import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../core/theme/colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/models/product/product_list_query.dart';
import '../../../data/models/product/create_product_request.dart';
import '../../../data/models/product/update_product_request.dart';
import 'admin_layout.dart';
import '../../../routes/app_router.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../bloc/category/category_bloc.dart';
import '../../bloc/category/category_event.dart';
import '../../bloc/category/category_state.dart';

/// Admin Products Management Page
class AdminProductsPage extends StatelessWidget {
  final User user;

  const AdminProductsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      user: user,
      currentRoute: AppRoutes.adminProducts,
      child: BlocProvider(
        create: (_) =>
            ProductBloc.create()..add(GetProductsEvent(ProductListQuery())),
        child: const _AdminProductsContent(),
      ),
    );
  }
}

class _AdminProductsContent extends StatefulWidget {
  const _AdminProductsContent();

  @override
  State<_AdminProductsContent> createState() => _AdminProductsContentState();
}

String? _pickBestProductImageUrl(ProductEntity product) {
  final candidates = <String>[];

  final thumbnails = product.productImages
      .where((e) => e.isThumbnail && e.imageUrl.trim().isNotEmpty)
      .toList()
    ..sort((a, b) {
      final ad = DateTime.tryParse(a.createdAt ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = DateTime.tryParse(b.createdAt ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });
  candidates.addAll(thumbnails.map((e) => e.imageUrl.trim()));

  final others = product.productImages
      .where((e) => e.imageUrl.trim().isNotEmpty)
      .toList()
    ..sort((a, b) {
      final ad = DateTime.tryParse(a.createdAt ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = DateTime.tryParse(b.createdAt ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });
  candidates.addAll(others.map((e) => e.imageUrl.trim()));

  final direct = product.imageUrl?.trim();
  if (direct != null && direct.isNotEmpty) {
    candidates.add(direct);
  }

  for (final candidate in candidates) {
    if (_isDisplayableImageUrl(candidate)) {
      return candidate;
    }
  }

  return null;
}

bool _isDisplayableImageUrl(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return false;
  if (!_looksLikeBase64Image(value)) return true;
  final bytes = _tryDecodeBase64Image(value);
  return bytes != null && bytes.isNotEmpty;
}

bool _looksLikeBase64Image(String value) {
  final v = value.trim();
  if (v.startsWith('data:image')) return true;
  if (v.startsWith('http://') || v.startsWith('https://')) return false;
  if (v.startsWith('/')) return false;
  if (v.contains('://')) return false;

  // Heuristic for raw base64 strings saved without data URI prefix.
  final maybeBase64 = RegExp(r'^[A-Za-z0-9+/=_\-\s]+$').hasMatch(v);
  return maybeBase64 && v.length > 120;
}

Uint8List? _tryDecodeBase64Image(String value) {
  final v = value.trim();

  if (v.startsWith('data:image')) {
    try {
      final uriData = UriData.parse(v);
      final bytes = uriData.contentAsBytes();
      if (bytes.isNotEmpty) return bytes;
    } catch (_) {}
  }

  String encoded;
  final commaIndex = v.indexOf(',');
  if (commaIndex > 0 && commaIndex < v.length - 1) {
    encoded = v.substring(commaIndex + 1);
  } else {
    encoded = v;
  }

  try {
    encoded = encoded.replaceAll(RegExp(r'\s+'), '');
    encoded = encoded.replaceAll('-', '+').replaceAll('_', '/');
    final mod = encoded.length % 4;
    if (mod != 0) {
      encoded = '$encoded${'=' * (4 - mod)}';
    }
    final bytes = base64Decode(encoded);
    if (bytes.isNotEmpty) return bytes;
  } catch (_) {}

  return null;
}

class _AdminProductsContentState extends State<_AdminProductsContent> {
  String? _resolveProductImageUrl(ProductEntity product) {
    return _pickBestProductImageUrl(product);
  }
  String _searchQuery = '';
  int _currentPage = 0;
  final int _rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          context.read<ProductBloc>().add(GetProductsEvent(ProductListQuery()));
        } else if (state is ProductError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          List<ProductEntity> products = [];
          if (state is ProductListLoaded) {
            products = state.products;
          }

          final filteredProducts = _searchQuery.isEmpty
              ? products
              : products
                    .where(
                      (p) => p.productName.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();

          final totalPages = (filteredProducts.length / _rowsPerPage).ceil();
          final startIndex = _currentPage * _rowsPerPage;
          final endIndex = (startIndex + _rowsPerPage < filteredProducts.length)
              ? startIndex + _rowsPerPage
              : filteredProducts.length;
          final displayedProducts = filteredProducts.sublist(
            startIndex,
            endIndex,
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 900;

              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 12 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Text(
                              'Quản lý Sản phẩm',
                              style: TextStyle(
                                fontSize: isMobile ? 20 : 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.refresh_rounded),
                              tooltip: 'Làm mới',
                              onPressed: () => context.read<ProductBloc>().add(
                                GetProductsEvent(ProductListQuery()),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isMobile ? 12 : 24),

                        // Search & Stats
                        Container(
                          padding: EdgeInsets.all(isMobile ? 12 : 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              TextField(
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                    _currentPage = 0;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm theo tên sản phẩm...',
                                  hintStyle: TextStyle(
                                    fontSize: isMobile ? 13 : 14,
                                  ),
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 12 : 16,
                                    vertical: isMobile ? 8 : 12,
                                  ),
                                ),
                              ),
                              SizedBox(height: isMobile ? 12 : 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _StatChip(
                                    icon: Icons.inventory_2_rounded,
                                    label: 'Tổng',
                                    value: '${products.length}',
                                    color: Colors.blue,
                                  ),
                                  _StatChip(
                                    icon: Icons.check_circle_rounded,
                                    label: 'Hoạt động',
                                    value:
                                        '${products.where((p) => p.isActive).length}',
                                    color: Colors.green,
                                  ),
                                  _StatChip(
                                    icon: Icons.cancel_rounded,
                                    label: 'Ngừng bán',
                                    value:
                                        '${products.where((p) => !p.isActive).length}',
                                    color: Colors.red,
                                  ),
                                  _StatChip(
                                    icon: Icons.inventory_rounded,
                                    label: 'Còn hàng',
                                    value:
                                        '${products.where((p) => p.stockQuantity > 0).length}',
                                    color: Colors.orange,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isMobile ? 12 : 24),

                        // Loading / Empty / Content
                        if (state is ProductLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(48.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (filteredProducts.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(48),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Không tìm thấy sản phẩm',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (isMobile)
                          // Mobile: Card layout
                          Column(
                            children: displayedProducts
                                .map(
                                  (product) => _ProductCard(
                                    product: product,
                                    onUploadImage: () => _showUploadImageDialog(
                                      context,
                                      product,
                                    ),
                                    onEdit: () =>
                                        _showEditDialog(context, product),
                                    onDelete: () =>
                                        _showDeleteDialog(context, product),
                                  ),
                                )
                                .toList(),
                          )
                        else
                          // Desktop: DataTable
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: MaterialStateProperty.all(
                                      Colors.grey.shade50,
                                    ),
                                    columns: const [
                                      DataColumn(label: Text('Hình ảnh')),
                                      DataColumn(label: Text('Tên sản phẩm')),
                                      DataColumn(label: Text('Danh mục')),
                                      DataColumn(label: Text('Giá')),
                                      DataColumn(label: Text('Tồn kho')),
                                      DataColumn(label: Text('Trạng thái')),
                                      DataColumn(label: Text('Thao tác')),
                                    ],
                                    rows: displayedProducts.map((product) {
                                      final resolvedImageUrl =
                                          _resolveProductImageUrl(product);
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Colors.grey.shade200,
                                              ),
                                                child: resolvedImageUrl != null
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: _SmartProductImage(
                                                    imageUrl:
                                                      resolvedImageUrl,
                                                        fallbackIcon:
                                                            Icons.inventory_2,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons.inventory_2,
                                                      color: Colors.grey,
                                                    ),
                                            ),
                                          ),
                                          DataCell(Text(product.productName)),
                                          DataCell(
                                            Text(
                                              product.categoryName ?? 'N/A',
                                              style: TextStyle(
                                                color:
                                                    product.categoryName == null
                                                    ? Colors.grey
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              '${product.price.toStringAsFixed(0)}đ',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            _StockBadge(
                                              quantity: product.stockQuantity,
                                            ),
                                          ),
                                          DataCell(
                                            _StatusBadge(
                                              isActive: product.isActive,
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons
                                                        .add_photo_alternate_outlined,
                                                    size: 20,
                                                  ),
                                                  color: Colors.teal,
                                                  tooltip: 'Thêm ảnh',
                                                  onPressed: () =>
                                                      _showUploadImageDialog(
                                                        context,
                                                        product,
                                                      ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.edit_outlined,
                                                    size: 20,
                                                  ),
                                                  color: Colors.blue,
                                                  tooltip: 'Chỉnh sửa',
                                                  onPressed: () =>
                                                      _showEditDialog(
                                                        context,
                                                        product,
                                                      ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    size: 20,
                                                  ),
                                                  color: Colors.red,
                                                  tooltip: 'Xóa',
                                                  onPressed: () =>
                                                      _showDeleteDialog(
                                                        context,
                                                        product,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),

                                // Pagination
                                if (totalPages > 1)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Hiển thị ${startIndex + 1}-$endIndex trong tổng ${filteredProducts.length}',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.chevron_left,
                                              ),
                                              onPressed: _currentPage > 0
                                                  ? () => setState(
                                                      () => _currentPage--,
                                                    )
                                                  : null,
                                            ),
                                            ...List.generate(totalPages, (
                                              index,
                                            ) {
                                              if (totalPages > 7 &&
                                                  (index > 2 &&
                                                      index < totalPages - 3 &&
                                                      index != _currentPage)) {
                                                if (index == 3) {
                                                  return const Text('...  ');
                                                }
                                                return const SizedBox.shrink();
                                              }
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                    ),
                                                child: InkWell(
                                                  onTap: () => setState(
                                                    () => _currentPage = index,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          _currentPage == index
                                                          ? AppColors.primary
                                                          : Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            _currentPage ==
                                                                index
                                                            ? AppColors.primary
                                                            : Colors
                                                                  .grey
                                                                  .shade300,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '${index + 1}',
                                                      style: TextStyle(
                                                        color:
                                                            _currentPage ==
                                                                index
                                                            ? Colors.white
                                                            : AppColors
                                                                  .textPrimary,
                                                        fontWeight:
                                                            _currentPage ==
                                                                index
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.chevron_right,
                                              ),
                                              onPressed:
                                                  _currentPage < totalPages - 1
                                                  ? () => setState(
                                                      () => _currentPage++,
                                                    )
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                        // Mobile pagination
                        if (isMobile && totalPages > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed: _currentPage > 0
                                      ? () => setState(() => _currentPage--)
                                      : null,
                                ),
                                Text(
                                  'Trang ${_currentPage + 1}/$totalPages',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: _currentPage < totalPages - 1
                                      ? () => setState(() => _currentPage++)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // FAB
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton.extended(
                      onPressed: () => _showCreateDialog(context),
                      icon: const Icon(Icons.add),
                      label: Text(isMobile ? 'Thêm' : 'Thêm sản phẩm'),
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductBloc>(),
        child: const _CreateProductDialog(),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ProductEntity product) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductBloc>(),
        child: _EditProductDialog(product: product),
      ),
    );
  }

  void _showUploadImageDialog(BuildContext context, ProductEntity product) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductBloc>(),
        child: _UploadProductImageDialog(product: product),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ProductEntity product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa sản phẩm "${product.productName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProductBloc>().add(DeleteProductEvent(product.id));
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onUploadImage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onUploadImage,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = _pickBestProductImageUrl(product);
  
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                    child: resolvedImageUrl != null && resolvedImageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _SmartProductImage(
                            imageUrl: resolvedImageUrl,
                            fallbackIcon: Icons.inventory_2,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.inventory_2,
                          color: Colors.grey,
                          size: 40,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (product.categoryName != null)
                        Text(
                          product.categoryName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.price.toStringAsFixed(0)}đ',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _StockBadge(quantity: product.stockQuantity),
                          const SizedBox(width: 8),
                          _StatusBadge(isActive: product.isActive),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onUploadImage,
                  icon: const Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 18,
                  ),
                  label: const Text('Ảnh'),
                  style: TextButton.styleFrom(foregroundColor: Colors.teal),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Sửa'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Xóa'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmartProductImage extends StatelessWidget {
  final String? imageUrl;
  final IconData fallbackIcon;
  final BoxFit fit;

  const _SmartProductImage({
    required this.imageUrl,
    required this.fallbackIcon,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final raw = imageUrl?.trim();
    if (raw == null || raw.isEmpty) {
      return Icon(fallbackIcon, color: Colors.grey);
    }

    final bytes = _tryDecodeBase64Image(raw);
    if (bytes != null && bytes.isNotEmpty) {
      return Image.memory(
        bytes,
        fit: fit,
        errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: Colors.grey),
      );
    }

    if (_looksLikeBase64Image(raw)) {
      return Icon(fallbackIcon, color: Colors.grey);
    }

    return Image.network(
      ApiConstants.getFullImageUrl(raw),
      fit: fit,
      errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: Colors.grey),
    );
  }
}

class _UploadProductImageDialog extends StatefulWidget {
  final ProductEntity product;
  const _UploadProductImageDialog({required this.product});

  @override
  State<_UploadProductImageDialog> createState() =>
      _UploadProductImageDialogState();
}

class _UploadProductImageDialogState extends State<_UploadProductImageDialog> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  Future<void> _pickImage() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 92,
      );
      if (file != null && mounted) {
        setState(() => _selectedImage = file);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể chọn ảnh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submit() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh trước khi tải lên')),
      );
      return;
    }

    context.read<ProductBloc>().add(
      UploadProductImageEvent(
        productId: widget.product.id,
        imageFile: _selectedImage!,
        isThumbnail: true,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;
    final maxDialogHeight = media.size.height * (isLandscape ? 0.82 : 0.72);
    final previewHeight = isLandscape ? 130.0 : 220.0;

    return AlertDialog(
      title: const Text('Tải ảnh sản phẩm'),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500, maxHeight: maxDialogHeight),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sản phẩm: ${widget.product.productName}'),
              const SizedBox(height: 4),
              SelectableText(
                'ID: ${widget.product.id}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: previewHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.grey.shade50,
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 48,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(height: 8),
                            const Text('Chọn ảnh để xem trước'),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.network(
                                  _selectedImage!.path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Chọn file'),
                  ),
                  if (_selectedImage != null)
                    SizedBox(
                      width: 220,
                      child: Text(
                        _selectedImage!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Ảnh tải lên sẽ được đặt làm ảnh đại diện mới nhất.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.upload),
          label: const Text('Tải lên'),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Text(
        isActive ? 'Đang bán' : 'Ngừng bán',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int quantity;

  const _StockBadge({required this.quantity});

  @override
  Widget build(BuildContext context) {
    final isInStock = quantity > 0;
    final isLowStock = quantity > 0 && quantity < 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isInStock
            ? (isLowStock ? Colors.orange.shade50 : Colors.blue.shade50)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'SL: $quantity',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isInStock
              ? (isLowStock ? Colors.orange.shade700 : Colors.blue.shade700)
              : Colors.grey.shade600,
        ),
      ),
    );
  }
}

// Create Product Dialog
class _CreateProductDialog extends StatefulWidget {
  const _CreateProductDialog();
  @override
  State<_CreateProductDialog> createState() => _CreateProductDialogState();
}

class _CreateProductDialogState extends State<_CreateProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  String? _selectedCategoryId;
  bool _isActive = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm sản phẩm mới'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCategorySelector(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên sản phẩm *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Vui lòng nhập tên' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Giá *',
                    border: OutlineInputBorder(),
                    suffixText: 'đ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.trim().isEmpty == true) return 'Vui lòng nhập giá';
                    if (double.tryParse(v!) == null) return 'Giá không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tồn kho *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.trim().isEmpty == true)
                      return 'Vui lòng nhập số lượng';
                    if (int.tryParse(v!) == null)
                      return 'Số lượng không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Đang bán'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Tạo')),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return BlocProvider(
      create: (_) => CategoryBloc.create()..add(const GetAllCategoriesEvent()),
      child: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryListLoaded) {
            final categoryIds = state.categories.map((c) => c.id).toSet();
            final validValue = categoryIds.contains(_selectedCategoryId)
                ? _selectedCategoryId
                : null;
            return DropdownButtonFormField<String>(
              value: validValue,
              decoration: const InputDecoration(
                labelText: 'Danh mục *',
                border: OutlineInputBorder(),
              ),
              items: state.categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.categoryName),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
              validator: (v) => v == null ? 'Vui lòng chọn danh mục' : null,
            );
          }
          return const LinearProgressIndicator();
        },
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<ProductBloc>().add(
        CreateProductEvent(
          CreateProductRequest(
            categoryId: _selectedCategoryId!,
            productName: _nameCtrl.text.trim(),
            description: _descCtrl.text.trim().isEmpty
                ? null
                : _descCtrl.text.trim(),
            price: double.parse(_priceCtrl.text),
            stockQuantity: int.parse(_stockCtrl.text),
            isActive: _isActive,
          ),
        ),
      );
      Navigator.pop(context);
    }
  }
}

// Edit Product Dialog
class _EditProductDialog extends StatefulWidget {
  final ProductEntity product;
  const _EditProductDialog({required this.product});
  @override
  State<_EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<_EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _stockCtrl;
  late String? _selectedCategoryId;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product.productName);
    _descCtrl = TextEditingController(text: widget.product.description ?? '');
    _priceCtrl = TextEditingController(
      text: widget.product.price.toStringAsFixed(0),
    );
    _stockCtrl = TextEditingController(
      text: widget.product.stockQuantity.toString(),
    );
    _selectedCategoryId = widget.product.categoryId;
    _isActive = widget.product.isActive;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chỉnh sửa sản phẩm'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCategorySelector(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên sản phẩm *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Vui lòng nhập tên' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Giá *',
                    border: OutlineInputBorder(),
                    suffixText: 'đ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.trim().isEmpty == true) return 'Vui lòng nhập giá';
                    if (double.tryParse(v!) == null) return 'Giá không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tồn kho *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.trim().isEmpty == true)
                      return 'Vui lòng nhập số lượng';
                    if (int.tryParse(v!) == null)
                      return 'Số lượng không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Đang bán'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Lưu')),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return BlocProvider(
      create: (_) => CategoryBloc.create()..add(const GetAllCategoriesEvent()),
      child: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryListLoaded) {
            final categoryIds = state.categories.map((c) => c.id).toSet();
            final validValue = categoryIds.contains(_selectedCategoryId)
                ? _selectedCategoryId
                : null;
            return DropdownButtonFormField<String>(
              value: validValue,
              decoration: const InputDecoration(
                labelText: 'Danh mục *',
                border: OutlineInputBorder(),
              ),
              items: state.categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.categoryName),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
              validator: (v) => v == null ? 'Vui lòng chọn danh mục' : null,
            );
          }
          return const LinearProgressIndicator();
        },
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<ProductBloc>().add(
        UpdateProductEvent(
          widget.product.id,
          UpdateProductRequest(
            categoryId: _selectedCategoryId!,
            productName: _nameCtrl.text.trim(),
            description: _descCtrl.text.trim().isEmpty
                ? null
                : _descCtrl.text.trim(),
            price: double.parse(_priceCtrl.text),
            stockQuantity: int.parse(_stockCtrl.text),
            isActive: _isActive,
          ),
        ),
      );
      Navigator.pop(context);
    }
  }
}
