import 'package:equatable/equatable.dart';
class GyroscopeData extends Equatable {
// Rotation on the axis from the back to the front side of the phone
  double azimuth;
// Rotation on the axis from the left to the right side of the phone
  double pitch;
// Rotation on the axis from the bottom to the top of the phone
  double roll;
  GyroscopeData({
    this.azimuth = 0,
    this.pitch = 0,
    this.roll = 0,
  });
 GyroscopeData.fromList(List<double> list)
      : pitch = list[0],
        roll = list[1],
        azimuth = list[2];
  @override
  List<Object> get props => [azimuth, pitch, roll];
}