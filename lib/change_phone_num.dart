import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class ChangeNumber extends StatefulWidget {
  @override
  _ChangeNumber createState() => _ChangeNumber();
}

class _ChangeNumber extends State<ChangeNumber> {
  final List<String> recentPhoneNumbers = [
    '0772488647', //Thanh moi Khanh Hoa
    '0947856900', // Danh LA
    '0365478963', // random
  ];

  bool flagSelect = true;

  final DatabaseReference phoneNumber =
      FirebaseDatabase.instance.ref('PhoneNumber');

  String recentPhoneNumber = "";
  void a() {
    phoneNumber.onValue.listen(
      (event) {
        if (mounted) {
          setState(() {
            recentPhoneNumber = event.snapshot.value.toString();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    a();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change number'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                flagSelect = false;
                _showPhoneNumberDialog(context);
              },
              child: const Text('Enter your phone number'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Currently phone number:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              recentPhoneNumber, // Display the recent phone number here
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 30.0),
                    child: Text(
                      'Recently phone number',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: ListView(
                      shrinkWrap: true,
                      children: recentPhoneNumbers
                          .map((phoneNumber) => ListTile(
                                title: Text(phoneNumber),
                                onTap: () {
                                  flagSelect = true;
                                  _showConfirmationDialog(context, phoneNumber);
                                },
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void writePhoneNumberToFireBase(String _phoneNumber) {
    setState(() {
      phoneNumber.set(_phoneNumber);
    });
  }

  void _showPhoneNumberDialog(BuildContext context) {
    String phoneNumber = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter phone number'),
          content: TextField(
            onChanged: (value) {
              phoneNumber = value;
            },
            decoration: const InputDecoration(hintText: 'Enter phone number'),
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
                _showConfirmationDialog(context, phoneNumber);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context, String phoneNumber) {
    String password = '';
    bool isObscureText = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Confirm'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone number be changed to: $phoneNumber'),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (value) {
                      password = value;
                    },
                    obscureText: isObscureText,
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isObscureText = !isObscureText;
                          });
                        },
                      ),
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
                    _showResultDialog(context, phoneNumber, password);
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

  void _showResultDialog(
      BuildContext context, String phoneNumber, String password) {
    if (password == '123123') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Successful'),
            content: const Text('Phone number be changed successfully'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  if (flagSelect) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      writePhoneNumberToFireBase(phoneNumber);
      print('print to check');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error!!'),
            content: const Text('Wrong password, please try again!'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
