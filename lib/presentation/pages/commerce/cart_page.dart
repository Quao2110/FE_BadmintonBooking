import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../data/datasources/commerce_api_service.dart';
import '../../../data/models/commerce/cart_item_model.dart';
import '../../../data/models/commerce/cart_model.dart';
import '../../../routes/app_router.dart';
import '../../../shared/widgets/app_notification.dart';
import '../../../shared/widgets/empty_widget.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CommerceApiService _commerce = CommerceApiService();
  final Map<String, Timer> _debouncers = <String, Timer>{};

  bool _isLoading = true;
  bool _isProcessing = false;
  String? _error;
  CartModel _cart = CartModel.empty();

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void dispose() {
    for (final timer in _debouncers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final cart = await _commerce.getCart();
      if (!mounted) return;
      setState(() => _cart = cart);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateQuantityDebounced(CartItemModel item, int nextQty) {
    if (nextQty <= 0) {
      _removeItem(item.id);
      return;
    }

    if (nextQty > item.stockQuantity && item.stockQuantity > 0) {
      AppNotification.showWarning(
        'So luong vuot qua ton kho (${item.stockQuantity}).',
      );
      return;
    }

    setState(() {
      _cart = CartModel(
        id: _cart.id,
        items: _cart.items
            .map((e) => e.id == item.id ? e.copyWith(quantity: nextQty) : e)
            .toList(),
        subtotal: _cart.items
            .map((e) => e.id == item.id ? e.copyWith(quantity: nextQty) : e)
            .fold(0.0, (sum, e) => sum + e.subtotal),
        total: _cart.items
            .map((e) => e.id == item.id ? e.copyWith(quantity: nextQty) : e)
            .fold(0.0, (sum, e) => sum + e.subtotal),
      );
    });

    _debouncers[item.id]?.cancel();
    _debouncers[item.id] = Timer(const Duration(milliseconds: 550), () async {
      try {
        await _commerce.updateCartItem(cartItemId: item.id, quantity: nextQty);
      } catch (e) {
        if (!mounted) return;
        AppNotification.showError(_friendlyError(e));
        _loadCart();
      }
    });
  }

  Future<void> _removeItem(String cartItemId) async {
    setState(() => _isProcessing = true);
    try {
      await _commerce.removeCartItem(cartItemId);
      await _loadCart();
    } catch (e) {
      AppNotification.showError(_friendlyError(e));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _clearCart() async {
    setState(() => _isProcessing = true);
    try {
      await _commerce.clearCart();
      await _loadCart();
      AppNotification.showSuccess('Da xoa toan bo gio hang.');
    } catch (e) {
      AppNotification.showError(_friendlyError(e));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _goCheckout() async {
    if (_cart.items.isEmpty) return;
    await Navigator.pushNamed(
      context,
      AppRoutes.checkout,
      arguments: CheckoutArgs(_cart),
    );
    _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    final canCheckout = _cart.items.isNotEmpty && !_isProcessing;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        title: const Text('Gio hang'),
        actions: [
          if (_cart.items.isNotEmpty)
            IconButton(
              onPressed: _isProcessing ? null : _clearCart,
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear cart',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _CartError(message: _error!, onRetry: _loadCart)
          : _cart.items.isEmpty
          ? const EmptyWidget(
              icon: Icons.remove_shopping_cart_outlined,
              message: 'Gio hang cua ban dang trong.',
            )
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadCart,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                      itemCount: _cart.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _cart.items[index];
                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade500,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) => _removeItem(item.id),
                          child: _CartItemCard(
                            item: item,
                            onDecrease: () => _updateQuantityDebounced(
                              item,
                              item.quantity - 1,
                            ),
                            onIncrease: () => _updateQuantityDebounced(
                              item,
                              item.quantity + 1,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                _CartSummary(
                  subtotal: _cart.subtotal,
                  total: _cart.total,
                  itemCount: _cart.itemCount,
                  onCheckout: _goCheckout,
                  enabled: canCheckout,
                ),
              ],
            ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _CartItemCard({
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: item.imageUrl == null || item.imageUrl!.isEmpty
                ? const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.accent,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.inventory_2_outlined),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  item.categoryName ?? 'Product',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'VND ${_formatMoney(item.unitPrice)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              _QtyButton(icon: Icons.add, onTap: onIncrease),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              _QtyButton(icon: Icons.remove, onTap: onDecrease),
            ],
          ),
        ],
      ),
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.background,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final double subtotal;
  final double total;
  final int itemCount;
  final VoidCallback onCheckout;
  final bool enabled;

  const _CartSummary({
    required this.subtotal,
    required this.total,
    required this.itemCount,
    required this.onCheckout,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          _SummaryLine(label: 'Items', value: '$itemCount'),
          const SizedBox(height: 6),
          _SummaryLine(
            label: 'Subtotal',
            value: 'VND ${_formatMoney(subtotal)}',
          ),
          const SizedBox(height: 6),
          _SummaryLine(
            label: 'Total',
            value: 'VND ${_formatMoney(total)}',
            highlight: true,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: enabled ? onCheckout : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Checkout'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _SummaryLine({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: highlight ? AppColors.primary : AppColors.textPrimary,
      fontWeight: highlight ? FontWeight.w800 : FontWeight.w500,
      fontSize: highlight ? 16 : 14,
    );

    return Row(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: style),
      ],
    );
  }
}

class _CartError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _CartError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 52, color: Colors.redAccent),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

String _formatMoney(double value) {
  final s = value.round().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idx = s.length - i;
    buf.write(s[i]);
    if (idx > 1 && idx % 3 == 1) {
      buf.write('.');
    }
  }
  return buf.toString();
}

String _friendlyError(Object error) {
  return error.toString().replaceFirst('Exception: ', '').trim();
}
