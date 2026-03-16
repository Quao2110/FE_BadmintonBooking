import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../data/datasources/commerce_api_service.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../routes/app_router.dart';
import '../../../shared/widgets/app_notification.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductEntity product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _qty = 1;
  int _cartCount = 0;
  bool _isAdding = false;
  final CommerceApiService _commerce = CommerceApiService();

  @override
  void initState() {
    super.initState();
    _refreshCartCount();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final imageUrl = _resolveImageUrl(product);
    final isInStock = product.stockQuantity > 0 && product.isActive;
    final desc = product.description?.trim();
    return Scaffold(
      appBar: AppBar(
        title: Text(product.productName),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Về trang chủ',
          ),
          _CartBadge(
            count: _cartCount,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.cart,
            ).then((_) => _refreshCartCount()),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ImageCard(imageUrl: imageUrl),
                    const SizedBox(height: 12),
                    Text(
                      product.productName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.categoryName ?? 'Cầu lông',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    _SectionCard(
                      child: Text(
                        (desc != null && desc.isNotEmpty)
                            ? desc
                            : 'Chưa có mô tả sản phẩm.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SectionCard(
                      child: Column(
                        children: [
                          _InfoRow(
                            label: 'Giá',
                            value: '₫${_formatCurrency(product.price)}',
                          ),
                          const SizedBox(height: 8),
                          _InfoRow(
                            label: 'Tồn kho',
                            value: '${product.stockQuantity}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SectionCard(
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Số lượng',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          _QtySelector(
                            value: _qty,
                            max: product.stockQuantity,
                            onChanged: (v) => setState(() => _qty = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  children: [
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: isInStock && !_isAdding ? _addToCart : null,
                        child: _isAdding
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(isInStock ? 'Thêm vào giỏ' : 'Hết hàng'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshCartCount() async {
    try {
      final cart = await _commerce.getCart();
      if (!mounted) return;
      setState(() => _cartCount = cart.itemCount);
    } catch (_) {
      // Keep badge silent if cart api is unavailable.
    }
  }

  Future<void> _addToCart() async {
    setState(() => _isAdding = true);
    try {
      await _commerce.addToCart(productId: widget.product.id, quantity: _qty);
      await _refreshCartCount();
      AppNotification.showSuccess('Added to cart successfully.');
    } catch (e) {
      AppNotification.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }
}

class _ImageCard extends StatelessWidget {
  final String? imageUrl;
  const _ImageCard({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: imageUrl == null || imageUrl!.isEmpty
            ? const Icon(Icons.shopping_bag, size: 90, color: AppColors.accent)
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.shopping_bag,
                    size: 90,
                    color: AppColors.accent,
                  ),
                ),
              ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _QtySelector extends StatelessWidget {
  final int value;
  final int max;
  final ValueChanged<int> onChanged;
  const _QtySelector({
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final canInc = max <= 0 ? false : value < max;
    return Row(
      children: [
        _QtyButton(
          icon: Icons.remove,
          onTap: () {
            if (value > 1) onChanged(value - 1);
          },
        ),
        Container(
          width: 46,
          alignment: Alignment.center,
          child: Text('$value', style: const TextStyle(fontSize: 16)),
        ),
        _QtyButton(
          icon: Icons.add,
          onTap: () {
            if (canInc) onChanged(value + 1);
          },
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _CartBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _CartBadge({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: const Icon(Icons.shopping_cart_outlined),
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

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

String? _resolveImageUrl(ProductEntity product) {
  if (product.imageUrl != null && product.imageUrl!.trim().isNotEmpty) {
    return product.imageUrl!.trim();
  }
  if (product.productImages.isNotEmpty) {
    final thumb = product.productImages.where((e) => e.isThumbnail).toList();
    if (thumb.isNotEmpty) return thumb.first.imageUrl;
    return product.productImages.first.imageUrl;
  }
  return null;
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
