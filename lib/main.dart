import 'package:flutter/material.dart';
import 'package:flutter_smart_home/room/kitchen_room.dart'; // temparature template
import 'package:flutter_smart_home/room/bed_room.dart'; // energy template
import 'package:flutter_smart_home/change_phone_num.dart';

import 'package:firebase_core/firebase_core.dart';

/* import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: 'AIzaSyA9Pi37HIms_ik9HPUNOHO - YAlxXEHbAhs',
        appId: '1:867706539798:android:ab2894c9d7a0acfb914a37',
        messagingSenderId: '867706539798',
        projectId: 'final-pro-97449'),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _loginController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 200,
              ),
              const SizedBox(height: 55),
              TextField(
                controller: _loginController,
                decoration: const InputDecoration(
                  labelText: 'Login name',
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  _login();
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() {
    String loginName = _loginController.text;
    String password = _passwordController.text;

    // Perform login validation here
    if (loginName == 'house01' && password == '123123') {
      // Navigate to home screen or perform desired action
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // Show error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Invalid login name or password'),
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false, // Remove all routes in the stack
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
                  const Text(
                    'HOME',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  /* RotatedBox(
                    quarterTurns: 135,
                    child: Icon(
                      Icons.bar_chart_rounded,
                      color: Colors.indigo,
                      size: 25,
                    ),
                  ) */
                  PopupMenuButton(
                    icon: const Icon(Icons.menu),
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        child: Text('Change phone number'),
                        value: 'Option 1',
                      ),
                      const PopupMenuItem(
                        child: Text('Sign out'),
                        value: 'Option 2',
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'Option 1') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangeNumber()),
                        );
                      } else if (value == 'Option 2') {
                        _logout(context);
                      }
                    },
                  ),
                  /* ElevatedButton(
                    onPressed: () {
                      _logout(context);
                    },
                    child: const Text('Sign out'),
                  ), */
                ],
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 32),
                    Center(
                      child: Image.asset(
                        /* 'assets/images/banner.png', */
                        'assets/images/logo.png',
                        width: 200,
                        height: 200,
                        scale: 0.5,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'THIẾT KẾ HỆ THỐNG BÁO CHÁY',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    /* const SizedBox(height: 16), */
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cardMenu(
                          icon: 'assets/images/bed_room.png',
                          title: 'BEDROOM',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Bedroom(),
                              ),
                            );
                          },
                        ),
                        _cardMenu(
                          title: 'KITCHEN',
                          icon: 'assets/images/kitchen_room.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Kitchen(),
                              ),
                            );
                          },
                          //fontColor: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 80,
                    ),
                    const Text(
                      'SVTH Dương Văn Thành - 20161370',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'SVTH Nguyễn Hữu Danh - 20161298',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardMenu({
    required String title,
    required String icon,
    VoidCallback? onTap,
    Color color = Colors.green,
    Color fontColor = Colors.black,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 10,
        ),
        width: 160,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: fontColor, fontSize: 20),
            ),
            const SizedBox(height: 20),
            Image.asset(
              icon,
              width: 100,
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
