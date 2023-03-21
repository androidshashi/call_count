import 'dart:io';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  late SharedPreferences prefs;
  String _lastCallAt = "No call received";

  @override
  void initState() {
    if(Platform.isIOS)
      {
        Fluttertoast.showToast(
            msg: "Inside init state",
        );
        setStream();
      }
    if(Platform.isAndroid)
    {
      askForPhoneStatePermission();
    }

    super.initState();
  }

  //Only for android
  void askForPhoneStatePermission() async {
    if (await Permission.phone.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      setStream();
    }

    var status = await Permission.phone.status;
    if (status.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      await Permission.phone.request();
    }

    // You can can also directly ask the permission about its status.
    if (await Permission.phone.isRestricted) {
      await Permission.contacts.shouldShowRequestRationale;
    }

    if (await Permission.phone.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  ///Start phone call state
  Future<void> setStream() async {
    Fluttertoast.showToast(
      msg: "Inside setStream",
    );
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt("call_counter") ?? 0;
      _lastCallAt =
          prefs.getString("last_call_at") ?? "No calls received till now";
    });

    debugPrint(
        "---------------------------previous calls:$_counter---------------------------");
    PhoneState.phoneStateStream.listen((event) async {
      if (event != null) {
        if (event == PhoneStateStatus.CALL_STARTED) {
          //call counter
          int counter = prefs.getInt("call_counter") ?? 0;
          counter++;
          prefs.setInt("call_counter", counter);

          //last call time
          var now = DateTime.now();
          String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
          prefs.setString("last_call_at", formattedDate);

          setState(() {
            _counter = counter;
            _lastCallAt = formattedDate;
            debugPrint(
                "----------Counter:$_counter, Last call at:$_lastCallAt----------");
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have answered calls:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              "You received last call at:$_lastCallAt",
            ),
            ...Platform.isAndroid ? (_batteryOptimizationLayout()) : [],
          ],
        ),
      ),
    );
  }

  List<Widget> _batteryOptimizationLayout() {
    return [
      const SizedBox(
        height: 20,
      ),
      ElevatedButton(
          child: const Text("Disable Battery Optimizations"),
          onPressed: () {
            DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
          }),
      const SizedBox(
        height: 20,
      ),
      ElevatedButton(
          child: const Text("Disable Manufacturer Battery Optimizations"),
          onPressed: () {
            DisableBatteryOptimization
                .showDisableManufacturerBatteryOptimizationSettings(
                    "Your device has additional battery optimization",
                    "Follow the steps and disable the optimizations to allow smooth functioning of this app");
          }),
    ];
  }
}
