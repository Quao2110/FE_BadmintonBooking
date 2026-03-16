import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../data/datasources/commerce_api_service.dart';
import '../../../core/theme/colors.dart';

class VnpayWebviewPage extends StatefulWidget {
  final String paymentUrl;

  const VnpayWebviewPage({super.key, required this.paymentUrl});

  @override
  State<VnpayWebviewPage> createState() => _VnpayWebviewPageState();
}

class _VnpayWebviewPageState extends State<VnpayWebviewPage> {
  static const String _returnUrlPrefix = 'myapp://payment-result';
  late final WebViewController _controller;
  final CommerceApiService _commerceApiService = CommerceApiService();
  bool _isLoading = true;
  bool _hasFinished = false;

  Future<void> _finishFromUrl(String url) async {
    if (_hasFinished) return;
    _hasFinished = true;

    final uri = Uri.tryParse(url);
    if (uri == null) {
      Navigator.pop(context, false);
      return;
    }

    var serverConfirmed = false;
    try {
      serverConfirmed = await _commerceApiService.confirmVnPayReturn(
        uri.queryParameters,
      );
    } catch (_) {
      // Keep local UX responsive even when callback sync fails.
    }

    final code = uri.queryParameters['vnp_ResponseCode'] ?? '';
    final txnStatus = uri.queryParameters['vnp_TransactionStatus'] ?? '';
    final success = serverConfirmed || (code == '00' && txnStatus == '00');

    if (!mounted) return;
    Navigator.pop(context, success);
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (url) {
            if (!mounted) return;
            setState(() => _isLoading = false);

            final uri = Uri.tryParse(url);
            if (uri != null && _isReturnFromPayment(uri)) {
              _finishFromUrl(url);
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.navigate;

            if (_isCustomSchemeReturn(uri)) {
              _finishFromUrl(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            final url = error.url;
            if (url != null && url.startsWith(_returnUrlPrefix)) {
              _finishFromUrl(url);
            }
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
    return _isCustomSchemeReturn(uri) ||
        uri.queryParameters.containsKey('vnp_ResponseCode');
  }

  bool _isCustomSchemeReturn(Uri uri) {
    return uri.toString().startsWith(_returnUrlPrefix);
  }
}
