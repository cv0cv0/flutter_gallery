import 'package:flutter/material.dart';

final kDarkGalleryTheme = GalleryTheme._('Dark', _buildDarkTheme());
final kLightGalleryTheme = GalleryTheme._('Light', _buildLightTheme());

ThemeData _buildDarkTheme() {
  const primaryColor = Color(0xFF0175C2);
  final base = ThemeData.dark();
  return base.copyWith(
    primaryColor: primaryColor,
    buttonColor: primaryColor,
    indicatorColor: Colors.white,
    accentColor: Color(0xFF13B9FD),
    canvasColor: Color(0xFF202124),
    scaffoldBackgroundColor: Color(0xFF202124),
    backgroundColor: Color(0xFF202124),
    errorColor: Color(0xFFB00020),
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: _buildTextTheme(base.textTheme),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildTextTheme(base.accentTextTheme),
  );
}

ThemeData _buildLightTheme() {
  const primaryColor = Color(0xFF0175C2);
  final base = ThemeData.light();
  return base.copyWith(
    primaryColor: primaryColor,
    buttonColor: primaryColor,
    indicatorColor: Colors.white,
    splashColor: Colors.white24,
    splashFactory: InkRipple.splashFactory,
    accentColor: Color(0xFF13B9FD),
    canvasColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    backgroundColor: Colors.white,
    errorColor: Color(0xFFB00020),
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: _buildTextTheme(base.textTheme),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildTextTheme(base.accentTextTheme),
  );
}

TextTheme _buildTextTheme(TextTheme base) {
  return base.copyWith(
    title: base.title.copyWith(
      fontFamily: 'GoogleSans',
    ),
  );
}

class GalleryTheme {
  const GalleryTheme._(this.name, this.data);

  final String name;
  final ThemeData data;
}
