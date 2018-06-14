import 'dart:async';

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

import 'package:url_launcher/url_launcher.dart';

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
  Widget build(BuildContext context) {
    // TODO: implement build
  }

  @override
  void dispose() {
    _timeDilationTimer?.cancel();
    _timeDilationTimer = null;
    super.dispose();
  }

  Map<String, WidgetBuilder> _buildRoutes() => Map.fromIterable(
        kAllRoutes,
        key: (route) => '${route.routeName}',
        value: (route) => route.buildRoute,
      );

  void _handleOptionsChanged(Options newOptions) => setState(() {
        if (_options.timeDilation != newOptions.textDirection) {
          _timeDilationTimer?.cancel();
          _timeDilationTimer = null;
          if (newOptions.timeDilation > 1.0)
            _timeDilationTimer = Timer(Duration(milliseconds: 150),
                () => timeDilation = newOptions.timeDilation);
        }

        _options = newOptions;
      });

      Widget _applyTextScaleFactor(Widget child)=>Builder(
        builder: (context)=>MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: _options.textScaleFactor.scale,
          ),
          child: child,
        ),
      );
}
