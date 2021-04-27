import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:esense_flutter/esense.dart';
import 'package:esense_speaking_objects/video_screen.dart';
import 'package:esense_speaking_objects/widgets/esense_panel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import 'connection_manager.dart';
import 'widgets/connect_dialog.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ConnectionStatus _connectionStatus;
  String _error;
  StreamSubscription _connectionStream;
  ImagePicker _picker;

  @override
  void initState() {
    _picker = ImagePicker();
    _connectionStream = ESenseManager().connectionEvents.listen(
      (event) {
        switch (event.type) {
          case ConnectionType.connected:
            setState(() {
              _connectionStatus = ConnectionStatus.connected;
              _error = null;
            });
            break;
          case ConnectionType.disconnected:
          case ConnectionType.unknown:
            setState(() {
              _connectionStatus = ConnectionStatus.disconnected;
              _error = null;
            });
            break;
          case ConnectionType.device_found:
            break;
          case ConnectionType.device_not_found:
            setState(() {
              _connectionStatus = ConnectionStatus.disconnected;
              _error = "Device not found";
            });
            break;
        }
      },
    );

    super.initState();
  }

  @override
  void dispose() async {
    await _connectionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          title: Text("Tilted View"),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ESensePanel(
                color: _error != null
                    ? Colors.red
                    : _connectionStatus == ConnectionStatus.connected
                        ? Colors.green
                        : _connectionStatus == ConnectionStatus.disconnected
                            ? Colors.grey
                            : Colors.blue,
                text: _error != null
                    ? _error
                    : _connectionStatus == ConnectionStatus.connected
                        ? "Connected"
                        : _connectionStatus == ConnectionStatus.disconnected
                            ? "Not connected"
                            : "Connecting...",
                button: _connectionStatus == ConnectionStatus.connected
                    ? MaterialButton(
                        elevation: 0,
                        color: Colors.grey.shade700,
                        textColor: Colors.white,
                        child: IconText(
                            icon: Icons.bluetooth_disabled, text: "Disconnect"),
                        onPressed: () => ESenseManager().disconnect())
                    : MaterialButton(
                        elevation: 0,
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: _connectionStatus == ConnectionStatus.connecting
                            ? CircularProgressIndicator(
                                strokeWidth: 2,
                              )
                            : IconText(
                                icon: Icons.bluetooth, text: "Select earables"),
                        onPressed:
                            _connectionStatus == ConnectionStatus.connecting
                                ? null
                                : () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => ConnectDialog(
                                        callback: (name) {
                                          ESenseManager().connect(name);
                                          Navigator.of(context).pop();
                                          setState(() {
                                            _error = null;
                                            _connectionStatus =
                                                ConnectionStatus.connecting;
                                          });
                                        },
                                      ),
                                    );
                                  },
                      ),
              ),
              Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          "SAMPLE VIDEOS",
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      // SizedBox(height: 5),
                      Container(
                        height: 150,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (_, __) => SizedBox(width: 4),
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 1,
                                      offset: Offset(2, 2),
                                      spreadRadius: -4)
                                ],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                child: InkWell(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => VideoScreenContainer(
                                        controllerBuilder: () =>
                                            VideoPlayerController.asset(
                                                "assets/sampleVideos/Sample${index + 1}.mp4"),
                                      ),
                                    ),
                                  ),
                                  child: Image.asset(
                                    "assets/sampleVideos/Sample${index + 1}.png",
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: 6,
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Center(
                        child: MaterialButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: IconText(
                            text: "Select video from device",
                            icon: Icons.filter,
                          ),
                          onPressed: () async {
                            final vidSource = await _picker.getVideo(
                                source: ImageSource.gallery);
                            if (vidSource != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => VideoScreenContainer(
                                    controllerBuilder: () =>
                                        VideoPlayerController.file(
                                            File(vidSource.path)),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                  if (_connectionStatus != ConnectionStatus.connected)
                    Positioned.fill(
                      top: 5,
                      child: GestureDetector(
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                            child: Container(
                              color: Colors.transparent,
                              child: Center(
                                child: Text(
                                  "Connect to an eSense\nearable to play videos",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    backgroundColor: Colors.black54,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class IconText extends StatelessWidget {
  const IconText({
    Key key,
    this.text,
    this.icon,
  }) : super(key: key);

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
        ),
        SizedBox(
          width: 3,
        ),
        Text(text),
      ],
    );
  }
}
