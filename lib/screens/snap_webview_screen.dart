import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/gradient_button.dart';
import 'transaction_complete_screen.dart';

class SnapWebViewScreen extends StatefulWidget {
  final String snapToken;
  final String redirectUrl;
  final String orderId;
  final Map<String, dynamic> destination;
  final int pax;
  final int total;

  const SnapWebViewScreen({
    super.key,
    required this.snapToken,
    required this.redirectUrl,
    required this.orderId,
    required this.destination,
    required this.pax,
    required this.total,
  });

  @override
  State<SnapWebViewScreen> createState() => _SnapWebViewScreenState();
}

class _SnapWebViewScreenState extends State<SnapWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;
  bool _navPopulated = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            final uri = Uri.parse(request.url);

            if (uri.path.contains('/finish')) {
              _navigateToComplete();
              return NavigationDecision.prevent;
            }

            if (uri.path.contains('/pending') ||
                uri.path.contains('/unfinish')) {
              _navigateToComplete();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() {
              _error = _friendlyError(error);
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  String _friendlyError(WebResourceError error) {
    final code = error.errorCode;
    if (code == 6) {
      return 'Cannot reach Midtrans. Please check your internet connection and try again.';
    }
    if (code == 8) {
      return 'Connection refused by Midtrans server. Please try again later.';
    }
    if (code == -2 || code == -1) {
      return 'Network error. Please check your internet connection.';
    }
    return error.description;
  }

  void _navigateToComplete() {
    if (!mounted || _navPopulated) return;
    _navPopulated = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionCompleteScreen(
          destination: widget.destination,
          pax: widget.pax,
          total: widget.total,
          payMethod: 'Midtrans',
        ),
      ),
    );
  }

  void _retry() {
    setState(() {
      _error = null;
      _isLoading = true;
      _navPopulated = false;
    });
    _controller.loadRequest(Uri.parse(widget.redirectUrl));
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text('Are you sure you want to cancel this payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showCancelDialog();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1A2B),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D2B4E),
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeft,
                color: Colors.white, size: 18),
            onPressed: _showCancelDialog,
          ),
          title: const Text('Payment',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            if (_error != null)
              _buildErrorWidget()
            else
              WebViewWidget(controller: _controller),
            if (_isLoading && _error == null)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF42A5F5)),
                    SizedBox(height: 16),
                    Text('Loading payment page...',
                        style: TextStyle(color: Colors.white54)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(FontAwesomeIcons.wifi,
                color: Colors.orange, size: 48),
            const SizedBox(height: 20),
            const Text('Connection Error',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white60, fontSize: 14, height: 1.5)),
            const SizedBox(height: 24),
            GradientButton('Try Again', _retry, height: 48, radius: 12),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back',
                  style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}
