import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class GameTable3d extends StatefulWidget {
  const GameTable3d({super.key});

  @override
  State<GameTable3d> createState() => _GameTable3dState();
}

class _GameTable3dState extends State<GameTable3d> {
  InAppWebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialFile: 'assets/web/index.html',
      onWebViewCreated: (controller) {
        _webViewController = controller;
      },
      initialSettings: InAppWebViewSettings(
        mediaPlaybackRequiresUserGesture: false,
        useHybridComposition: true,
      ),
    );
  }
}
