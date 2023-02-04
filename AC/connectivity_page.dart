import 'dart:async';
import 'package:air_conditioner_remote_app/add_remote.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:esptouch_smartconfig/esptouch_smartconfig.dart';
import 'wifi_page.dart';
import 'package:flutter/material.dart';

class ConnectivityPage extends StatefulWidget {
  @override
  _ConnectivityPageState createState() => _ConnectivityPageState();
}

class _ConnectivityPageState extends State<ConnectivityPage> {
  late Connectivity _connectivity;
  late Stream<ConnectivityResult> _connectivityStream;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult? result;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivitySubscription = _connectivityStream.listen((e) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: (() {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddRemotePage(),
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
        body: FutureBuilder(
            future: _connectivity.checkConnectivity(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: CircularProgressIndicator(),
                );
              else if (snapshot.data == ConnectivityResult.wifi) {
                return FutureBuilder<Map<String, String>?>(
                    future: EsptouchSmartconfig.wifiData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return WifiPage(snapshot.data!['wifiName']!,
                            snapshot.data!['bssid']!);
                      } else
                        return Container();
                    });
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 380,
                        height: 380,
                        decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.15),
                            //  border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.wifi_off_sharp,
                              size: 200,
                              color: Colors.blue,
                            ),
                            Text(
                              "Please connect to your home WIFI",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 20, color: Colors.blue),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }
}
