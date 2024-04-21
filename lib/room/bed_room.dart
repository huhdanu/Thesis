/* import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart'; */

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:firebase_database/firebase_database.dart';

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

  final DatabaseReference deviceALARM =
      FirebaseDatabase.instance.ref('Room1/DEVICES').child('Alarm');

  final DatabaseReference deviceLARM =
      FirebaseDatabase.instance.ref('Room1/DEVICES').child('Lamp');

  final DatabaseReference devicePUMP = FirebaseDatabase.instance.ref('Pump');

  void getStateDevices() {
    if (widget.title == 'ALARM') {
      deviceALARM.onValue.listen(
        (event) {
          if (mounted) {
            setState(() {
              String receiveData = event.snapshot.value.toString();
              bool alarm = bool.parse(receiveData);
              (alarm == true) ? (isActive = true) : (isActive = false);
            });
          }
        },
      );
    } else if (widget.title == 'LAMP') {
      deviceLARM.onValue.listen(
        (event) {
          if (mounted) {
            setState(() {
              String receiveData = event.snapshot.value.toString();
              bool lamp = bool.parse(receiveData);
              (lamp == true) ? (isActive = true) : (isActive = false);
            });
          }
        },
      );
    } else {
      devicePUMP.onValue.listen(
        (event) {
          if (mounted) {
            setState(() {
              String receiveData = event.snapshot.value.toString();
              int pump = int.parse(receiveData);
              (pump == 1) ? (isActive = true) : (isActive = false);
            });
          }
        },
      );
    }
  }

  void toggleDevice() {
    setState(() {
      isActive = !isActive;
      if (widget.title == 'ALARM') {
        isActive ? deviceALARM.set(true) : deviceALARM.set(false);
      } else if (widget.title == 'LAMP') {
        isActive ? deviceLARM.set(true) : deviceLARM.set(false);
      } else {
        isActive ? devicePUMP.set(true) : devicePUMP.set(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    getStateDevices();

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
  int _dtemp = 0; // temp variable
  int _dgas = 0; // temp humidity

  /* variable for get data from Firebase */
  int tempVal = 0;
  int humVal = 0;
  int gasThreshold = 30;
  int tempThreshold = 20;
  bool flagSendData = false;

  /*  */
  final DatabaseReference databaseTEMP =
      FirebaseDatabase.instance.ref('Room1/SENSORS').child('Temperature');

  final DatabaseReference databaseHUM =
      FirebaseDatabase.instance.ref('Room1/SENSORS').child('Humidity');

  final DatabaseReference databaseGASThreshold =
      FirebaseDatabase.instance.ref('Room1/SETTINGS').child('Gas Threshold');

  final DatabaseReference databaseTEMPThreshold = FirebaseDatabase.instance
      .ref('Room1/SETTINGS')
      .child('Temperature Threshold');

  /* function for confirm when user want to change data TEMP threshold */
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
              'Do you want to set the value of Threshold Temparature to ${newValue.toInt()}°C?',
              style: const TextStyle(
                fontSize: 18,
              )),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  tempThreshold = newValue.toInt();
                  /* send data */
                  databaseTEMPThreshold.set(tempThreshold);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  tempThreshold = _dtemp;
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

  /* function for confirm when user want to change data GAS threshold */
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
              'Do you want to set the value of Threshold Gas to ${newValue.toInt()}ppm?',
              style: const TextStyle(
                fontSize: 18,
              )),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  gasThreshold = newValue.toInt();
                  // send to Firebase
                  databaseGASThreshold.set((gasThreshold ~/ 100).toInt());
                });
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  gasThreshold = _dgas;
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
    /* get data for TEMP sensor */
    databaseTEMP.onValue.listen(
      (event) {
        if (mounted) {
          setState(() {
            String temp_ = event.snapshot.value.toString();
            tempVal = int.parse(temp_);
          });
        }
      },
    );

    /* get data for HUM sensor */
    databaseHUM.onValue.listen(
      (event) {
        if (mounted) {
          setState(() {
            String humVal_ = event.snapshot.value.toString();
            humVal = int.parse(humVal_);
          });
        }
      },
    );

    /* get data GAS threshold */
    databaseGASThreshold.onValue.listen(
      (event) {
        if (mounted) {
          setState(() {
            String gasThrehold_ = event.snapshot.value.toString();
            gasThreshold = int.parse(gasThrehold_);
          });
        }
      },
    );

    /* get data TEMP threshold */
    databaseTEMPThreshold.onValue.listen(
      (event) {
        if (mounted) {
          setState(() {
            String tempThrehold_ = event.snapshot.value.toString();
            tempThreshold = int.parse(tempThrehold_);
          });
        }
      },
    );

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
                        circle(
                          title: 'Temparature',
                          radiusValue: 70,
                          value: tempVal,
                        ),
                        const SizedBox(width: 35),
                        circle(
                          title: 'Humidity',
                          radiusValue: 70,
                          value: humVal,
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
                                  '$tempThreshold°C',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Slider(
                            value: tempThreshold.toDouble(),
                            onChangeStart: (newValue) {
                              _dtemp = tempThreshold;
                            },
                            onChanged: (newValue) {
                              setState(() {
                                tempThreshold = newValue.toInt();
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
                                Text('10°C'),
                                Text('50°C'),
                                Text('99°C'),
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
                                  '$gasThreshold ppm',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Slider(
                            value: (gasThreshold.toDouble()),
                            onChangeStart: (newValue) {
                              _dgas = gasThreshold;
                            },
                            onChanged: (newValue) {
                              setState(() {
                                gasThreshold = newValue.toInt();
                              });
                            },
                            onChangeEnd: (newValue) {
                              _showConfirmationDialogHum(newValue);
                            },
                            max: 100,
                            min: 5,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('5ppm'),
                                Text('55ppm'),
                                Text('99ppm'),
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
                        FanWidget(title: 'ALARM'),
                        FanWidget(title: 'LAMP'),
                        FanWidget(title: 'PUMP'),
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

  Widget circle({
    required String title,
    required int radiusValue,
    var value,
  }) {
    List<Color> gradientColors = [
      Colors.green,
      const Color.fromARGB(255, 232, 6, 6),
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
