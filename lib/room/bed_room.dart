/* import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart'; */

//import 'dart:math';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class Energy extends StatefulWidget {
  const Energy({Key? key}) : super(key: key);

  @override
  _Energy createState() => _Energy();
}

class FanWidget extends StatefulWidget {
  final String title;

  const FanWidget({Key? key, required this.title}) : super(key: key);

  @override
  _FanWidgetState createState() => _FanWidgetState();
}

class _FanWidgetState extends State<FanWidget> {
  bool isActive = false;

  void toggleDevice() {
    setState(() {
      isActive = !isActive;
      if (widget.title == 'BELL') {
        isActive ? print('BELL is active') : print('BELL is inactive');
      } else if (widget.title == 'LIGHT') {
        isActive ? print('LIGHT is active') : print('LIGHT is inactive');
      } else {
        isActive
            ? print('WATER PUMPS is active')
            : print('WATER PUMPS is inactive');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        toggleDevice();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Image.asset(
              isActive ? 'assets/images/fan-2.png' : 'assets/images/fan-1.png',
            ),
          ),
          const SizedBox(height: 15),
          Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _Energy extends State<Energy> {
  int dtemp = 69; // variable for temparature
  int dgas = 4579; // variable for humidity

  int _dtemp = 0; // temp variable
  int _dgas = 0; // temp humidity

  void _showConfirmationDialogTemp(double newValue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              )),
          content: Text(
              'Do you want to set the value Threshold Temparature to ${newValue.toInt()}°C?',
              style: const TextStyle(
                fontSize: 18,
              )),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  dtemp = newValue.toInt();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  dtemp = _dtemp;
                });
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialogHum(double newValue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              )),
          content: Text(
              'Do you want to set the value Threshold Gas to ${newValue.toInt()}ppm?',
              style: const TextStyle(
                fontSize: 18,
              )),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  dgas = newValue.toInt();
                  // send to Firebase
                });
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  dgas = _dgas;
                  // send to Firebase
                });
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 18, left: 24, right: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 21),
                        _Circle(
                          title: 'Temparature',
                          radiusValue: 70,
                          value: 77,
                        ),
                        const SizedBox(width: 35),
                        _Circle(
                          title: 'Humidity',
                          radiusValue: 70,
                          value: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _roundedButton(title: 'Temparature', valueHori: 30),
                        _roundedButton(title: 'Humidity', valueHori: 40),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'THRESHOLD TEMPERATURE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$dtemp°C',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Slider(
                            value: dtemp.toDouble(),
                            onChangeStart: (newValue) {
                              _dtemp = dtemp;
                            },
                            onChanged: (newValue) {
                              setState(() {
                                dtemp = newValue.toInt();
                              });
                            },
                            onChangeEnd: (newValue) {
                              _showConfirmationDialogTemp(newValue);
                            },
                            max: 90,
                            min: 20,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('20°C'),
                                Text('50°C'),
                                Text('90°C'),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'THRESHOLD GAS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$dgas ppm',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Slider(
                            value: dgas.toDouble(),
                            onChangeStart: (newValue) {
                              _dgas = dgas;
                            },
                            onChanged: (newValue) {
                              setState(() {
                                dgas = newValue.toInt();
                              });
                            },
                            onChangeEnd: (newValue) {
                              _showConfirmationDialogHum(newValue);
                            },
                            max: 9000,
                            min: 3000,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('3000ppm'),
                                Text('6000ppm'),
                                Text('9000ppm'),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FanWidget(title: 'BELL'),
                        FanWidget(title: 'LIGHT'),
                        FanWidget(title: 'WATER PUMPS'),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _Circle({
    required String title,
    required int radiusValue,
    var value,
  }) {
    List<Color> gradientColors = [
      Colors.green,
      Color.fromARGB(255, 232, 6, 6),
    ];

    double ratio;
    double colorIndex;

    if (value <= 45) {
      ratio = (value - 20) / (46 - 20);
      colorIndex = ((gradientColors.length - 1) * ratio);
    } else {
      ratio = (value - 45) / (100 - 45);
      colorIndex = 0;
    }

    colorIndex = ((gradientColors.length - 1) * ratio);

    Color beginColor = gradientColors[colorIndex.toInt()];
    Color endColor = gradientColors[colorIndex.toInt() + 1];

    // Create a linear gradient
    LinearGradient gradient = LinearGradient(
      colors: [beginColor, endColor],
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
    );

    /* Color color;

    if (value <= 38) {
      color = Colors.green; 
    } else if (value < 50) {
      color = Colors.yellow; 
    } else {
      color = Colors.red; 
    } */

    return CircularPercentIndicator(
      radius: radiusValue.toDouble(),
      lineWidth: 14,
      percent: value / 100,
      backgroundColor: Colors.grey, // Set background color to show the gradient
      linearGradient: gradient, // Set linearGradient to the created gradient
      //progressColor: color,
      center: Text(
        value.toString() + '\u00B0', // assign from value to string in Dart
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _roundedButton({
    required String title,
    required double valueHori,
  }) {
    return GestureDetector(
        child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: valueHori,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.pink,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));
  }
}
