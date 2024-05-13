import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:gesture_zoom_box/gesture_zoom_box.dart';
import 'package:intl/intl.dart';
import 'dart:async';

/* void main() {
  runApp(const MyApp());
}
 */
class Camera extends StatelessWidget {
  const Camera({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(
        channel: IOWebSocketChannel.connect('ws://172.20.10.2:8888'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final WebSocketChannel channel;
  MyHomePage({Key? key, required this.channel}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final videoWidth = 680;
  final videoHeight = 480;

  double newVideoSizeWidth = 640;
  double newVideoSizeHeight = 480;

  bool isLandscape = false;
  String _timeString = '0';

  @override
  void initState() {
    super.initState();
    isLandscape = false;
    _timeString = _formatDatetime(DateTime.now());
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  String _formatDatetime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy hh:mm:ss aaa').format(dateTime);
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    if (mounted) {
      setState(() {
        _timeString = _formatDatetime(now);
      });
    }
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          var screenWidth = MediaQuery.of(context).size.width;
          var screenHeight = MediaQuery.of(context).size.height;

          if (orientation == Orientation.portrait) {
            isLandscape = false;
            newVideoSizeWidth = (screenWidth > videoWidth)
                ? videoWidth.toDouble()
                : screenWidth.toDouble();
            newVideoSizeHeight = videoHeight * newVideoSizeHeight / videoWidth;
          } else {
            isLandscape = false;
            newVideoSizeHeight = (screenHeight > videoHeight)
                ? videoHeight.toDouble()
                : screenHeight.toDouble();
            newVideoSizeWidth = videoWidth * newVideoSizeHeight / videoHeight;
          }

          return Scaffold(
              body: SafeArea(
            child: Container(
              color: Colors.white,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 50),
                        const Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'BEDROOM',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Expanded(
                      child: StreamBuilder(
                          stream: widget.channel.stream,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              );
                            } else {
                              return Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: isLandscape ? 0 : 20,
                                  ),
                                  Stack(
                                    children: <Widget>[
                                      GestureZoomBox(
                                        maxScale: 5.0,
                                        doubleTapScale: 2.0,
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: Image.memory(
                                          snapshot.data,
                                          gaplessPlayback: true,
                                        ),
                                      ),
                                      Positioned.fill(
                                          child: Align(
                                        child: Column(
                                          children: <Widget>[
                                            const SizedBox(
                                              height: 16,
                                            ),
                                            const Text(
                                              'ESP32\'s CAM',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              'Live | $_timeString',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                        alignment: Alignment.topCenter,
                                      )),
                                    ],
                                  ),
                                  /* Expanded(
                              flex: 1,
                              child: Container(
                                color: Colors.black,
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    IconButton(
                                        icon: Icon(Icons.photo_camera, size: 24))
                                  ],
                                ),
                              ),
                            ) */
                                ],
                              );
                            }
                          }),
                    )
                  ]),
            ),
          ));
        },
      ),
    );
  }
}
