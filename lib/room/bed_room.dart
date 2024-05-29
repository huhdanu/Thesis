import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; /* for count time */

import 'package:flutter_smart_home/camera.dart'; // camera template
import 'package:flutter_smart_home/dtb/dtb_bedroom.dart'; // database template
//import 'package:flutter_smart_home/dtb/dtb_kitchen.dart'; // database template

class Bedroom extends StatefulWidget {
  const Bedroom({Key? key}) : super(key: key);

  @override
  _Bedroom createState() => _Bedroom();
}

class FanWidget extends StatefulWidget {
  final String title;

  const FanWidget({Key? key, required this.title}) : super(key: key);

  @override
  _FanWidgetState createState() => _FanWidgetState();
}

class _FanWidgetState extends State<FanWidget> {
  String dataALARMDetect = '0', dataLAMPDetect = '0', dataPUMPDetect = '0';
  bool isActive = false;
  String Option = "true";

  @override
  void initState() {
    super.initState();
    readOPTION.onValue.listen(
      (event) {
        if (mounted) {
          setState(() {
            Option = event.snapshot.value.toString();
            print(Option);
          });
        }
      },
    );
  }

  final DatabaseReference deviceALARM =
      FirebaseDatabase.instance.ref('Room1/DEVICES').child('Alarm');

  final DatabaseReference deviceLAMP =
      FirebaseDatabase.instance.ref('Room1/DEVICES').child('Lamp');

  final DatabaseReference devicePUMP = FirebaseDatabase.instance.ref('Pump');

  final DatabaseReference detectActiveALARM =
      FirebaseDatabase.instance.ref('ACTIVE/IsAlarmActiveRoom1');

  final DatabaseReference detectActiveLAMP =
      FirebaseDatabase.instance.ref('ACTIVE/IsLampActiveRoom1');

  final DatabaseReference detectActivePUMP =
      FirebaseDatabase.instance.ref('ACTIVE/IsPumpActive');

  final DatabaseReference readOPTION = FirebaseDatabase.instance.ref('OPTION');

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
      deviceLAMP.onValue.listen(
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

  void _showConfirmationDialog(BuildContext context) {
    String _title = widget.title;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Center(
                child: Text('Confirm'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black, // Optional: Set text color
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              'You want to set $_title, it will be switched to ',
                        ),
                        const TextSpan(
                          text: 'AUTO mode?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // set optione in firebase
                    readOPTION.set(false);
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void toggleDevice() {
    readOPTION.onValue.listen(
      (event) {
        if (mounted) {
          setState(() {
            Option = event.snapshot.value.toString();
          });
        }
      },
    );
    setState(() {
      if (Option == "true") {
        (_showConfirmationDialog(context));
      } else {
        isActive = !isActive;
      }

      if (widget.title == 'ALARM') {
        isActive ? deviceALARM.set(true) : deviceALARM.set(false);
      } else if (widget.title == 'LAMP') {
        isActive ? deviceLAMP.set(true) : deviceLAMP.set(false);
      } else {
        isActive ? devicePUMP.set(1) : devicePUMP.set(0);
      }
    });
  }

  void getStateActive() {
    if (widget.title == 'ALARM') {
      detectActiveALARM.onValue.listen(
        (event) {
          if (mounted) {
            setState(() {
              dataALARMDetect = event.snapshot.value.toString();
            });
          }
        },
      );
    } else if (widget.title == 'LAMP') {
      detectActiveLAMP.onValue.listen(
        (event) {
          if (mounted) {
            setState(() {
              dataLAMPDetect = event.snapshot.value.toString();
            });
          }
        },
      );
    } else {
      detectActivePUMP.onValue.listen(
        (event) {
          if (mounted) {
            setState(() {
              dataPUMPDetect = event.snapshot.value.toString();
            });
          }
        },
      );
    }
  }

  Color returnColor() {
    getStateActive();
    if (!isActive) {
      return Colors.white;
    } else {
      if (widget.title == 'ALARM') {
        int data = int.parse(dataALARMDetect);
        return (data == 1) ? (Colors.green) : (Colors.grey);
      } else {}
      if (widget.title == 'LAMP') {
        int data = int.parse(dataLAMPDetect);
        return (data == 1) ? (Colors.green) : (Colors.grey);
      } else {
        int data = int.parse(dataPUMPDetect);
        return (data == 1) ? (Colors.green) : (Colors.grey);
      }
    }
  }

  Widget getImage() {
    if (widget.title == 'ALARM') {
      return Image.asset(
        isActive ? 'assets/images/alarm_on.png' : 'assets/images/alarm_off.png',
        width: 40,
        height: 40,
      );
    } else if (widget.title == 'LAMP') {
      return Image.asset(
        isActive ? 'assets/images/light_on.png' : 'assets/images/light_off.png',
        width: 40,
        height: 40,
      );
    } else {
      return Image.asset(
        isActive ? 'assets/images/pump_on.png' : 'assets/images/pump_off.png',
        width: 40,
        height: 40,
      );
    }
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
              color: returnColor(),
              borderRadius: BorderRadius.circular(18),
            ),
            child: getImage(),
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

class SwitchWidget extends StatefulWidget {
  @override
  _SwitchWidgetState createState() => _SwitchWidgetState();
}

class _SwitchWidgetState extends State<SwitchWidget> {
  bool _isSwitched = false;
  bool _previousSwitchState = false;

  final DatabaseReference readOPTION = FirebaseDatabase.instance.ref('OPTION');
  void _toggleSwitch(bool value) {
    setState(() {
      _isSwitched = value;
      // send mode to firebase
      _isSwitched ? (readOPTION.set(false)) : (readOPTION.set(true));
    });
  }

  @override
  void initState() {
    super.initState();
    readOPTION.onValue.listen(
      (event) {
        if (mounted) {
          setState(() {
            String option = event.snapshot.value.toString();
            if (option != "true") {
              // manual mode
              _isSwitched = true;
            } else {
              // auto mode
              _isSwitched = false;
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    /* get data TEMP threshold */
    readOPTION.onValue.listen(
      (event) {
        if (mounted) {
          setState(() {
            String option = event.snapshot.value.toString();
            /* switch be show ON is auto mode */
            if (option != "true") {
              // manual mode
              _isSwitched = true;
            } else {
              // auto mode
              _isSwitched = false;
            }
          });
        }
      },
    );
    return Row(
      children: [
        Switch(
          value: _isSwitched,
          onChanged: (value) {
            _previousSwitchState = _isSwitched;
            _toggleSwitch(value);
          },
        ),
        const SizedBox(
          width: 20,
        ),
        Text(
          (_isSwitched) ? 'AUTO' : 'MANUAL',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _Bedroom extends State<Bedroom> with WidgetsBindingObserver {
  int _dtemp = 0; // temp variable
  int _dgas = 0; // temp humidity

  /* variable for get data from Firebase */
  int tempVal = 0;
  int gasVal = 0;
  int gasThreshold = 30;
  int tempThreshold = 20;
  bool flagSendData = false;

  bool _sliderChangingGAS = false;
  bool _sliderChangingTEMP = false;

  /* syntax for CRUD data in Realtime database */
  final DatabaseReference databaseTEMP =
      FirebaseDatabase.instance.ref('Room1/SENSORS').child('Temperature');

  void sendGasToFireStore(String fieldName, int value) {
    Map<String, dynamic> userData = {
      fieldName: value,
    };

    FirebaseFirestore.instance.collection('ROOM 1').doc('GAS').update(userData);
  }

  void sendTempToFireStore(String fieldName, int value) {
    Map<String, dynamic> userData = {
      fieldName: value,
    };

    FirebaseFirestore.instance
        .collection('ROOM 1')
        .doc('TEMP')
        .update(userData);
  }

  final DatabaseReference databaseGAS =
      FirebaseDatabase.instance.ref('Room1/SENSORS').child('Gas');

  final DatabaseReference databaseGASThreshold =
      FirebaseDatabase.instance.ref('Room1/SETTINGS').child('Gas Threshold');

  final DatabaseReference databaseTEMPThreshold = FirebaseDatabase.instance
      .ref('Room1/SETTINGS')
      .child('Temperature Threshold');

  void showPasswordDialogTEMP(double newValue) {
    String enteredPassword = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextFormField(
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            onChanged: (value) {
              enteredPassword = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();

                if (enteredPassword == '123123') {
                  setState(() {
                    tempThreshold = newValue.toInt();
                    // send to Firebase
                    databaseTEMPThreshold.set((tempThreshold).toInt());
                  });
                } else {
                  // Incorrect password
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect password!'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

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
                showPasswordDialogTEMP(newValue);
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

  Future<void> fetchDocumentFromFirestore(String day) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('ROOM 1').doc('GAS').get();
    String date;

    if (documentSnapshot.exists) {
      for (int i = 15; i < 16; i++) {
        for (int j = 0; j < 60; j++) {
          date =
              "$day-${i.toString().padLeft(2, '0')}:${j.toString().padLeft(2, '0')}";
          int? field1 = documentSnapshot[date];
          if (field1 != null) {
            print('$date: $field1');
          }
        }
      }
    } else {
      print('Document does not exist');
    }
  }

  /* function for confirm when user want to change data GAS threshold */
  void _showConfirmationDialogGAS(double newValue) {
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
              'Do you want to set the value of Threshold Gas to ${newValue.toInt()}%?',
              style: const TextStyle(
                fontSize: 18,
              )),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                showPasswordDialogGAS(newValue);
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

  void showPasswordDialogGAS(double newValue) {
    String enteredPassword = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextFormField(
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            onChanged: (value) {
              enteredPassword = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                if (enteredPassword == '123123') {
                  setState(() {
                    gasThreshold = newValue.toInt();
                    // send to Firebase
                    databaseGASThreshold.set((gasThreshold).toInt());
                  });
                } else {
                  // Incorrect password
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect password!'),
                    ),
                  );
                }
              },
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
            int tempVala = 0;
            var a = (event.snapshot.value);
            if (a is int) {
              tempVala = a;
            } else if (a is double) {
              tempVala = a.floor();
            }
            String temp_ = tempVala.toString();
            tempVal = int.parse(temp_);
          });
        }
      },
    );

    /* get data for HUM sensor */
    databaseGAS.onValue.listen(
      (event) {
        if (mounted) {
          setState(() {
            int gasVala = 0;
            var a = event.snapshot.value;
            if (a is int) {
              gasVala = a;
            } else if (a is double) {
              gasVala = a.floor();
            }
            String gasVal_ = gasVala.toString();
            gasVal = int.parse(gasVal_);
          });
        }
      },
    );

    /* get data GAS threshold */
    databaseGASThreshold.onValue.listen(
      (event) {
        if (!_sliderChangingGAS) {
          if (mounted) {
            setState(() {
              String gasThrehold_ = event.snapshot.value.toString();
              gasThreshold = int.parse(gasThrehold_);
            });
          }
        }
      },
    );

    /* get data TEMP threshold */
    databaseTEMPThreshold.onValue.listen(
      (event) {
        if (!_sliderChangingTEMP) {
          if (mounted) {
            setState(() {
              String tempThrehold_ = event.snapshot.value.toString();
              tempThreshold = int.parse(tempThrehold_);
            });
          }
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
                  const Text(
                    'BEDROOM',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Camera()),
                      );
                    },
                    child: const Icon(
                      Icons.video_camera_back_outlined,
                      color: Colors.black,
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
                          title: 'Gas',
                          radiusValue: 70,
                          value: gasVal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _roundedButton(title: 'Temperature', valueHori: 30),
                        _roundedButton(title: 'Gas', valueHori: 75),
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
                              _sliderChangingTEMP = true;
                            },
                            onChanged: (newValue) {
                              setState(() {
                                tempThreshold = newValue.toInt();
                                _sliderChangingTEMP = true;
                              });
                            },
                            onChangeEnd: (newValue) {
                              _showConfirmationDialogTemp(newValue);
                              _sliderChangingTEMP = false;
                            },
                            max: 99,
                            min: 10,
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
                                  '$gasThreshold %',
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
                              _sliderChangingGAS = true;
                            },
                            onChanged: (newValue) {
                              setState(() {
                                gasThreshold = newValue.toInt();
                                _sliderChangingGAS = true;
                              });
                            },
                            onChangeEnd: (newValue) {
                              gasThreshold = newValue.toInt();
                              _showConfirmationDialogGAS(newValue);
                              _sliderChangingGAS = false;
                            },
                            max: 99,
                            min: 10,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('10%'),
                                Text('50%'),
                                Text('99%'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SwitchWidget(),
                    const SizedBox(height: 15),
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

    String getText() {
      if (title == 'Temparature') {
        return value.toString() + '\u00B0';
      } else {
        return value.toString() + '%';
      }
    }

    return GestureDetector(
      onTap: () {
        if (title == 'Temparature') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Database(
                      typeShow: title,
                    )),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Database(
                      typeShow: title,
                    )),
          );
        }
      },
      child: CircularPercentIndicator(
        radius: radiusValue.toDouble(),
        lineWidth: 14,
        percent: value / 100,
        backgroundColor: Colors.grey,
        linearGradient: gradient,
        center: Text(
          getText(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _roundedButton({
    required String title,
    required double valueHori,
  }) {
    return GestureDetector(
        onTap: () {
          if (title == "Temperature") {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Database(typeShow: title)),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Database(typeShow: title)),
            );
          }
        },
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
