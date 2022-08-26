import 'dart:async';
import 'package:flutter/services.dart';
import 'package:gyroscope/src/gyroscope_data.dart';
import 'package:gyroscope/src/gyroscope_sensor_impl.dart';
import 'package:gyroscope/src/sample_rate.dart';
export 'package:gyroscope/src/gyroscope_data.dart';
// export 'package:gyroscope/src/sample_rate.dart';
export 'package:gyroscope/src/exceptions.dart';
// export 'package:gyroscope/src/gyroscope_sensor_impl.dart';

class Gyroscope {
  static const MethodChannel _channel =
      const MethodChannel('gyroscope');
  static const EventChannel _gyroscopeEventChannel = EventChannel('gyroscope/');


  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
  static Stream<GyroscopeData> get gyroscope {
    Stream<GyroscopeData>? gyroscopeEvents;
    if (gyroscopeEvents == null) {
      //will call and start recieving stream of data of gyroscope here
      gyroscopeEvents =
          _gyroscopeEventChannel.receiveBroadcastStream().map((dynamic event){
            print(event);
              return GyroscopeData.fromList(event.cast<double>());
          });
    }
    return gyroscopeEvents;
  }
  static Future<bool> get unSubscribe async{
    //this will un subscribe to the sensor here
    await GyroscopeSensorImpl().unsubscribe();
    return true;
  }
  static Future<bool> get subscribe async{
    // this will subscribe to the sensor
    GyroscopeSensorImpl().subscribe((data) => SampleRate.normal);
    return true;
  }
}
