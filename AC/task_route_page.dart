import 'dart:async';
import 'package:air_conditioner_remote_app/connectivity_page.dart';
import 'package:air_conditioner_remote_app/wifi_page.dart';
import 'package:esptouch_smartconfig/esptouch_smartconfig.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'add_remote.dart';

class TaskRoute extends StatefulWidget {
  TaskRoute(
      this.ssid, this.bssid, this.password, this.deviceCount, this.isBroadcast);
  final String ssid;
  final String bssid;
  final String password;
  final String deviceCount;
  final bool isBroadcast;
  @override
  State<StatefulWidget> createState() {
    return TaskRouteState();
  }
}

class TaskRouteState extends State<TaskRoute> {
  late Stream<ESPTouchResult>? _stream;

  @override
  void initState() {
    _stream = EsptouchSmartconfig.run(
        ssid: widget.ssid,
        bssid: widget.bssid,
        password: widget.password,
        deviceCount: widget.deviceCount,
        isBroad: widget.isBroadcast);
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  Widget waitingState(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.blue),
          ),
          SizedBox(height: 16),
          Text(
            'Waiting for results',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }

  Widget error(BuildContext context, String s) {
    return Center(
      child: Text(
        s,
        style: TextStyle(color: Colors.blue),
      ),
    );
  }

  Widget noneState(BuildContext context) {
    return Center(
        child: Text(
      'None',
      style: TextStyle(fontSize: 24),
    ));
  }

  Widget resultList(BuildContext context, ConnectionState state) {
    final result = _results.toList(growable: false)[0];
    deviceip = result.ip;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 380,
          height: 250,
          decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: <Widget>[
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 25, right: 25, top: 20),
                  child: Text(
                    "Success!",
                    style: TextStyle(fontSize: 30, color: Colors.black),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 25, right: 25, top: 20),
                child: Text('Success! Device IP : ${result.ip}'),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 25, right: 25, top: 20),
                child:
                    Text('Press "View Device" button to return main screen.'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, top: 30),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                        fixedSize: const Size(400, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: (() {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const MyApp(),
                      ));
                    }),
                    child: const Text('VIEW DEVICE')),
              ),
            ],
          ),
        )
        // Expanded(
        //   child: ListView.builder(
        //     itemCount: _results.length,
        //     itemBuilder: (_, index) {
        //       final result = _results.toList(growable: false)[index];
        //       return Padding(
        //         padding: const EdgeInsets.all(8.0),
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //           children: <Widget>[
        //             Row(
        //               children: <Widget>[
        //                 Text('BSSID: '),
        //                 Text(result.bssid),
        //               ],
        //             ),
        //             Row(
        //               children: <Widget>[
        //                 Text('IP: '),
        //                 Text(result.ip),
        //               ],
        //             )
        //           ],
        //         ),
        //       );
        //     },
        //   ),
        // ),
        ,
        if (state == ConnectionState.active)
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.blue),
          ),
      ],
    );
  }

  final Set<ESPTouchResult> _results = Set();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: (() {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ConnectivityPage(),
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
        child: StreamBuilder<ESPTouchResult>(
          stream: _stream,
          builder: (context, AsyncSnapshot<ESPTouchResult> snapshot) {
            if (snapshot.hasError) {
              return error(context, 'Error in StreamBuilder');
            }
            switch (snapshot.connectionState) {
              case ConnectionState.active:
                _results.add(snapshot.data!);
                return resultList(context, ConnectionState.active);
              case ConnectionState.none:
                return noneState(context);
              case ConnectionState.done:
                if (snapshot.hasData) {
                  _results.add(snapshot.data!);
                  return resultList(context, ConnectionState.done);
                } else
                  return noneState(context);
              case ConnectionState.waiting:
                return waitingState(context);
            }
          },
        ),
      ),
    );
  }
}
