import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/colors.dart';

class VnpayWebviewPage extends StatefulWidget {
  final String paymentUrl;

  const VnpayWebviewPage({super.key, required this.paymentUrl});

  @override
  State<VnpayWebviewPage> createState() => _VnpayWebviewPageState();
}

class _VnpayWebviewPageState extends State<VnpayWebviewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.navigate;

            if (_isReturnFromPayment(uri)) {
              final code = uri.queryParameters['vnp_ResponseCode'] ?? '';
              final txnStatus =
                  uri.queryParameters['vnp_TransactionStatus'] ?? '';
              final success = code == '00' && txnStatus == '00';
              Navigator.pop(context, success);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        title: const Text('VNPAY Payment'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }

  bool _isReturnFromPayment(Uri uri) {
    final path = uri.path.toLowerCase();
    return path.contains('/payments/vnpay/return') ||
        uri.queryParameters.containsKey('vnp_ResponseCode');
  }
}
