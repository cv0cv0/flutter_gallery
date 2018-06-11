import 'package:flutter/material.dart';
import 'package:flutter_gallery/utils/updater.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  const App({
    this.updateUrlFetcher,
    this.enablePerformaceOverlay: true,
    this.enableRasterCacheImagesCheckerboard: true,
    this.enableOffscreenLayersCheckerboard: true,
    this.onSendFeedback,
  });

  final UpdateUrlFetcher updateUrlFetcher;
  final bool enablePerformaceOverlay;
  final bool enableRasterCacheImagesCheckerboard;
  final bool enableOffscreenLayersCheckerboard;
  final VoidCallback onSendFeedback;

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
  }
}
