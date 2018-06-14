import 'package:flutter/material.dart';

import 'icons.dart';

final List<Routes> kAllRoutes = _buildRoutes();

final kAllCategorys = kAllRoutes.map((route) => route.category).toSet();

final kCategoryToRoutes = Map.fromIterable(
  kAllCategorys,
  value: (category) =>
      kAllRoutes.where((route) => route.category == category).toList(),
);

List<Routes> _buildRoutes() {
  //TODO
}

const _kStudies = Category._(
  name: 'Studies',
  icon: GalleryIcons.animation,
);

const _kStyle = Category._(
  name: 'Style',
  icon: GalleryIcons.custom_typography,
);

const _kMaterial = Category._(
  name: 'Material',
  icon: GalleryIcons.category_mdc,
);

const _kCupertino = Category._(
  name: 'Cupertino',
  icon: GalleryIcons.phone_iphone,
);

const _kMedia = Category._(
  name: 'Media',
  icon: GalleryIcons.drive_video,
);

class Routes {
  const Routes({
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
  final Category category;
  final String routeName;
  final WidgetBuilder buildRoute;

  @override
  String toString() {
    return '$runtimeType($title $routeName)';
  }
}

class Category {
  const Category._({@required this.name, @required this.icon});

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
