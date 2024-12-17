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
 /// Launch the URL in an external browser
  Future<void> _launchURL(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }
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
           // If the request URL does not contain the linkUrls string
          if (!request.url.contains(Urls.linkUrls)) {
            // Open the URL in an external browser using _launchURL
            await _launchURL(Uri.parse(request.url));
            return NavigationDecision.prevent; // Prevent the WebView from navigating to the URL
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

// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:url_launcher/url_launcher.dart';

// class WebViewDemo extends StatefulWidget {
//   const WebViewDemo({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _WebViewDemoState createState() => _WebViewDemoState();
// }

// class _WebViewDemoState extends State<WebViewDemo> {
//   late InAppWebViewController _webViewController;
//   late InAppWebView _webView;

//   static const String url = 'https://firenoc.bihar.gov.in/website/';

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         // appBar: AppBar(
//         //   title: Text('InAppWebView Example'),
//         // ),
//         body: InAppWebView(
//           initialUrlRequest: URLRequest(url:  WebUri(url),),initialOptions: InAppWebViewGroupOptions(
//           android: AndroidInAppWebViewOptions(
//             textZoom: 75,
//             // Disable zooming on Android
//             builtInZoomControls: false,  // Disable built-in zoom controls
//             displayZoomControls: false,  // Hide zoom controls UI
//           ),
//           ios: IOSInAppWebViewOptions(
//             // Disable zooming on iOS
//             allowsInlineMediaPlayback: true,
//           ),
//         ),
//           shouldOverrideUrlLoading: (controller, navigationAction) async {
//             final url = navigationAction.request.url.toString();
      
//             // Identify footer links or specific URLs to open in the default browser
//             // For instance, you can check if the URL contains "contact-us" or "privacy-policy"
//             if (url.contains("contact-us") || url.contains("privacy-policy") || url.contains("terms-of-service")) {
//               // Check if the URL can be launched in the default browser
//               if (await canLaunch(url)) {
//                 // Launch the URL in the default browser
//                 await launch(url);
//               }
//               return NavigationActionPolicy.CANCEL; // Prevent WebView from loading this URL
//             }
      
//             // Allow WebView to load other URLs
//             return NavigationActionPolicy.ALLOW;
//           },
//           onWebViewCreated: (controller) {
//             _webViewController = controller;
//           },
//         ),
//       ),
//     );
//   }
// }

