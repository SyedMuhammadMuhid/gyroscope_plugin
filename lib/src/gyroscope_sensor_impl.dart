import 'package:flutter/services.dart';
import 'package:gyroscope/src/gyroscope_data.dart';
import 'package:gyroscope/src/gyroscope_sensor_interface.dart';
import 'package:gyroscope/src/sample_rate.dart';

class GyroscopeSensorImpl implements GyroscopeSensorInterface {
  MethodChannel _methodChannel = MethodChannel('gyroscope');
  @override
  Future<void> subscribe(GyroscopeSensorSubscription subscription, {
    SampleRate rate = SampleRate.normal,
  }) async {
// TODO: implement subscribe
    await _methodChannel.invokeMethod(
        'setSensorUpdateInterval', {"interval": 1});
    throw UnimplementedError();
  }

  @override
  Future<void> unsubscribe() async {
// TODO: implement unsubscribe
    await _methodChannel.invokeMethod('onCancleSensor');
    throw UnimplementedError();
  }

  @override
  Future<bool> isSensorAvailable() async {
    MethodChannel _methodChannel = MethodChannel('gyroscope');
    final available = await _methodChannel.invokeMethod('isSensorAvailable');
    return available;
  }
}