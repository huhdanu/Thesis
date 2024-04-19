/* import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart'; */

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

/* class for devices */
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
      if (widget.title == 'FAN') {
        isActive ? print('FAN is active') : print('FAN is inactive');
      } else if (widget.title == 'LIGHT') {
        isActive ? print('LIGHT is active') : print('LIGHT is inactive');
      } else {
        isActive
            ? print('WATER CONTROL is active')
            : print('WATER CONTROL is inactive');
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

/* main class */
class TemperaturePage extends StatefulWidget {
  const TemperaturePage({Key? key}) : super(key: key);

  @override
  _TemperaturePage createState() => _TemperaturePage();
}

class _TemperaturePage extends State<TemperaturePage> {
  int dtemp = 40; // variable for temparature
  int dhum = 80; // variable for humidity

  int _dtemp = 0; // temp variable
  int _dhum = 0; // temp humidity

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
              'Do you want to set the value Threshold Humidity to ${newValue.toInt()}%?',
              style: const TextStyle(
                fontSize: 18,
              )),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  dhum = newValue.toInt();
                  // send to Firebase command
                });
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  dhum = _dhum;
                  // send to Firebase command
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
                        'KITCHEN',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        const SizedBox(width: 20),
                        _Circle(
                            title: 'Temparature', radiusValue: 140, value: 67),
                        const SizedBox(width: 35),
                        _Circle(title: 'Humidity', radiusValue: 140, value: 89),
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
                            max: 99,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('20\u00B0'),
                                Text('50\u00B0'),
                                Text('80\u00B0'),
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
                                  'THRESHOLD HUMIDITY',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$dhum%',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Slider(
                            value: dhum.toDouble(),
                            onChangeStart: (newValue) {
                              _dhum = dhum;
                            },
                            onChanged: (newValue) {
                              setState(() {
                                dhum = newValue.toInt();
                              });
                            },
                            onChangeEnd: (newValue) {
                              _showConfirmationDialogHum(newValue);
                            },
                            max: 99,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('33%'),
                                Text('66%'),
                                Text('99%'),
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
                        FanWidget(title: 'FAN'),
                        FanWidget(title: 'LIGHT'),
                        FanWidget(title: 'WATER'),
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
    return CircularPercentIndicator(
      radius: radiusValue.toDouble(),
      lineWidth: 14,
      percent: value / 100,
      progressColor: Colors.red,
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

class _Energy extends State<TemperaturePage> {
  double heating = 12;
  double fan = 15;
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
                        'BED ROOM',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        const SizedBox(width: 20),
                        _Circle(title: 'Temparature', value: 60),
                        const SizedBox(width: 80),
                        _Circle(title: 'Humidity', value: 15),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _roundedButton(title: 'Temparature', valueHori: 45),
                        _roundedButton(title: 'Humidity', valueHori: 60),
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
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'THRESHOLD TEMPERATURE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Slider(
                            value: heating,
                            onChanged: (newHeating) {
                              setState(() => heating = newHeating);
                            },
                            max: 30,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('20\u00B0'),
                                Text('50\u00B0'),
                                Text('80\u00B0'),
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
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'THRESHOLD HUMIDITY',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Slider(
                            value: fan,
                            onChanged: (newFan) {
                              setState(() => fan = newFan);
                            },
                            max: 30,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('33%'),
                                Text('66%'),
                                Text('99%'),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _fan(
                          title: 'FAN 1',
                          /* onTap: () {
                            (isActive == true)?(isActive == true):(isActive == false);
                        } */
                        ),
                        _fan(title: 'FAN 2', isActive: true),
                        _fan(title: 'FAN 3'),
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

  Widget _fan({
    required String title,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Image.asset(
            isActive ? 'assets/images/fan-2.png' : 'assets/images/fan-1.png',
          ),

          /* Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.black87 : Colors.black54,
          ),
        )), */
        ));
  }

  Widget _Circle({
    required String title,
    var value,
  }) {
    return CircularPercentIndicator(
      radius: 170,
      lineWidth: 14,
      percent: value / 100,
      progressColor: Colors.red,
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
          color: Colors.black45,
          fontSize: 20,
        ),
      ),
    ));
  }
}
