import 'package:esptouch_smartconfig/esptouch_smartconfig.dart';
import 'task_route_page.dart';
import 'package:flutter/material.dart';

class WifiPage extends StatefulWidget {
  WifiPage(this.ssid, this.bssid);

  final String ssid;
  final String bssid;

  @override
  _WifiPageState createState() => _WifiPageState();
}

class _WifiPageState extends State<WifiPage> {
  bool isBroad = false;
  TextEditingController password = TextEditingController();
  TextEditingController deviceCount = TextEditingController(text: "1");
  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 380,
                  height: 280,
                  decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      //  border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text.rich(TextSpan(children: [
                        const TextSpan(
                            text: "WIFI SSID:   ",
                            style: TextStyle(fontSize: 20, color: Colors.blue)),
                        TextSpan(
                            text: widget.ssid,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black)),
                      ])),
                      const SizedBox(
                        height: 6,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 25, right: 25, top: 15),
                        child: Text(
                            'Please enter the credentials for your network below.'),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 25, right: 25, top: 20),
                        child: TextField(
                          obscureText: _isObscure,
                          controller: password,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              labelText: "Network password",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                },
                              )),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 25, right: 25, top: 20),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                fixedSize: const Size(400, 55),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            child: const Text('CONFIRM'),
                            onPressed: () async {
                              print(password.text);
                              print(deviceCount.text);
                              Set<ESPTouchResult> result =
                                  await Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => TaskRoute(
                                              widget.ssid,
                                              widget.bssid,
                                              password.text,
                                              deviceCount.text,
                                              isBroad)));
                              print("result : $result");
                            },
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
