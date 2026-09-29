import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final int orderId;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.orderId,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            _checkRedirect(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _checkRedirect(url);
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (_checkRedirect(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  bool _checkRedirect(String url) {
    // Flexible query parameter extractor (handles double '?' or '&')
    String? getQueryParam(String key) {
      try {
        final uri = Uri.parse(url);
        if (uri.queryParameters.containsKey(key)) {
          return uri.queryParameters[key];
        }
      } catch (_) {}
      final regExp = RegExp('[?&]$key=([^&#]*)', caseSensitive: false);
      final match = regExp.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return Uri.decodeComponent(match.group(1)!);
      }
      return null;
    }

    final lowerUrl = url.toLowerCase();
    final isCallback = lowerUrl.contains('/callback') ||
        lowerUrl.contains('payment-callback') ||
        lowerUrl.contains('order-success') ||
        lowerUrl.contains('status=paid') ||
        lowerUrl.contains('status=failed') ||
        lowerUrl.contains('status=canceled') ||
        lowerUrl.contains('status=cancelled');

    if (isCallback) {
      final paymentId = getQueryParam('id') ??
          getQueryParam('paymentId') ??
          getQueryParam('payment_id') ??
          getQueryParam('Id');
      final status = getQueryParam('status')?.toLowerCase();
      final message = getQueryParam('message')?.toLowerCase();

      final isSuccessStatus = status == 'paid' ||
          status == 'captured' ||
          status == 'authorized' ||
          status == 'completed' ||
          status == 'success' ||
          (message != null && message.contains('succeed'));

      if (paymentId != null && paymentId.isNotEmpty) {
        // If status is explicit failure/cancel, abort
        if (status == 'failed' || status == 'canceled' || status == 'cancelled') {
          Navigator.of(context).pop(null);
          return true;
        }
        // Otherwise, pop the payment ID for verification
        Navigator.of(context).pop(paymentId);
        return true;
      }

      // If status is paid/success but no payment ID was in the URL
      if (isSuccessStatus) {
        Navigator.of(context).pop('order_${widget.orderId}_paid');
        return true;
      }

      // If explicitly failed
      if (status == 'failed' || status == 'canceled' || status == 'cancelled') {
        Navigator.of(context).pop(null);
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الدفع الآمن',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(null),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8B1E3F),
              ),
            ),
        ],
      ),
    );
  }
}
