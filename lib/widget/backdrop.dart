import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const _kFrontHeadingHeight = 32.0;
const _kFrontClosedHeight = 92.0;
const _kBackAppBarHeight = 56.0;

final _kFrontHeadingBevelRadius = BorderRadiusTween(
  begin: BorderRadius.only(
    topLeft: Radius.circular(12.0),
    topRight: Radius.circular(12.0),
  ),
  end: BorderRadius.only(
    topLeft: Radius.circular(_kFrontHeadingHeight),
    topRight: Radius.circular(_kFrontHeadingHeight),
  ),
);

class Backdrop extends StatefulWidget {
  const Backdrop({
    this.frontAction,
    this.frontTitle,
    this.frontHeading,
    this.frontLayer,
    this.backTitle,
    this.backLayer,
  });

  final Widget frontAction;
  final Widget frontTitle;
  final Widget frontLayer;
  final Widget frontHeading;
  final Widget backTitle;
  final Widget backLayer;

  @override
  _BackdropState createState() => _BackdropState();
}

class _BackdropState extends State<Backdrop>
    with SingleTickerProviderStateMixin {
  final _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  AnimationController _controller;
  Animation<double> _frontOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      value: 1.0,
      vsync: this,
    );

    _frontOpacity = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: _buildStack);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    final frontRelativeRect = RelativeRectTween(
      begin: RelativeRect.fromLTRB(
          0.0, constraints.biggest.height - _kFrontClosedHeight, 0.0, 0.0),
      end: RelativeRect.fromLTRB(0.0, _kBackAppBarHeight, 0.0, 0.0),
    ).animate(_controller);

    final layers = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _BackAppBar(
            leading: widget.frontAction,
            title: _CrossFadeTransition(
              progress: _controller,
              alignment: AlignmentDirectional.centerStart,
              child0: Semantics(namesRoute: true, child: widget.frontTitle),
              child1: Semantics(namesRoute: true, child: widget.backTitle),
            ),
            trailing: IconButton(
              onPressed: _toggleFrontLayer,
              tooltip: 'Toggle options page',
              icon: AnimatedIcon(
                icon: AnimatedIcons.close_menu,
                progress: _controller,
              ),
            ),
          ),
          Expanded(
            child: _TappableWhileStatusls(
              AnimationStatus.dismissed,
              controller: _controller,
              child: widget.backLayer,
            ),
          ),
        ],
      ),
      PositionedTransition(
        rect: frontRelativeRect,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => PhysicalShape(
                elevation: 12.0,
                color: Theme.of(context).canvasColor,
                clipper: ShapeBorderClipper(
                  shape: BeveledRectangleBorder(
                    borderRadius:
                        _kFrontHeadingBevelRadius.lerp(_controller.value),
                  ),
                ),
                child: child,
              ),
          child: _TappableWhileStatusls(
            AnimationStatus.completed,
            controller: _controller,
            child: FadeTransition(
              opacity: _frontOpacity,
              child: widget.frontLayer,
            ),
          ),
        ),
      ),
    ];

    if (widget.frontHeading != null) {
      layers.add(
        PositionedTransition(
          rect: frontRelativeRect,
          child: ExcludeSemantics(
            child: Container(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleFrontLayer,
                onVerticalDragUpdate: _handlerDragUpdate,
                onVerticalDragEnd: _handlerDragEnd,
                child: widget.frontHeading,
              ),
            ),
          ),
        ),
      );
    }

    return Stack(children: layers);
  }

  double get _backdropHeight {
    final RenderBox renderBox = _backdropKey.currentContext.findRenderObject();
    return math.max(
        0.0, renderBox.size.height - _kBackAppBarHeight - _kFrontClosedHeight);
  }

  void _handlerDragUpdate(DragUpdateDetails details) {
    _controller.value -=
        details.primaryDelta / (_backdropHeight ?? details.primaryDelta);
  }

  void _handlerDragEnd(DragEndDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed) return;

    final flingVelocity = details.velocity.pixelsPerSecond.dy / _backdropHeight;
    if (flingVelocity < 0.0)
      _controller.fling(velocity: math.max(2.0, -flingVelocity));
    else if (flingVelocity > 0.0)
      _controller.fling(velocity: math.max(-2.0, -flingVelocity));
    else
      _controller.fling(velocity: _controller.value < 0.5 ? -2.0 : 2.0);
  }

  void _toggleFrontLayer() {
    final status = _controller.status;
    final isOpen = status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
    _controller.fling(velocity: isOpen ? -2.0 : 2.0);
  }
}

class _TappableWhileStatusls extends StatefulWidget {
  const _TappableWhileStatusls(
    this.status, {
    this.controller,
    this.child,
  });

  final AnimationController controller;
  final AnimationStatus status;
  final Widget child;

  @override
  __TappableWhileStatuslsState createState() => __TappableWhileStatuslsState();
}

class __TappableWhileStatuslsState extends State<_TappableWhileStatusls> {
  bool _active;

  @override
  void initState() {
    super.initState();
    widget.controller.addStatusListener(_handleStatusChange);
    _active = widget.controller.status == widget.status;
  }

  @override
  Widget build(BuildContext context) => AbsorbPointer(
        absorbing: !_active,
        child: IgnorePointer(
          ignoring: !_active,
          child: widget.child,
        ),
      );

  @override
  void dispose() {
    widget.controller.removeStatusListener(_handleStatusChange);
    super.dispose();
  }

  void _handleStatusChange(AnimationStatus status) {
    final value = widget.controller.status == widget.status;
    if (_active != value) setState(() => _active = value);
  }
}

class _CrossFadeTransition extends AnimatedWidget {
  const _CrossFadeTransition({
    this.alignment: Alignment.center,
    Animation<double> progress,
    this.child0,
    this.child1,
  }) : super(listenable: progress);

  final AlignmentGeometry alignment;
  final Widget child0;
  final Widget child1;

  @override
  Widget build(BuildContext context) {
    final Animation<double> progress = listenable;

    final opacity1 = CurvedAnimation(
      parent: ReverseAnimation(progress),
      curve: Interval(0.5, 1.0),
    ).value;

    final opacity2 = CurvedAnimation(
      parent: progress,
      curve: Interval(0.5, 1.0),
    ).value;

    return Stack(
      alignment: alignment,
      children: <Widget>[
        Opacity(
          opacity: opacity1,
          child: Semantics(
            scopesRoute: true,
            explicitChildNodes: true,
            child: child1,
          ),
        ),
        Opacity(
          opacity: opacity2,
          child: Semantics(
            scopesRoute: true,
            explicitChildNodes: true,
            child: child0,
          ),
        ),
      ],
    );
  }
}

class _BackAppBar extends StatelessWidget {
  const _BackAppBar({
    this.leading: const SizedBox(width: 56.0),
    @required this.title,
    this.trailing,
  })  : assert(leading != null),
        assert(title != null);

  final Widget leading;
  final Widget title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) => IconTheme.merge(
        data: Theme.of(context).primaryIconTheme,
        child: DefaultTextStyle(
          style: Theme.of(context).primaryTextTheme.title,
          child: SizedBox(
            height: _kBackAppBarHeight,
            child: Row(children: _buildChildren()),
          ),
        ),
      );

  List<Widget> _buildChildren() {
    final children = <Widget>[
      Container(
        alignment: Alignment.center,
        width: 56.0,
        child: leading,
      ),
      Expanded(
        child: title,
      ),
    ];

    if (trailing != null)
      children.add(
        Container(
          alignment: Alignment.center,
          width: 56.0,
          child: trailing,
        ),
      );

    return children;
  }
}
