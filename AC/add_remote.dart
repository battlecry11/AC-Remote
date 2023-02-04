import 'package:flutter/material.dart';
import 'dart:async';
import 'main.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'connectivity_page.dart';

// String deviceip = "192.168.0.104";
String deviceip = "";
int setTemp = 20;
String curTemp = "20";

enum myCmd {
  CMD_GET_DATA,
  CMD_ON_OFF,
  CMD_FAN,
  CMD_MODE,
  CMD_UP,
  CMD_DOWN,
  CMD_SWING,
  CMD_ON_CONFIG,
  CMD_OFF_CONFIG
}

void sendCmd(var cmd) async {
  print("Sending command to ESP32");
  print("CMD : ${cmd}");
  var url;
  switch (cmd) {
    case myCmd.CMD_GET_DATA:
      {
        url = Uri.parse('http://${deviceip}:80/data');
      }
      break;
    case myCmd.CMD_ON_OFF:
      {
        url = Uri.parse('http://${deviceip}:80/on');
      }
      break;
    case myCmd.CMD_FAN:
      {
        url = Uri.parse('http://${deviceip}:80/fan');
      }
      break;
    case myCmd.CMD_MODE:
      {
        url = Uri.parse('http://${deviceip}:80/mode');
      }
      break;
    case myCmd.CMD_UP:
      {
        url = Uri.parse('http://${deviceip}:80/up');
        setTemp++;
      }
      break;
    case myCmd.CMD_DOWN:
      {
        url = Uri.parse('http://${deviceip}:80/down');
        setTemp--;
      }
      break;
    case myCmd.CMD_SWING:
      {
        url = Uri.parse('http://${deviceip}:80/swing');
      }
      break;
    case myCmd.CMD_ON_CONFIG:
      {
        url = Uri.parse('http://${deviceip}:80/onconfig');
      }
      break;
    case myCmd.CMD_OFF_CONFIG:
      url = Uri.parse('http://${deviceip}:80/offconfig');
      break;
    default:
      url = Uri.parse('http://${deviceip}:80/');
      break;
  }
  final response = await http.get(url);
  if (response.statusCode == 200) {
    if (cmd == myCmd.CMD_GET_DATA) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var data = jsonResponse;
      String temp = data["temperature"];
      print("data: ${temp}");
      if (temp != 'nan') curTemp = temp;
    }
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}

class AddRemotePage extends StatefulWidget {
  const AddRemotePage({Key? key}) : super(key: key);

  @override
  State<AddRemotePage> createState() => _AddRemotePageState();
}

class _AddRemotePageState extends State<AddRemotePage> {
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void onconfig() async {
      print("starting button configuration");
      var url = Uri.parse('http://${deviceip}:80/onconfig');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        //   print("RE_data: ${RE_Data[name]['Led Light']}");
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: (() {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MyApp(),
                ));
              })),
          centerTitle: true,
          backgroundColor: Colors.white,
          title: const Text(
            "Add Remote",
            style: TextStyle(
                fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 380,
                height: 250,
                decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    //  border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: <Widget>[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 25, right: 25, top: 20),
                        child: Text(
                          "Add New Remote",
                          style: TextStyle(fontSize: 30, color: Colors.black),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 25, right: 25, top: 20),
                      child: Text(
                        "This wizard will help you to add new remote to your accout, please press start button and follow the instructions.",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15, bottom: 20, right: 20, top: 0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        margin: const EdgeInsets.all(10),
                        // child: Image.asset('images/Vector.png'),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 25, right: 5, top: 10),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  onPrimary: const Color(0xffb888888),
                                  fixedSize: const Size(150, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              onPressed: (() {
                                // sendCmd(myCmd.CMD_ON_CONFIG);
                              }),
                              child: const Text('END')),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 25, right: 15, top: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                onPrimary: Colors.white,
                                fixedSize: const Size(150, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            onPressed: (() {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => (ConnectivityPage()),
                              ));
                              // sendCmd(myCmd.CMD_OFF_CONFIG);
                            }),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text('Start'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
