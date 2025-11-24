import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class GameTable3d extends StatefulWidget {
  const GameTable3d({Key? key}) : super(key: key);

  @override
  GameTable3dState createState() => GameTable3dState();
}

class GameTable3dState extends State<GameTable3d> {
  InAppWebViewController? _webViewController;

  void resetScene() {
    _webViewController?.evaluateJavascript(source: 'resetScene();');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.black),
        InAppWebView(
          initialFile: 'assets/web/index.html',
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          onConsoleMessage: (controller, consoleMessage) {
            if (kDebugMode) {
              print('WebView Console: [${consoleMessage.messageLevel}] ${consoleMessage.message}');
            }
          },
          // These options make the WebView background transparent
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              transparentBackground: true,
            ),
          ),
          initialSettings: InAppWebViewSettings(
            mediaPlaybackRequiresUserGesture: false,
            useHybridComposition: true,
          ),
        ),
      ],
    );
  }
}
