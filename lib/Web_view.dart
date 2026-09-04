import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController controller;
  bool isLoading = true;
  int loadingProgress = 0;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              loadingProgress = progress;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          // onWebResourceError: (WebResourceError error) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(
          //       content: Text('Error: ${error.description}'),
          //       backgroundColor: Colors.red,
          //     ),
          //   );
          // },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF1A1A1A),
              size: 25,
            ),
          ),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontFamily: "Figtree-Medium",
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          // Reload button
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1A1A1A)),
            onPressed: () {
              controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),

          // Loading indicator
          if (isLoading)
            Column(
              children: [
                LinearProgressIndicator(
                  value: loadingProgress / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6C5CE7),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: const Color(0xFF6C5CE7),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}