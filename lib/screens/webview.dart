import 'package:flutter/material.dart';
import 'package:webapp/utils/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewDemo extends StatefulWidget {
  const WebViewDemo({super.key});

  @override
  State<WebViewDemo> createState() => _WebViewDemoState();
}

class _WebViewDemoState extends State<WebViewDemo> {
  late WebViewController controller;
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color.fromARGB(0, 171, 167, 167))
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          setState(() {
            _isLoading =
                progress < 100; // Show loading if progress is less than 100%
          });
        },
        onPageStarted: (String url) {
          setState(() {
            _isLoading = true; // Show loading when page starts
          });
        },
        onPageFinished: (String url) {
          setState(() {
            _isLoading = false; // Hide loading when page finishes
          });
        },
        onHttpError: (HttpResponseError error) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) async {
          if (!request.url.startsWith(Urls.linkUrls)) {
            if (await canLaunchUrl(Uri.parse(request.url))) {
              await launchUrl(
                Uri.parse(request.url),
                mode: LaunchMode.externalApplication,
              );
              return NavigationDecision.prevent;
            }
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(Urls.url)); // Replace with your URL
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: () async {
          if (await controller.canGoBack()) {
            controller.goBack();
            return false; // Prevent app exit
          }
          return true; // Allow app exit
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              WebViewWidget(controller: controller),
              if (_isLoading) // Display progress indicator if loading
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
