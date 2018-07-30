import 'dart:async';

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

import 'package:url_launcher/url_launcher.dart';

import 'pages/home_page.dart';
import 'styles/themes.dart';
import 'utils/options.dart';
import 'utils/routes.dart';
import 'utils/scales.dart';
import 'utils/updater.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  const App({
    this.updateUrlFetcher,
    this.enablePerformaceOverlay: true,
    this.enableRasterCacheImagesCheckerboard: true,
    this.enableOffscreenLayersCheckerboard: true,
    this.onSendFeedback,
    this.testMode: false,
  });

  final UpdateUrlFetcher updateUrlFetcher;
  final bool enablePerformaceOverlay;
  final bool enableRasterCacheImagesCheckerboard;
  final bool enableOffscreenLayersCheckerboard;
  final VoidCallback onSendFeedback;
  final bool testMode;

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  Options _options;
  Timer _timeDilationTimer;

  @override
  void initState() {
    super.initState();
    _options = Options(
      theme: kLightGalleryTheme,
      textScaleFactor: kAllTextScaleValues[0],
      timeDilation: timeDilation,
      platform: defaultTargetPlatform,
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: _options.theme.data.copyWith(platform: _options.platform),
        title: 'Flutter Gallery',
        color: Colors.grey,
        showPerformanceOverlay: _options.showPerformanceOverlay,
        checkerboardOffscreenLayers: _options.showOffscreenLayersCheckerboard,
        checkerboardRasterCacheImages:
            _options.showRasterCacheImagesCheckerboard,
        routes: _buildRoutes(),
        builder: (context, child) => Directionality(
              textDirection: _options.textDirection,
              child: _applyTextScaleFactor(child),
            ),
        home: _buildHome(),
      );

  @override
  void dispose() {
    _timeDilationTimer?.cancel();
    _timeDilationTimer = null;
    super.dispose();
  }

  Map<String, WidgetBuilder> _buildRoutes() => Map.fromIterable(
        kAllRoutes,
        key: (route) => route.routeName,
        value: (route) => route.buildRoute,
      );

  Widget _applyTextScaleFactor(Widget child) => Builder(
        builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                    textScaleFactor: _options.textScaleFactor.scale,
                  ),
              child: child,
            ),
      );

  Widget _buildHome() {
    Widget home = HomePage(
      testMode: widget.testMode,
      optionsPage: OptionsPage(
        options: _options,
        onOptionsChanged: _handleOptionsChanged,
        onSendFeedback: widget.onSendFeedback ??
            () => launch('https://github.com/flutter/flutter/issues/new',
                forceSafariVC: false),
      ),
    );

    if (widget.updateUrlFetcher != null)
      home = Updater(
        updateUrlFetcher: widget.updateUrlFetcher,
        child: home,
      );

    return home;
  }

  void _handleOptionsChanged(Options newOptions) => setState(() {
        if (_options.timeDilation != newOptions.timeDilation) {
          _timeDilationTimer?.cancel();
          _timeDilationTimer = null;
          if (newOptions.timeDilation > 1.0)
            _timeDilationTimer = Timer(Duration(milliseconds: 150),
                () => timeDilation = newOptions.timeDilation);
          else
            timeDilation = newOptions.timeDilation;
        }

        _options = newOptions;
      });
}
