import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../data/datasources/commerce_api_service.dart';
import '../../../data/models/commerce/cart_model.dart';
import '../../../data/models/commerce/order_model.dart';
import '../../../shared/widgets/app_notification.dart';
import 'vnpay_webview_page.dart';

class CheckoutPage extends StatefulWidget {
  final CartModel cart;

  const CheckoutPage({super.key, required this.cart});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  final CommerceApiService _commerce = CommerceApiService();

  String _paymentMethod = 'COD';
  bool _isSubmitting = false;
  bool _showValidationError = false;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      if (!mounted) return;
      setState(() => _showValidationError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete delivery information before checkout.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final order = await _commerce.checkout(
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        paymentMethod: _paymentMethod,
      );

      if (_paymentMethod == 'VNPAY') {
        await _startVnpay(order);
      } else {
        await _showOrderCreated(order);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      final message = _friendlyError(e);
      AppNotification.showError(message);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _startVnpay(OrderModel order) async {
    final amountVnd = order.totalAmount.round();
    final url = await _commerce.createVnPayLink(
      txnRef: order.id,
      amountVnd: amountVnd,
      orderInfo: 'Thanh toan don hang ${order.id}',
    );
    if (!mounted) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => VnpayWebviewPage(paymentUrl: url)),
    );

    if (!mounted) return;
    final success = result == true;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(success ? 'Payment success' : 'Payment pending/failed'),
        content: Text(
          success
              ? 'VNPAY reported a successful payment.'
              : 'Payment is not confirmed yet. Please check order status in history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showOrderCreated(OrderModel order) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order created'),
        content: Text('Order #${order.id} was created successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        title: const Text('Checkout'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _showValidationError
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Section(
              title: 'Delivery information',
              child: Column(
                children: [
                  TextFormField(
                    controller: _addressController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return 'Please enter address';
                      if (value.trim().length < 8)
                        return 'Address is too short';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                    ),
                    validator: (value) {
                      final phone = value?.trim() ?? '';
                      if (phone.isEmpty) return 'Please enter phone number';
                      if (phone.length < 9) return 'Phone number is invalid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _noteController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Section(
              title: 'Payment method',
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'COD',
                    groupValue: _paymentMethod,
                    title: const Text('Cash on delivery (COD)'),
                    onChanged: (value) =>
                        setState(() => _paymentMethod = value ?? 'COD'),
                  ),
                  RadioListTile<String>(
                    value: 'VNPAY',
                    groupValue: _paymentMethod,
                    title: const Text('VNPAY'),
                    onChanged: (value) =>
                        setState(() => _paymentMethod = value ?? 'VNPAY'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Section(
              title: 'Order summary',
              child: Column(
                children: [
                  _SummaryLine(
                    label: 'Items',
                    value: '${widget.cart.itemCount}',
                  ),
                  const SizedBox(height: 6),
                  _SummaryLine(
                    label: 'Subtotal',
                    value: 'VND ${_formatMoney(widget.cart.subtotal)}',
                  ),
                  const SizedBox(height: 6),
                  _SummaryLine(
                    label: 'Total',
                    value: 'VND ${_formatMoney(widget.cart.total)}',
                    highlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _paymentMethod == 'VNPAY'
                            ? 'Pay with VNPAY'
                            : 'Place order',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          child,
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
    return Row(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: highlight ? AppColors.primary : AppColors.textPrimary,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
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
