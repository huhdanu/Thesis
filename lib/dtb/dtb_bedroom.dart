import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
/* import 'dart:math'; */
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; /* for count time */

class Database extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Database> {
  String selectedDate = "";
  bool isSelected = false;
  bool isShow = false;
  String? dataShow = "";

  void handleDataSelectedData(String? data) {
    setState(() {
      dataShow = data;
      isShow = true;
    });
  }

  /* declare variable for function get one day */
  String stringToShow = "";

  void _showDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024, 4, 1),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        DateTime strReceive = pickedDate;
        selectedDate = formattedDate(strReceive);
        stringToShow = formattedToShow(strReceive);
        isSelected = true;
      });
    }
  }

  String formattedDate(DateTime date) {
    return DateFormat('yyyy.MM.dd').format(date);
  }

  String formattedToShow(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  /* declare variable for function get range day */
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isNotInRange(DateTime day) {
    return _startDate != null &&
        _endDate != null &&
        !day.isAtSameMomentAs(_startDate!) &&
        !day.isAtSameMomentAs(_endDate!) &&
        !day.isAfter(_startDate!) &&
        !day.isBefore(_endDate!);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2024, 4, 1),
      lastDate: DateTime.now(),
      selectableDayPredicate: (day) =>
          _startDate == null || _endDate == null || !_isNotInRange(day),
    );
    if (pickedStartDate != null) {
      final DateTime? pickedEndDate = await showDatePicker(
        context: context,
        initialDate: _endDate ?? pickedStartDate,
        firstDate: pickedStartDate,
        lastDate: DateTime.now(),
        selectableDayPredicate: (day) =>
            _startDate == null || _endDate == null || !_isNotInRange(day),
      );
      if (pickedEndDate != null) {
        final daysInRange = pickedEndDate.difference(pickedStartDate).inDays;
        if (daysInRange > 30) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text(
                  'Please select a date range of no more than 30 days.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          setState(() {
            _startDate = pickedStartDate;
            _endDate = pickedEndDate;
            String a = formattedToShow(_startDate!);
            String b = formattedToShow(_endDate!);
            stringToShow = '$a - $b';
          });
        }
      }
    }
  }

  /*  */
  Color getDotColor(FlSpot spot) {
    if (spot.y > 60) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    const SizedBox(height: 20),
                    Row(children: [
                      const SizedBox(width: 20),
                      MyButton(onSelectOption: handleDataSelectedData),
                      const SizedBox(width: 150),
                      /*  DatePickerWidget(onDateSelected: handleDataSelectedDay), */
                      PopupMenuButton(
                        icon: const Icon(Icons.calendar_month),
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem(
                            child: Text('Select day'),
                            value: 'Option 1',
                          ),
                          const PopupMenuItem(
                            child: Text('Select range day'),
                            value: 'Option 2',
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'Option 1') {
                            _showDatePicker();
                          } else if (value == 'Option 2') {
                            _selectDateRange(context);
                          }
                        },
                      ),
                    ]),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        stringToShow,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                        child: Align(
                            alignment: Alignment.center,
                            child: LineChartWidget(
                                days: selectedDate,
                                acceptToDraw: isSelected & isShow,
                                dataBeShown: dataShow))),
                  ],
                ))));
  }
}

/* Widget for select data which be shown */
class MyButton extends StatefulWidget {
  final void Function(String?) onSelectOption;
  const MyButton({required this.onSelectOption});

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  String? _selectedOption;
  List<String>? _options = ['Gas', 'Temp'];

  @override
  Widget build(BuildContext context) {
    if (_options == null || _options!.isEmpty) {
      return const Center(
        child: Text('No options available'),
      );
    }

    return DropdownButton<String>(
      value: _selectedOption,
      hint: const Text('Select data'),
      onChanged: (String? newValue) {
        setState(() {
          _selectedOption = newValue;
        });
        widget.onSelectOption(_selectedOption);
      },
      items: _options!.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

/*  */
class LineChartWidget extends StatelessWidget {
  final int numberOfPoints = 25;
  final double chartMinY = 0;
  final double chartMaxY = 100;
  final int dotThreshold = 35;

  String days = "";
  String? dataBeShown = "";
  bool acceptToDraw = true;
  LineChartWidget(
      {required this.days,
      required this.acceptToDraw,
      required this.dataBeShown});

  Future<int> readGasFromFireStore(String date, int hour, int min) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('ROOM 1').doc('GAS').get();
    int value = 0;
    late String fieldName;

    if (documentSnapshot.exists) {
      fieldName =
          "$date-${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}";
      value = documentSnapshot[fieldName];
    }
    return value;
  }

  Future<int> readTempFromFireStore(String date, int hour, int min) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('ROOM 1').doc('TEMP').get();
    int value = 0;
    late String fieldName;

    if (documentSnapshot.exists) {
      fieldName =
          "$date-${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}";
      value = documentSnapshot[fieldName];
    }
    return value;
  }

  /* return value after read value 30 times in Fire Store */
  Future<int> returnValueGasAverage(String date, int hour, int min) async {
    int sum = 0;
    for (int i = min; i < min + 30; i = i + 2) {
      int valueFromFireStore = await readGasFromFireStore(date, hour, i);
      sum = sum + valueFromFireStore;
    }
    print((sum ~/ 15).toInt());
    return (sum ~/ 15).toInt();
  }

  Future<List<FlSpot>> generateGasSpots() async {
    List<FlSpot> spots = [];

    double hour = 0;
    double min = 0;
    int valueBeDraw = 40;

    for (int i = 0; i < 48; i++) {
      /* if (hour < 11) {
        int getValue =
            await readGasFromFireStore(days, hour.toInt(), min.toInt());
        if (getValue > 100) {
          valueBeDraw = getValue ~/ 100;
        }
      } else if (hour < 18) {
        valueBeDraw = 78;
      } else {
        valueBeDraw = 38;
      } */

      int getValue =
          await readGasFromFireStore(days, hour.toInt(), min.toInt());
      if (getValue > 100) {
        valueBeDraw = getValue % 100;
      } else {
        valueBeDraw = getValue;
      }
      double a = valueBeDraw.toDouble();
      double xValue = hour + min / 60;
      spots.add(FlSpot(xValue, a));
      min += 30;
      if (min >= 60) {
        hour++;
        min = 0;
      }
    }

    return spots;
  }

  Future<List<FlSpot>> generateTempSpots() async {
    List<FlSpot> spots = [];

    double hour = 0;
    double min = 0;
    int valueBeDraw = 40;

    for (int i = 0; i < 48; i++) {
      if (hour < 5) {
        int getValue =
            await readTempFromFireStore(days, hour.toInt(), min.toInt());
        if (getValue > 100) {
          valueBeDraw = getValue ~/ 100;
        }
      } else if (hour < 14) {
        valueBeDraw = 20;
      } else {
        valueBeDraw = 67;
      }
      double a = valueBeDraw.toDouble();
      double xValue = hour + min / 60;
      spots.add(FlSpot(xValue, a));
      min += 30;
      if (min >= 60) {
        hour++;
        min = 0;
      }
    }

    return spots;
  }

  Future<List<FlSpot>> selectDataBeShown() async {
    if (dataBeShown == 'Gas') {
      return generateGasSpots();
    } else if (dataBeShown == 'Temp') {
      return generateTempSpots();
    } else {
      return [];
    }
  }

  bool showSpot() {
    if (spot.y > 60) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (acceptToDraw == true) {
      return Stack(
        children: [
          FutureBuilder<List<FlSpot>>(
            future: selectDataBeShown(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  width: 100,
                  height: 100,
                  child: const CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<FlSpot> spots = snapshot.data!;
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    height: 500,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            //isCurved: true,
                            color: Colors.blue,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(show: false),
                            dotData: const FlDotData(
                              show: true,
                            ),
                          )
                        ],
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        minX: 0,
                        maxX: 25 - 1,
                        minY: 0,
                        maxY: 100,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }
}
