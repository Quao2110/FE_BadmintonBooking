import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/colors.dart';
import '../../../routes/app_router.dart';
import '../../../data/models/product/product_list_query.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../bloc/category/category_bloc.dart';
import '../../bloc/category/category_event.dart';
import '../../bloc/category/category_state.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  int _cartCount = 3;
  int _selectedCategoryIndex = 0;
  String? _selectedCategoryId;
  String _search = '';
  double? _minPrice;
  double? _maxPrice;
  String? _sort;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  late final CategoryBloc _categoryBloc;
  late final ProductBloc _productBloc;

  @override
  void initState() {
    super.initState();
    _categoryBloc = CategoryBloc.create();
    _productBloc = ProductBloc.create();
    _categoryBloc.add(const GetAllCategoriesEvent());
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _categoryBloc.close();
    _productBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CategoryBloc>.value(value: _categoryBloc),
        BlocProvider<ProductBloc>.value(value: _productBloc),
      ],
      child: Scaffold(
        drawer: _StoreDrawer(
          onProducts: () => Navigator.pop(context),
          onServices: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, AppRoutes.serviceList);
          },
        ),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          title: const Text('Cửa hàng cầu lông'),
          leading: Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu),
              tooltip: 'Danh mục',
            ),
          ),
          actions: [
            _CartIcon(count: _cartCount, onTap: () {}),
            const SizedBox(width: 12),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              _SearchBar(
                controller: _searchController,
                onSubmitted: (value) {
                  _search = value.trim();
                  _fetchProducts();
                },
                onFilterTap: () => _showFilterSheet(context),
              ),
              const SizedBox(height: 12),
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoading) {
                    return const SizedBox(height: 38, child: Center(child: CircularProgressIndicator()));
                  }
                  if (state is CategoryListLoaded) {
                    final categories = state.categories;
                    final labels = ['All', ...categories.map((e) => e.categoryName)];
                    return _CategoryRow(
                      categories: labels,
                      selectedIndex: _selectedCategoryIndex,
                      onChanged: (index) {
                        setState(() {
                          _selectedCategoryIndex = index;
                          if (index == 0) {
                            _selectedCategoryId = null;
                          } else {
                            _selectedCategoryId = categories[index - 1].id;
                          }
                        });
                        _fetchProducts();
                      },
                    );
                  }
                  if (state is CategoryError) {
                    return _InlineError(
                      message: state.message,
                      onRetry: () => _categoryBloc.add(const GetAllCategoriesEvent()),
                    );
                  }
                  return const SizedBox(height: 38);
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is ProductLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ProductListLoaded) {
                      final items = state.products;
                      if (items.isEmpty) {
                        return const Center(child: Text('Không có sản phẩm'));
                      }
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _ProductCard(
                            item: item,
                            onAdd: () {
                              setState(() => _cartCount += 1);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to cart successfully!'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.storeDetail,
                                arguments: ProductDetailArgs(item),
                              );
                            },
                          );
                        },
                      );
                    }
                    if (state is ProductError) {
                      return _InlineError(
                        message: state.message,
                        onRetry: _fetchProducts,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _fetchProducts() {
    final query = ProductListQuery(
      search: _search.isEmpty ? null : _search,
      categoryId: _selectedCategoryId,
      page: 1,
      pageSize: 12,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      sort: _sort,
    );
    _productBloc.add(GetProductsEvent(query));
  }

  void _showFilterSheet(BuildContext context) {
    _minPriceController.text = _minPrice?.toStringAsFixed(0) ?? '';
    _maxPriceController.text = _maxPrice?.toStringAsFixed(0) ?? '';
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        double? tempMin = _minPrice;
        double? tempMax = _maxPrice;
        String? tempSort = _sort;

        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filters', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                const Text('Giá', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Từ (₫)',
                        ),
                        onChanged: (v) => tempMin = _parseDouble(v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _maxPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Đến (₫)',
                        ),
                        onChanged: (v) => tempMax = _parseDouble(v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Sắp xếp', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                _SortOption(
                  label: 'Giá tăng dần',
                  value: 'price_asc',
                  groupValue: tempSort,
                  onChanged: (v) => setModalState(() => tempSort = v),
                ),
                _SortOption(
                  label: 'Giá giảm dần',
                  value: 'price_desc',
                  groupValue: tempSort,
                  onChanged: (v) => setModalState(() => tempSort = v),
                ),
                _SortOption(
                  label: 'Mới nhất',
                  value: 'newest',
                  groupValue: tempSort,
                  onChanged: (v) => setModalState(() => tempSort = v),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _minPrice = tempMin;
                        _maxPrice = tempMax;
                        _sort = tempSort;
                      });
                      Navigator.pop(context);
                      _fetchProducts();
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onFilterTap;
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  const _SearchBar({
    required this.onFilterTap,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm Yonex...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 48,
          width: 48,
          child: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: onFilterTap,
            icon: const Icon(Icons.tune),
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _CategoryRow({
    required this.categories,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return InkWell(
            onTap: () => onChanged(index),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: selected ? AppColors.background : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductEntity item;
  final VoidCallback onAdd;
  final VoidCallback onTap;

  const _ProductCard({
    required this.item,
    required this.onAdd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.shopping_bag, size: 54, color: AppColors.accent),
                ),
              ),
              const SizedBox(height: 10),
              Text(item.productName, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                item.categoryName ?? '',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('₫${_formatCurrency(item.price)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  IconButton(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartIcon extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _CartIcon({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: onTap,
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: AppColors.background,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final String value;
  final String? groupValue;
  final ValueChanged<String> onChanged;
  const _SortOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      dense: true,
      contentPadding: EdgeInsets.zero,
      onChanged: (v) => onChanged(v ?? value),
      title: Text(label),
      activeColor: AppColors.primary,
    );
  }
}

class _StoreDrawer extends StatelessWidget {
  final VoidCallback onProducts;
  final VoidCallback onServices;
  const _StoreDrawer({
    required this.onProducts,
    required this.onServices,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.shopping_bag, color: AppColors.background, size: 28),
                SizedBox(height: 10),
                Text(
                  'Danh mục',
                  style: TextStyle(color: AppColors.background, fontSize: 18),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.store, color: AppColors.textPrimary),
            title: const Text('Sản phẩm'),
            onTap: onProducts,
          ),
          ListTile(
            leading: const Icon(Icons.build, color: AppColors.textPrimary),
            title: const Text('Dịch vụ'),
            onTap: onServices,
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _InlineError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(message, style: const TextStyle(color: AppColors.textSecondary))),
        TextButton(onPressed: onRetry, child: const Text('Thử lại')),
      ],
    );
  }
}

String _formatCurrency(double value) {
  final s = value.round().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idx = s.length - i;
    buf.write(s[i]);
    if (idx > 1 && idx % 3 == 1) buf.write('.');
  }
  return buf.toString();
}

double? _parseDouble(String text) {
  final normalized = text.replaceAll('.', '').replaceAll(',', '').trim();
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}
