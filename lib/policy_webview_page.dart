import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PolicyWebViewPage extends StatelessWidget {
  final String url;
  final String title;

  const PolicyWebViewPage({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    // 创建 WebViewController
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: WebViewWidget(controller: controller),
    );
  }
}
