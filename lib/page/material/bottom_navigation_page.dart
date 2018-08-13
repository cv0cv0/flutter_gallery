import 'package:flutter/material.dart';

class BottomNavigationPage extends StatefulWidget {
  static const routeName = '/material/bottom_navigation';

  @override
  _BottomNavigationPageState createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage>
    with TickerProviderStateMixin {
  BottomNavigationBarType _type = BottomNavigationBarType.shifting;
  List<NavigationIconView> _navigationViews;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _navigationViews = [
      NavigationIconView(
        title: 'Alarm',
        icon: const Icon(Icons.access_alarm),
        color: Colors.deepPurple,
        vsync: this,
      ),
      NavigationIconView(
        title: 'Box',
        icon: BoxIcon(),
        color: Colors.deepOrange,
        vsync: this,
      ),
      NavigationIconView(
        title: 'Cloud',
        icon: const Icon(Icons.cloud),
        color: Colors.teal,
        vsync: this,
      ),
      NavigationIconView(
        title: 'Favorites',
        icon: const Icon(Icons.favorite),
        color: Colors.indigo,
        vsync: this,
      ),
      NavigationIconView(
        title: 'Event',
        icon: const Icon(Icons.event_available),
        color: Colors.pink,
        vsync: this,
      ),
    ];

    for (var view in _navigationViews) {
      view.controller.addListener(_rebuild);
    }

    _navigationViews[_currentIndex].controller.value = 1.0;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Bottom navigation'),
          actions: <Widget>[
            PopupMenuButton<BottomNavigationBarType>(
              onSelected: (type) => setState(() => _type = type),
              itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: BottomNavigationBarType.fixed,
                      child: Text('Fixed'),
                    ),
                    const PopupMenuItem(
                      value: BottomNavigationBarType.shifting,
                      child: Text('Shifting'),
                    ),
                  ],
            )
          ],
        ),
        body: Center(
          child: _buildTransitionStack(),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      );

  @override
  void dispose() {
    for (var view in _navigationViews) {
      view.controller.dispose();
    }
    super.dispose();
  }

  void _rebuild() => setState(() {
        // Rebuild in order to animate views.
      });

  Widget _buildTransitionStack() => Stack(
        children: _navigationViews
            .map((view) => view.transition(context, _type))
            .toList()
              ..sort((a, b) => a.opacity.value.compareTo(b.opacity.value)),
      );

  BottomNavigationBar _buildBottomNavigationBar() => BottomNavigationBar(
        type: _type,
        currentIndex: _currentIndex,
        items: _navigationViews.map((view) => view.item).toList(),
        onTap: (index) => setState(() {
              _navigationViews[_currentIndex].controller.reverse();
              _navigationViews[index].controller.forward();
              _currentIndex = index;
            }),
      );
}

class NavigationIconView {
  NavigationIconView({
    String title,
    Widget icon,
    Color color,
    TickerProvider vsync,
  })  : _title = title,
        _icon = icon,
        _color = color,
        item = BottomNavigationBarItem(
          title: Text(title),
          icon: icon,
          backgroundColor: color,
        ),
        controller = AnimationController(
          duration: kThemeAnimationDuration,
          vsync: vsync,
        ) {
    _animation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
  }

  final Widget _icon;
  final Color _color;
  final String _title;
  final BottomNavigationBarItem item;
  final AnimationController controller;
  CurvedAnimation _animation;

  FadeTransition transition(
      BuildContext context, BottomNavigationBarType type) {
    Color iconColor;
    if (type == BottomNavigationBarType.shifting) {
      iconColor = _color;
    } else {
      final theme = Theme.of(context);
      iconColor = theme.brightness == Brightness.light
          ? theme.primaryColor
          : theme.accentColor;
    }

    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0.0, 0.02),
          end: Offset.zero,
        ).animate(_animation),
        child: IconTheme(
          data: IconThemeData(
            color: iconColor,
            size: 120.0,
          ),
          child: Semantics(
            label: 'Placeholder for $_title tab',
            child: _icon,
          ),
        ),
      ),
    );
  }
}

class BoxIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    return Container(
      margin: const EdgeInsets.all(4.0),
      width: iconTheme.size - 8.0,
      height: iconTheme.size - 8.0,
      color: iconTheme.color,
    );
  }
}
