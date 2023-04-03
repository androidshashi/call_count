import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebService {
  static const String _serviceUrl =
      "https://panel.ga4d.com/eventsapi/index.php";
  static const LAST_CALL_DATE ="last_call_date";
  static const LAST_CALL_TIME ="last_call_time";

  static void send() async {
    Map returnData = {};
    String? deviceId = await PlatformDeviceId.getDeviceId;

    var prefs = await SharedPreferences.getInstance();
     String lastCallAt = await prefs.getString(LAST_CALL_DATE) ?? "";
    String lastCallAtTime = await prefs.getString(LAST_CALL_TIME) ?? "";
    debugPrint("---------------Device Id:$lastCallAt----------------");

    Map<String,String> data = {
      'device': deviceId.toString(),
      'devicedatestamp':lastCallAt,
      'devicetimestamp':lastCallAtTime
    };

    var headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse(_serviceUrl));
    request.fields.addAll(data);

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      debugPrint(await response.stream.bytesToString());
    } else {
      debugPrint(response.reasonPhrase);
    }
  }
}
