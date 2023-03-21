import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:platform_device_id/platform_device_id.dart';

class WebService {
  static const String _serviceUrl =
      "https://panel.ga4d.com/eventsapi/index.php";

  static void send() async {
    Map returnData = {};
    String? deviceId = await PlatformDeviceId.getDeviceId;
    debugPrint("---------------Device Id:$deviceId----------------");

    Map<String,String> data = {
      'device': deviceId.toString(),
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
