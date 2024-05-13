import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
/* import 'dart:math'; */
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; /* for count time */

class Database extends StatefulWidget {
  String dataShow = "";
  Database({required this.dataShow});

  @override
  _MyAppState createState() => _MyAppState(dataShow: dataShow);
}

class _MyAppState extends State<Database> {
  String selectedDate = "2024.05.08";
  /* declare variable for function get one day */
  String stringToShow = "History in 08.05.2024";

  String dataShow = "";
  _MyAppState({required this.dataShow});
  /*============== variable for select day or range of day===================
  * false: showing data of day
  * true: showing data in range of day 
  ======================================================================== */
  bool selectType = false;

  /* variable for range of day */
  String startDay = "";
  String endDay = "";

/*   void handleDataSelectedData(String? data) {
    setState(() {
      dataShow = data;
    });
  } */

  /* ====================================== func to click select one day ==================================== */
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
        String a = formattedToShow(strReceive);
        if (dataShow == "Gas") {
          stringToShow = "History of Gas in $a";
        } else {
          stringToShow = "History of Tempareture in $a";
        }
        selectType = false;
      });
    }
  }

  /* ====================================== func format data date ==================================== */
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
            selectType = true; // which be day or range of day

            _startDate = pickedStartDate;
            _endDate = pickedEndDate;

            DateTime startDay_ = pickedStartDate;
            DateTime endDate_ = pickedEndDate;

            startDay = formattedDate(startDay_);
            endDay = formattedDate(endDate_);
            print("start is: $startDay");
            print("end is: $endDay");

            String a = formattedToShow(_startDate!);
            String b = formattedToShow(_endDate!);
            if (dataShow == "Gas") {
              stringToShow = 'History of Gas from $a to $b';
            } else {
              stringToShow = 'History of Temperature from $a to $b';
            }
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
                      ],
                    ),
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
                              isDayOrMonth: selectType,
                              days: selectedDate,
                              dataBeShown: dataShow,
                              startDay: startDay,
                              endDay: endDay,
                            ))),
                  ],
                ))));
  }
}

/*  */
class LineChartWidget extends StatelessWidget {
  final int numberOfPoints = 25;
  final double chartMinY = 0;
  final double chartMaxY = 100;
  final int dotThreshold = 35;

  /* variable for select range day */
  String startDay = "";
  String endDay = "";

  String days = "";
  String? dataBeShown = "";

  bool isDayOrMonth = false;
  LineChartWidget(
      {required this.isDayOrMonth,
      required this.days,
      required this.dataBeShown,
      required this.startDay,
      required this.endDay});

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

  Future<List<FlSpot>> generateGasSpots() async {
    List<FlSpot> spots = [];

    double hour = 0;
    double min = 0;
    int valueBeDraw = 40;

    for (int i = 0; i < 48; i++) {
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

  /* func to return value of day */
  int returnDayOfMonth(String str) {
    int month = int.parse(str[5]) * 10 + int.parse(str[6]);
    if (month == 2) {
      return 28;
    } else if (month == 1 ||
        month == 3 ||
        month == 5 ||
        month == 7 ||
        month == 8 ||
        month == 10 ||
        month == 12) {
      return 31;
    } else {
      return 30;
    }
  }

  /* ========================================= return month of string ======================================= */
  int monthOfStr(String str) {
    return int.parse(str[5]) * 10 + int.parse(str[6]);
  }

  /* =================================== Read data Temp in day ========================================== */
  Future<int> readTempFromFireStoreInDay(String date) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('ROOM 1')
        .doc('TEMP_inday')
        .get();
    int value = 0;

    if (documentSnapshot.exists) {
      value = documentSnapshot[date];
    }
    return value;
  }

/* =================================== Read data Temp in range of days ========================================== */
  Future<List<FlSpot>> generateTempSpotsRangeDays(
      String startDay, String endDay) async {
    List<FlSpot> spots = [];
    String year = startDay[0] + startDay[1] + startDay[2] + startDay[3];
    String startDay_ = startDay[8] + startDay[9];
    String endDay_ = endDay[8] + endDay[9];
    String startMonth_ = startDay[5] + startDay[6];
    String endMonth_ = endDay[5] + endDay[6];
    int valueBeDraw = 40;
    double xValue = 0;
    /* count days between start and end range of day */
    int monthOfStart = monthOfStr(startDay);
    int monthOfEnd = monthOfStr(endDay);

    /* get data */
    if (monthOfEnd > monthOfStart) {
      // difference month
      for (int i = int.parse(startDay_); i <= returnDayOfMonth(startDay); i++) {
        String day = "$year.$startMonth_.${i ~/ 10}${i % 10}";
        print(day);
        int a = await (readTempThresholdInDay(day));
        valueBeDraw = a % 100;
        spots.add(FlSpot(xValue, valueBeDraw.toDouble()));
        xValue = xValue + 1;
      }
      for (int i = 1; i <= int.parse(endDay_); i++) {
        String day = "$year.$endMonth_.${i ~/ 10}${i % 10}";
        print(day);
        int a = await (readTempThresholdInDay(day));
        valueBeDraw = a % 100;
        spots.add(FlSpot(xValue, valueBeDraw.toDouble()));
        xValue = xValue + 1;
      }
    } else {
      // same month
      for (int i = int.parse(startDay_); i <= int.parse(endDay_); i++) {
        String day = "$year.$endMonth_.${i ~/ 10}${i % 10}";
        int a = await readTempFromFireStoreInDay(day);
        valueBeDraw = a % 100;
        spots.add(FlSpot(xValue, valueBeDraw.toDouble()));
        xValue = xValue + 1;
      }
    }

    return spots;
  }

  /*  */
  Future<int> readTempThresholdInDay(String date) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('ROOM 1')
        .doc('TEMP_inday')
        .get();
    int value = 0;

    if (documentSnapshot.exists) {
      value = documentSnapshot[date];
    }
    return value;
  }

/* =================================== Read data Temp in range of days ========================================== */
  Future<List<FlSpot>> generateTempThresholdRangeDays(
      String startDay, String endDay) async {
    List<FlSpot> spots = [];
    String year = startDay[0] + startDay[1] + startDay[2] + startDay[3];
    String startDay_ = startDay[8] + startDay[9];
    String endDay_ = endDay[8] + endDay[9];
    String startMonth_ = startDay[5] + startDay[6];
    String endMonth_ = endDay[5] + endDay[6];
    int valueBeDraw = 40;
    double xValue = 0;
    /* count days between start and end range of day */
    int monthOfStart = monthOfStr(startDay);
    int monthOfEnd = monthOfStr(endDay);

    /* get data */
    if (monthOfEnd > monthOfStart) {
      // difference month
      for (int i = int.parse(startDay_); i <= returnDayOfMonth(startDay); i++) {
        String day = "$year.$startMonth_.${i ~/ 10}${i % 10}";
        int a = await (readTempThresholdInDay(day));
        valueBeDraw = a ~/ 100;
        spots.add(FlSpot(xValue, valueBeDraw.toDouble()));
        xValue = xValue + 1;
      }
      for (int i = 1; i <= int.parse(endDay_); i++) {
        String day = "$year.$endMonth_.${i ~/ 10}${i % 10}";
        print(day);
        int a = await (readTempThresholdInDay(day));
        valueBeDraw = a ~/ 100;
        spots.add(FlSpot(xValue, valueBeDraw.toDouble()));
        xValue = xValue + 1;
      }
    } else {
      // same month
      for (int i = int.parse(startDay_); i <= int.parse(endDay_); i++) {
        String day = "$year.$endMonth_.${i ~/ 10}${i % 10}";
        print(day);
        int a = await (readTempThresholdInDay(day));
        valueBeDraw = a ~/ 100;
        spots.add(FlSpot(xValue, valueBeDraw.toDouble()));
        xValue = xValue + 1;
      }
    }

    return spots;
  }

/* ====================================== func to click select one day ==================================== */
  Future<List<FlSpot>> generateGasSpotsRangeDays() async {
    List<FlSpot> spots = [];

    double hour = 0;
    double min = 0;
    int valueBeDraw = 40;

    for (int i = 0; i < 48; i++) {
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

/* ====================================== func to click select one day ==================================== */
  Future<List<FlSpot>> selectDataBeShown() async {
    if (isDayOrMonth == false) {
      // select day
      if (dataBeShown == 'Gas') {
        return generateGasSpots();
      } else {
        return generateTempSpots();
      }
    } else {
      // select range of day
      if (dataBeShown == 'Gas') {
        return generateGasSpotsRangeDays();
      } else {
        return generateTempSpotsRangeDays(startDay, endDay);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<List<FlSpot>>(
          future: selectDataBeShown(),
          builder: (context, snapshotData) {
            if (snapshotData.connectionState == ConnectionState.waiting) {
              return Container(
                padding: const EdgeInsets.all(10),
                width: 100,
                height: 100,
                child: const CircularProgressIndicator(),
              );
            } else if (snapshotData.hasError) {
              return Text('Error: ${snapshotData.error}');
            } else {
              List<FlSpot> dataSpots = snapshotData.data!;
              return FutureBuilder<List<FlSpot>>(
                future: generateTempThresholdRangeDays(startDay, endDay),
                builder: (context, snapshotThreshold) {
                  if (snapshotThreshold.connectionState ==
                      ConnectionState.waiting) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      width: 100,
                      height: 100,
                      child: const CircularProgressIndicator(),
                    );
                  } else if (snapshotThreshold.hasError) {
                    return Text('Error: ${snapshotThreshold.error}');
                  } else {
                    List<FlSpot> thresholdSpots = snapshotThreshold.data!;
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        width: double.infinity,
                        height: 600,
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: dataSpots,
                                color: Colors.blue,
                                barWidth: 4,
                                isStrokeCapRound: true,
                                isCurved: false,
                                belowBarData: BarAreaData(show: false),
                                dotData: const FlDotData(
                                  show: false,
                                ),
                              ),
                              LineChartBarData(
                                spots: thresholdSpots,
                                color: Colors.red,
                                barWidth: 4,
                                isStrokeCapRound: true,
                                isCurved: false,
                                belowBarData: BarAreaData(show: false),
                                dotData: const FlDotData(
                                  show: false,
                                ),
                              )
                            ],
                            titlesData: const FlTitlesData(
                                bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                  showTitles: true,
                                )),
                                rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false))),
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
              );
            }
          },
        ),
      ],
    );
  }
}
