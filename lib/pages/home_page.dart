import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'backdrop.dart';
import '../utils/routes.dart';

const String _kAssetsPackage = 'flutter_gallery_assets';
const Color _kFlutterBlue = const Color(0xFF003D75);
const double _kItemHeight = 64.0;
const Duration _kFrontLayerSwitchDuration = const Duration(milliseconds: 300);

class HomePage extends StatefulWidget {
  static bool showPreviewBanner = true;

  const HomePage({this.testMode: false, @required this.optionsPage});

  final bool testMode;
  final Widget optionsPage;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static final _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController _controller;
  RouteCategory _category;

  static Widget _topHomeLayout(
      Widget currentChild, List<Widget> previousChildren) {
    if (currentChild != null) previousChildren.add(currentChild);
    return Stack(
      children: previousChildren,
      alignment: Alignment.topCenter,
    );
  }

  static const AnimatedSwitcherLayoutBuilder _centerHomeLayout =
      AnimatedSwitcher.defaultLayoutBuilder;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600),
      debugLabel: 'preview banner',
      vsync: this,
    )..forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final media = MediaQuery.of(context);
    final centerHome =
        media.orientation == Orientation.portrait && media.size.height < 800.0;

    const switchCurve = const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn);

    Widget home = Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? _kFlutterBlue : theme.primaryColor,
      body: SafeArea(
        bottom: false,
        child: WillPopScope(
          onWillPop: () {
            if (_category != null) {
              setState(() => _category = null);
              return Future<bool>.value(false);
            }
            return Future<bool>.value(true);
          },
          child: Backdrop(
            backTitle: Text('Options'),
            backLayer: AnimatedSwitcher(
              duration: _kFrontLayerSwitchDuration,
              switchOutCurve: switchCurve,
              switchInCurve: switchCurve,
              child: _category == null
                  ? _FlutterLogo()
                  : IconButton(
                      icon: BackButtonIcon(),
                      tooltip: 'Back',
                      onPressed: () => setState(() => _category = null),
                    ),
            ),
            frontTitle: AnimatedSwitcher(
              duration: _kFrontLayerSwitchDuration,
              child: _category == null
                  ? Text('Flutter gallery')
                  : Text(_category.name),
            ),
            frontHeading: widget.testMode ? null : Container(height: 24.0),
            frontLayer: AnimatedSwitcher(
              duration: _kFrontLayerSwitchDuration,
              switchOutCurve: switchCurve,
              switchInCurve: switchCurve,
              layoutBuilder: centerHome ? _centerHomeLayout : _topHomeLayout,
              child: _category != null
                  ? _RoutesPage(_category)
                  : _CategoriesPage(
                      categories: kAllRouteCategorys,
                      onCategoryTop: (category) =>
                          setState(() => _category = category),
                    ),
            ),
          ),
        ),
      ),
    );

    assert(() {
      HomePage.showPreviewBanner = false;
      return true;
    }());

    if (HomePage.showPreviewBanner) {
      home=Stack(
        fit: StackFit.expand,
        children: <Widget>[
          home,
          FadeTransition(
            opacity: CurvedAnimation(parent: _controller,curve: Curves.easeInOut),
            child: Banner(
              message: 'PREVIEW',
              location: BannerLocation.topEnd,
            ),
          ),
        ],
      );
    }

    return home;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _FlutterLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 34.0,
          height: 34.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image:
                  AssetImage('white_logo/logo.png', package: _kAssetsPackage),
            ),
          ),
        ),
      );
}

class _RoutesPage extends StatelessWidget {
  const _RoutesPage(this.category);

  final RouteCategory category;

  @override
  Widget build(BuildContext context) => KeyedSubtree(
        key: ValueKey('RouteList'),
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          label: category.name,
          explicitChildNodes: true,
          child: ListView(
            key: PageStorageKey(category.name),
            padding: EdgeInsets.only(top: 8.0),
            children: kRouteCategoryToRoutes[category]
                .map((route) => _RouteItem(route: route))
                .toList(),
          ),
        ),
      );
}

class _RouteItem extends StatelessWidget {
  const _RouteItem({this.route});

  final GalleryRoute route;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);

    final titleChildren = <Widget>[
      Text(
        route.title,
        style: theme.textTheme.body1.copyWith(
          color: isDark ? Colors.white : Color(0xFF202124),
        ),
      ),
    ];
    if (route.subtitle != null) {
      titleChildren.add(
        Text(
          route.subtitle,
          style: theme.textTheme.body1.copyWith(
            color: isDark ? Colors.white : Color(0xFF60646B),
          ),
        ),
      );
    }

    return RawMaterialButton(
      padding: EdgeInsets.zero,
      splashColor: theme.primaryColor.withOpacity(0.12),
      highlightColor: Colors.transparent,
      onPressed: () => _launchRoute(context),
      child: Container(
        constraints: BoxConstraints(minHeight: _kItemHeight * textScaleFactor),
        child: Row(
          children: <Widget>[
            Container(
              width: 56.0,
              height: 56.0,
              alignment: Alignment.center,
              child: Icon(
                route.icon,
                size: 24.0,
                color: isDark ? Colors.white : _kFlutterBlue,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: titleChildren,
              ),
            ),
            SizedBox(width: 44.0),
          ],
        ),
      ),
    );
  }

  void _launchRoute(BuildContext context) {
    if (route.routeName != null) {
      Timeline.instantSync('Start Transition', arguments: <String, String>{
        'from': '/',
        'to': route.routeName,
      });
      Navigator.of(context).pushNamed(route.routeName);
    }
  }
}

class _CategoriesPage extends StatelessWidget {
  const _CategoriesPage({
    this.categories,
    this.onCategoryTop,
  });

  final Iterable<RouteCategory> categories;
  final ValueChanged<RouteCategory> onCategoryTop;

  @override
  Widget build(BuildContext context) {
    const aspectRatio = 160.0 / 180.0;
    final categoriesList = categories.toList();
    final columnCount =
        MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 3;

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: 'categories',
      explicitChildNodes: true,
      child: SingleChildScrollView(
        key: PageStorageKey('categories'),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columnWidth = constraints.biggest.width / columnCount;
            final rowHeight = math.min(225.0, columnWidth * aspectRatio);
            final rowCount =
                (categories.length + columnCount - 1) ~/ columnCount;

            return RepaintBoundary(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List<Widget>.generate(rowCount, (rowIndex) {
                  final columnCountForRow = rowIndex == rowCount - 1
                      ? categories.length -
                          columnCount +
                          math.max(0, rowCount - 1)
                      : columnCount;

                  return Row(
                    children:
                        List<Widget>.generate(columnCountForRow, (columnIndex) {
                      final index = rowIndex * columnCount + columnIndex;
                      final category = categoriesList[index];

                      return SizedBox(
                        width: columnWidth,
                        height: rowHeight,
                        child: _CategoryItem(
                          category: category,
                          onTap: () => onCategoryTop(category),
                        ),
                      );
                    }),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    this.category,
    this.onTap,
  });

  final RouteCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RepaintBoundary(
      child: RawMaterialButton(
        padding: EdgeInsets.zero,
        splashColor: theme.primaryColor.withOpacity(0.12),
        highlightColor: Colors.transparent,
        onPressed: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(6.0),
              child: Icon(
                category.icon,
                size: 60.0,
                color: isDark ? Colors.white : _kFlutterBlue,
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              height: 48.0,
              alignment: Alignment.center,
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.subhead.copyWith(
                  fontFamily: 'GoogleSans',
                  color: isDark ? Colors.white : _kFlutterBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
