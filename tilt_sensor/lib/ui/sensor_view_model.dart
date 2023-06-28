import 'package:sensors_plus/sensors_plus.dart';
import 'package:tilt_sensor/data/model/sensor_event.dart';

class SensorViewModel {
  Stream<SensorEvent> get eventStream => accelerometerEvents
      .map((event) => SensorEvent(event.x, event.y, event.z));
}
