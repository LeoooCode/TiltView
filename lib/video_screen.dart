import 'dart:async';
import 'dart:math';

import 'package:esense_flutter/esense.dart';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:vector_math/vector_math_64.dart' as vec;
import 'package:video_player/video_player.dart';

class VideoScreenContainer extends StatelessWidget {
  const VideoScreenContainer({Key key, @required this.controllerBuilder})
      : super(key: key);

  final VideoPlayerController Function() controllerBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => VideoScreen(
                controllerBuilder: controllerBuilder, constraints: constraints),
          ),
        ),
      ),
    );
  }
}

class VideoScreen extends StatefulWidget {
  VideoScreen({Key key, this.controllerBuilder, this.constraints})
      : super(key: key);

  final VideoPlayerController Function() controllerBuilder;
  final BoxConstraints constraints;

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  double _deviceRoll = 0, _headRoll = 0;

  StreamSubscription _deviceSensorSubs;
  StreamSubscription _earableSensorSubs;

  bool _dangerMode = false, _paused = false;

  @override
  void initState() {
    _controller = widget.controllerBuilder();
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.play();

    _deviceSensorSubs = accelerometerEvents.listen((event) {
      setState(() {
        _deviceRoll = 0.8 * _deviceRoll + 0.2 * event.x / 10;
      });
    });

    _earableSensorSubs = ESenseManager().sensorEvents.listen((event) {
      setState(() {
        if ((event.gyro[1] / 65.5).abs() > 140) _dangerMode = true;
        final headPitch = event.accel[1] / 8192;
        if (_paused) {
          if (headPitch < -0.3) {
            _paused = false;
            _controller.play();
          }
        } else {
          if (headPitch > 0) {
            _paused = true;
            _controller.pause();
          }
        }
        _headRoll = 0.8 * _headRoll + 0.2 * (event.accel[2] / 8192);
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _deviceSensorSubs.cancel();
    _earableSensorSubs.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_dangerMode) {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 20,
            child: MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text("Continue"),
              onPressed: () {
                setState(() => (_dangerMode = false));
              },
            ),
          ),
          Center(child: Image.asset("assets/differentialGleichung.png")),
        ],
      );
    }

    final size = {
      "width": widget.constraints.maxWidth,
      "height": widget.constraints.maxHeight
    };
    var rotation = pi / 2 * (_deviceRoll + _headRoll);

    final orient = MediaQuery.of(context).orientation;
    if (orient == Orientation.landscape) {
      if (_deviceRoll > 0.4)
        rotation -= pi / 2;
      else if (_deviceRoll < -0.4) rotation += pi / 2;
    }

    final vec.Vector2 aspectRatioV = vec.Matrix2.rotation(-rotation) *
        vec.Vector2(_controller.value.aspectRatio, 1);
    final vec.Vector2 aspectRatioV2 = vec.Matrix2.rotation(-rotation) *
        vec.Vector2(-_controller.value.aspectRatio, 1);

    final scale = min(
      min(
        (size["width"] / aspectRatioV.x).abs(),
        (size["height"] / aspectRatioV.y).abs(),
      ),
      min(
        (size["width"] / aspectRatioV2.x).abs(),
        (size["height"] / aspectRatioV2.y).abs(),
      ),
    );

    final height = scale, width = _controller.value.aspectRatio * scale;

    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return AnimatedContainer(
                  transform: Matrix4.identity()
                    ..translate(width / 2, height / 2)
                    ..rotateZ(rotation)
                    ..translate(-width / 2, -height / 2),
                  duration: Duration(milliseconds: 70),
                  child: AnimatedContainer(
                    width: width,
                    height: height,
                    duration: Duration(milliseconds: 70),
                    child: VideoPlayer(_controller),
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        if (_paused)
          Center(
            child: FloatingActionButton(
              child: Icon(Icons.play_arrow_outlined),
              onPressed: () {
                setState(() {
                  _controller.play();
                  _paused = false;
                });
              },
            ),
          ),
        // Text(_deviceRoll.toString())
      ],
    );
  }
}
