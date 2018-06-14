import 'package:flutter/material.dart';

import 'about.dart';
import 'scales.dart';
import '../styles/themes.dart';

class Options {
  Options({
    this.theme,
    this.textScaleFactor,
    this.textDirection: TextDirection.ltr,
    this.timeDilation: 1.0,
    this.platform,
    this.showPerformanceOverlay: false,
    this.showRasterCacheImagesCheckerboard: false,
    this.showOffscreenLayersCheckerboard: false,
  });

  final GalleryTheme theme;
  final TextScaleValue textScaleFactor;
  final TextDirection textDirection;
  final double timeDilation;
  final TargetPlatform platform;
  final bool showPerformanceOverlay;
  final bool showRasterCacheImagesCheckerboard;
  final bool showOffscreenLayersCheckerboard;

  Options copyWith({
    GalleryTheme theme,
    TextScaleValue textScaleFactor,
    TextDirection textDirection,
    double timeDilation,
    TargetPlatform platform,
    bool showPerformanceOverlay,
    bool showRasterCacheImagesCheckerboard,
    bool showOffscreenLayersCheckerboard,
  }) {
    return Options(
      theme: theme ?? this.theme,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      textDirection: textDirection ?? this.textDirection,
      timeDilation: timeDilation ?? this.timeDilation,
      platform: platform ?? this.platform,
      showPerformanceOverlay:
          showPerformanceOverlay ?? this.showPerformanceOverlay,
      showOffscreenLayersCheckerboard: showOffscreenLayersCheckerboard ??
          this.showOffscreenLayersCheckerboard,
      showRasterCacheImagesCheckerboard: showRasterCacheImagesCheckerboard ??
          this.showRasterCacheImagesCheckerboard,
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (runtimeType != other.runtimeType) return false;
    return theme == other.theme &&
        textScaleFactor == other.textScaleFactor &&
        textDirection == other.textDirection &&
        platform == other.platform &&
        showPerformanceOverlay == other.showPerformanceOverlay &&
        showRasterCacheImagesCheckerboard ==
            other.showRasterCacheImagesCheckerboard &&
        showOffscreenLayersCheckerboard ==
            other.showOffscreenLayersCheckerboard;
  }

  @override
  int get hashCode => hashValues(
        theme,
        textScaleFactor,
        textDirection,
        timeDilation,
        platform,
        showPerformanceOverlay,
        showRasterCacheImagesCheckerboard,
        showOffscreenLayersCheckerboard,
      );

  @override
  String toString() {
    return '$runtimeType($theme)';
  }
}

class OptionsPage extends StatelessWidget {
  const OptionsPage({
    this.options,
    this.onOptionsChanged,
    this.onSendFeedback,
  });

  final Options options;
  final ValueChanged<Options> onOptionsChanged;
  final VoidCallback onSendFeedback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTextStyle(
      style: theme.primaryTextTheme.subhead,
      child: ListView(
        padding: EdgeInsets.only(bottom: 124.0),
        children: <Widget>[
          _Heading('Display'),
          _ThemeItem(options, onOptionsChanged),
          _TextScaleFactorItem(options, onOptionsChanged),
          _TextDirectionItem(options, onOptionsChanged),
          _TimeDilationItem(options, onOptionsChanged),
          Divider(),
          _Heading('Platform mechanics'),
          _PlatformItem(options, onOptionsChanged),
        ]
          ..addAll(
            _enabledDiagnosticItems(),
          )
          ..addAll(
            <Widget>[
              Divider(),
              _Heading('Flutter gallery'),
              _ActionItem('About Flutter Gallery', () {
                showGalleryAboutDialog(context);
              }),
              _ActionItem('Send feedback', onSendFeedback),
            ],
          ),
      ),
    );
  }

  List<Widget> _enabledDiagnosticItems() {
    if (options.showOffscreenLayersCheckerboard ??
        options.showRasterCacheImagesCheckerboard ??
        options.showPerformanceOverlay == null) return const <Widget>[];

    final items = <Widget>[
      const Divider(),
      const _Heading('Diagnostics'),
    ];

    if (options.showOffscreenLayersCheckerboard != null) {
      items.add(
        _BooleanItem(
          'Highlight offscreen layers',
          options.showOffscreenLayersCheckerboard,
          (value) => onOptionsChanged(
                options.copyWith(showOffscreenLayersCheckerboard: value),
              ),
        ),
      );
    }
    if (options.showRasterCacheImagesCheckerboard != null) {
      items.add(
        _BooleanItem(
          'Highlight raster cache images',
          options.showRasterCacheImagesCheckerboard,
          (value) => onOptionsChanged(
                options.copyWith(showRasterCacheImagesCheckerboard: value),
              ),
        ),
      );
    }
    if (options.showPerformanceOverlay != null) {
      items.add(
        _BooleanItem(
          'Show performance overlay',
          options.showPerformanceOverlay,
          (value) => onOptionsChanged(
                options.copyWith(showPerformanceOverlay: value),
              ),
        ),
      );
    }

    return items;
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem(this.text, this.onTap);

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _OptionsItem(
        child: _FlatButton(
          onPressed: onTap,
          child: Text(text),
        ),
      );
}

class _FlatButton extends StatelessWidget {
  const _FlatButton({this.onPressed, this.child});

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => FlatButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: DefaultTextStyle(
          style: Theme.of(context).primaryTextTheme.subhead,
          child: child,
        ),
      );
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _OptionsItem(
      child: DefaultTextStyle(
        style: theme.textTheme.body1.copyWith(
          fontFamily: 'GoogleSans',
          color: theme.accentColor,
        ),
        child: Semantics(
          child: Text(text),
          header: true,
        ),
      ),
    );
  }
}

class _ThemeItem extends StatelessWidget {
  const _ThemeItem(this.options, this.onOptionsChanged);

  final Options options;
  final ValueChanged<Options> onOptionsChanged;

  @override
  Widget build(BuildContext context) => _BooleanItem(
        'Dark Theme',
        options.theme == kDarkGalleryTheme,
        (value) => onOptionsChanged(
              options.copyWith(
                theme: value ? kDarkGalleryTheme : kLightGalleryTheme,
              ),
            ),
      );
}

class _TextScaleFactorItem extends StatelessWidget {
  const _TextScaleFactorItem(this.options, this.onOptionsChanged);

  final Options options;
  final ValueChanged<Options> onOptionsChanged;

  @override
  Widget build(BuildContext context) => _OptionsItem(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Text size'),
                  Text(
                    '${options.textScaleFactor.label}',
                    style: Theme.of(context).primaryTextTheme.body1,
                  ),
                ],
              ),
            ),
            PopupMenuButton<TextScaleValue>(
              padding: EdgeInsetsDirectional.only(end: 16.0),
              icon: Icon(Icons.arrow_drop_down),
              itemBuilder: (context) => kAllTextScaleValues
                  .map(
                    (scaleValue) => PopupMenuItem<TextScaleValue>(
                          value: scaleValue,
                          child: Text(scaleValue.label),
                        ),
                  )
                  .toList(),
              onSelected: (scaleValue) => onOptionsChanged(
                    options.copyWith(textScaleFactor: scaleValue),
                  ),
            ),
          ],
        ),
      );
}

class _TextDirectionItem extends StatelessWidget {
  const _TextDirectionItem(this.options, this.onOptionsChanged);

  final Options options;
  final ValueChanged<Options> onOptionsChanged;

  @override
  Widget build(BuildContext context) => _BooleanItem(
        'Force RTL',
        options.textDirection == TextDirection.rtl,
        (value) => onOptionsChanged(
              options.copyWith(
                textDirection: value ? TextDirection.rtl : TextDirection.ltr,
              ),
            ),
      );
}

class _TimeDilationItem extends StatelessWidget {
  const _TimeDilationItem(this.options, this.onOptionsChanged);

  final Options options;
  final ValueChanged<Options> onOptionsChanged;

  @override
  Widget build(BuildContext context) => _BooleanItem(
        'Slow motion',
        options.timeDilation != 1.0,
        (value) => onOptionsChanged(
              options.copyWith(
                timeDilation: value ? 20.0 : 1.0,
              ),
            ),
      );
}

class _PlatformItem extends StatelessWidget {
  const _PlatformItem(this.options, this.onOptionsChanged);

  final Options options;
  final ValueChanged<Options> onOptionsChanged;

  @override
  Widget build(BuildContext context) => _OptionsItem(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Platform mechanics'),
                  Text(
                    '${_platformLabel(options.platform)}',
                    style: Theme.of(context).primaryTextTheme.body1,
                  ),
                ],
              ),
            ),
            PopupMenuButton<TargetPlatform>(
              padding: EdgeInsetsDirectional.only(end: 16.0),
              icon: Icon(Icons.arrow_drop_down),
              itemBuilder: (context) => TargetPlatform.values
                  .map(
                    (platform) => PopupMenuItem(
                          value: platform,
                          child: Text(_platformLabel(platform)),
                        ),
                  )
                  .toList(),
              onSelected: (platform) => onOptionsChanged(
                    options.copyWith(platform: platform),
                  ),
            ),
          ],
        ),
      );

  String _platformLabel(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.android:
        return 'Mountain View';
      case TargetPlatform.fuchsia:
        return 'Fuchsia';
      case TargetPlatform.iOS:
        return 'Cupertino';
    }
    assert(false);
    return null;
  }
}

const _kItemHeight = 48.0;
const _kItemPadding = EdgeInsetsDirectional.only(start: 56.0);

class _OptionsItem extends StatelessWidget {
  const _OptionsItem({this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    return MergeSemantics(
      child: Container(
        constraints: BoxConstraints(minHeight: _kItemHeight * textScaleFactor),
        padding: _kItemPadding,
        alignment: AlignmentDirectional.centerStart,
        child: DefaultTextStyle(
          style: DefaultTextStyle.of(context).style,
          maxLines: 2,
          overflow: TextOverflow.fade,
          child: IconTheme(
            data: Theme.of(context).primaryIconTheme,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _BooleanItem extends StatelessWidget {
  const _BooleanItem(this.title, this.value, this.onChanged);

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _OptionsItem(
      child: Row(
        children: <Widget>[
          Expanded(child: Text(title)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFF39CEFD),
            activeTrackColor: isDark ? Colors.white30 : Colors.black26,
          ),
        ],
      ),
    );
  }
}
