import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

const String beeUri =
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

class VideoPage extends StatefulWidget {
  static const routeName = '/media/video';

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final connectedCompleter = Completer<Null>();
  bool isSupported = true;

  final butterfyController = VideoPlayerController.asset('videos/butterfly.mp4',
      package: 'flutter_gallery_assets');
  final beeController = VideoPlayerController.network(beeUri);

  @override
  void initState() {
    super.initState();
    _initController(butterfyController);
    _initController(beeController);
    isIOSSimulator().then((result) => isSupported = !result);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text('Videos'),
        ),
        body: isSupported
            ? ConnectivityOverlay(
                scaffoldKey: scaffoldKey,
                connectedCompleter: connectedCompleter,
                child: ListView(
                  children: <Widget>[
                    VideoCard(
                      title: 'Butterfly',
                      subtitle: '... flutter by',
                      controller: butterfyController,
                    ),
                    VideoCard(
                      title: 'Bee',
                      subtitle: '... gently buzzing',
                      controller: beeController,
                    ),
                  ],
                ),
              )
            : Center(
                child: Text(
                  'Video playback not supported on the iOS Simulator.',
                ),
              ),
      );

  @override
  void dispose() {
    butterfyController.dispose();
    beeController.dispose();
    super.dispose();
  }

  Future<Null> _initController(VideoPlayerController controller) async {
    controller.setLooping(true);
    controller.setVolume(0.0);
    controller.play();

    await connectedCompleter.future;
    await controller.initialize();
    setState(() {});
  }

  Future<bool> isIOSSimulator() async {
    return Platform.isIOS &&
        !(await DeviceInfoPlugin().iosInfo).isPhysicalDevice;
  }
}

class ConnectivityOverlay extends StatefulWidget {
  const ConnectivityOverlay({
    this.scaffoldKey,
    this.connectedCompleter,
    this.child,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final Completer<Null> connectedCompleter;
  final Widget child;

  @override
  _ConnectivityOverlayState createState() => _ConnectivityOverlayState();
}

class _ConnectivityOverlayState extends State<ConnectivityOverlay> {
  StreamSubscription<ConnectivityResult> connectivitySubscription;
  bool connected = true;

  @override
  void initState() {
    super.initState();
    connectivitySubscription =
        connectivityStream().listen((connectivityResult) {
      if (!mounted) return;
      if (connectivityResult == ConnectivityResult.none) {
        widget.scaffoldKey.currentState.showSnackBar(errorSnackBar);
      } else {
        if (!widget.connectedCompleter.isCompleted)
          widget.connectedCompleter.complete();
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    connectivitySubscription.cancel();
    super.dispose();
  }

  Stream<ConnectivityResult> connectivityStream() async* {
    final connectivity = Connectivity();
    var previousResult = await connectivity.checkConnectivity();
    yield previousResult;
    await for (var result in connectivity.onConnectivityChanged) {
      if (result != previousResult) {
        yield result;
        previousResult = result;
      }
    }
  }

  static const errorSnackBar = SnackBar(
    backgroundColor: Colors.red,
    content: ListTile(
      title: Text('No network'),
      subtitle: Text(
        'To load the videos you must have an active network connection',
      ),
    ),
  );
}

class VideoCard extends StatelessWidget {
  const VideoCard({
    this.title,
    this.subtitle,
    this.controller,
  });

  final String title;
  final String subtitle;
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        bottom: false,
        child: Card(
          child: Column(
            children: <Widget>[
              ListTile(title: Text(title), subtitle: Text(subtitle)),
              GestureDetector(
                onTap: () => _pushFullScreenWidget(context),
                child: _buildInlineVideo(),
              ),
            ],
          ),
        ),
      );

  Widget _buildInlineVideo() => Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
        child: Center(
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: Hero(
              tag: controller,
              child: VideoPlayerLoading(controller),
            ),
          ),
        ),
      );

  Widget _buildFullScreenVideo() => Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: Hero(
              tag: controller,
              child: VideoPlayPause(controller),
            ),
          ),
        ),
      );

  void _pushFullScreenWidget(BuildContext context) {
    final route = PageRouteBuilder<void>(
      settings: RouteSettings(name: title, isInitialRoute: false),
      pageBuilder: (context, animation, secondaryAnimation) =>
          _buildFullScreenVideo(),
    )..completed.then((result) => controller.setVolume(0.0));

    controller.setVolume(1.0);
    Navigator.of(context).push(route);
  }
}

class VideoPlayerLoading extends StatefulWidget {
  const VideoPlayerLoading(this.controller);

  final VideoPlayerController controller;

  @override
  _VideoPlayerLoadingState createState() => _VideoPlayerLoadingState();
}

class _VideoPlayerLoadingState extends State<VideoPlayerLoading> {
  bool _initialized;

  @override
  void initState() {
    super.initState();
    _initialized = widget.controller.value.initialized;
    widget.controller.addListener(() {
      if (!mounted) return;
      final controllerInitialized = widget.controller.value.initialized;
      if (_initialized != controllerInitialized) {
        setState(() {
          _initialized = controllerInitialized;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initialized) return VideoPlayer(widget.controller);
    return Stack(
      children: <Widget>[
        VideoPlayer(widget.controller),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class VideoPlayPause extends StatefulWidget {
  const VideoPlayPause(this.controller);

  final VideoPlayerController controller;

  @override
  _VideoPlayPauseState createState() => _VideoPlayPauseState();
}

class _VideoPlayPauseState extends State<VideoPlayPause> {
  FadeAnimation imageFadeAnimation;
  VoidCallback listener;

  _VideoPlayPauseState() {
    listener = () => setState(() {});
  }

  VideoPlayerController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.bottomCenter,
        fit: StackFit.expand,
        children: <Widget>[
          GestureDetector(
            child: VideoPlayerLoading(controller),
            onTap: () {
              if (!controller.value.initialized) return;
              if (controller.value.isPlaying) {
                imageFadeAnimation = const FadeAnimation(
                  child: Icon(Icons.pause, size: 100.0),
                );
                controller.pause();
              } else {
                imageFadeAnimation = const FadeAnimation(
                  child: Icon(Icons.play_arrow, size: 100.0),
                );
                controller.play();
              }
            },
          ),
          Center(child: imageFadeAnimation),
        ],
      );

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }
}

class FadeAnimation extends StatefulWidget {
  const FadeAnimation({
    @required this.child,
    this.duration: const Duration(milliseconds: 500),
  });

  final Widget child;
  final Duration duration;

  @override
  _FadeAnimationState createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      })
      ..forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) => animationController.isAnimating
      ? Opacity(
          opacity: 1.0 - animationController.value,
          child: widget.child,
        )
      : Container();

  @override
  void didUpdateWidget(FadeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child != oldWidget.child) animationController.forward(from: 0.0);
  }

  @override
  void deactivate() {
    animationController.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
