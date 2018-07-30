import 'package:flutter/material.dart';

import 'icons.dart';

final kAllRoutes = _buildRoutes();

final kAllRouteCategorys = kAllRoutes.map((route) => route.category).toSet();

final kRouteCategoryToRoutes = Map.fromIterable(
  kAllRouteCategorys,
  value: (category) =>
      kAllRoutes.where((route) => route.category == category).toList(),
);

List<GalleryRoute> _buildRoutes() {
  //TODO
}

const _kStudies = RouteCategory._(
  name: 'Studies',
  icon: GalleryIcons.animation,
);

const _kStyle = RouteCategory._(
  name: 'Style',
  icon: GalleryIcons.custom_typography,
);

const _kMaterial = RouteCategory._(
  name: 'Material',
  icon: GalleryIcons.category_mdc,
);

const _kCupertino = RouteCategory._(
  name: 'Cupertino',
  icon: GalleryIcons.phone_iphone,
);

const _kMedia = RouteCategory._(
  name: 'Media',
  icon: GalleryIcons.drive_video,
);

class GalleryRoute {
  const GalleryRoute({
    @required this.title,
    @required this.icon,
    this.subtitle,
    @required this.category,
    @required this.routeName,
    @required this.buildRoute,
  })  : assert(title != null),
        assert(category != null),
        assert(routeName != null),
        assert(buildRoute != null);

  final String title;
  final IconData icon;
  final String subtitle;
  final RouteCategory category;
  final String routeName;
  final WidgetBuilder buildRoute;

  @override
  String toString() {
    return '$runtimeType($title $routeName)';
  }
}

class RouteCategory {
  const RouteCategory._({@required this.name, @required this.icon});

  final String name;
  final IconData icon;

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    return name == other.name && icon == other.icon;
  }

  @override
  int get hashCode => hashValues(name, icon);

  @override
  String toString() {
    return '$runtimeType($name)';
  }
}
