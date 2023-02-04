// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Permission.location.request();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         debugShowCheckedModeBanner: false, home: ConnectivityPage());
//   }
// }

import 'connectivity_page.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:convert' as convert;
import 'package:air_conditioner_remote_app/add_remote.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.location.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Air Conditioner remote',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Air Conditioner Remote'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void initState() {
    super.initState();

    Timer.periodic(Duration(seconds: 5), (Timer t) {
      UpdateDate();
    });
  }

  void UpdateDate() async {
    if (deviceip.length > 5) {
      sendCmd(myCmd.CMD_GET_DATA);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(
              fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: 180,
                    height: 120,
                    decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.15),
                        border: Border.all(
                            color: Colors.blue.withOpacity(0.1), width: 20),
                        borderRadius: BorderRadius.circular(30)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 10),
                          child: Text(
                            "Current Temperature",
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        Center(
                          child: Text(
                            curTemp + " \u2103",
                            style: const TextStyle(
                                fontSize: 30,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 180,
                    height: 120,
                    decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.15),
                        border: Border.all(
                            color: Colors.blue.withOpacity(0.1), width: 20),
                        borderRadius: BorderRadius.circular(30)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 10),
                          child: Text(
                            "Set Temperature",
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        Center(
                          child: Text(
                            setTemp.toString() + " \u2103",
                            style: const TextStyle(
                                fontSize: 30,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Container(
                width: 380,
                height: 370,
                decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    border: Border.all(
                        color: Colors.blue.withOpacity(0.1), width: 20),
                    borderRadius: BorderRadius.circular(80)),
                child: Column(
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 0, right: 0, top: 20, bottom: 20),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.red,
                                    fixedSize: const Size(150, 50),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50))),
                                onPressed: (() {
                                  sendCmd(myCmd.CMD_ON_OFF);
                                }),
                                child: const Text('ON/OFF')),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 5, right: 0, top: 20, bottom: 20),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                  fixedSize: const Size(50, 50),
                                  shape: CircleBorder(),
                                ),
                                onPressed: (() {
                                  sendCmd(myCmd.CMD_ON_CONFIG);
                                }),
                                child: const Text('C')),
                          ),
                        ]),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 0, right: 0, top: 20),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              onPrimary: Colors.white,
                              fixedSize: const Size(150, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: (() {
                            sendCmd(myCmd.CMD_FAN);
                          }),
                          child: const Text('FAN')),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 0, top: 20),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  onPrimary: Colors.white,
                                  fixedSize: const Size(80, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              onPressed: (() {
                                setState(() {
                                  sendCmd(myCmd.CMD_UP);
                                });
                              }),
                              child: const Text('UP')),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 0, right: 0, top: 20),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  onPrimary: const Color(0xffb888888),
                                  fixedSize: const Size(80, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              onPressed: (() {
                                sendCmd(myCmd.CMD_MODE);
                              }),
                              child: const Text('MODE')),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 0, right: 20, top: 20),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                onPrimary: Colors.white,
                                fixedSize: const Size(80, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            onPressed: (() {
                              setState(() {
                                sendCmd(myCmd.CMD_DOWN);
                              });
                            }),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text('DOWN'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 0, right: 0, top: 20, bottom: 20),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              onPrimary: Colors.white,
                              fixedSize: const Size(150, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: (() {
                            sendCmd(myCmd.CMD_SWING);
                          }),
                          child: const Text('SWING')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: deviceAddButton(),
    );
  }

  Widget deviceAddButton() => FloatingActionButton(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      onPressed: () {
        Navigator.push(
            this.context,
            MaterialPageRoute(
              builder: (context) => const AddRemotePage(),
            ));
      },
      child: const Icon(Icons.add));
}
