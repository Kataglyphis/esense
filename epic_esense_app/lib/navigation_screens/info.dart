import 'package:flutter/material.dart';

class Info extends StatefulWidget {

  String deviceName;
  double voltage;
  String deviceStatus;
  bool sampling;
  String event;
  String button;
  String eSenseName;
  String offsetX;
  String offsetY;
  String offsetZ;
  String gyroX;
  String gyroY;
  String gyroZ;

  Info(String deviceName, double voltage, String deviceStatus, bool sampling,
      String Stringevent, String button, String eSenseName, String offsetX, String offsetY, String offsetZ,
      String gyroX, String gyroY, String gyroZ) {
    this.deviceName = deviceName;
    this.voltage = voltage;
    this.deviceStatus = deviceStatus;
    this.sampling = sampling;
    this.event = Stringevent;
    this.button = button;
    this.eSenseName = eSenseName;
    this.offsetX = offsetX;
    this.offsetY = offsetY;
    this.offsetZ = offsetZ;
    this.gyroX = gyroX;
    this.gyroY = gyroY;
    this.gyroZ = gyroZ;
  }

  @override
  _MyInfoState createState() => _MyInfoState();

}

  class _MyInfoState extends State<Info> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (widget.deviceStatus == 'device_not_found') ? Colors.redAccent : Colors.greenAccent,
      body:
      Align(
        alignment: Alignment.topLeft,
        child: ListView(
          children: [
            Text('eSense Device Status: \t'+ widget.deviceStatus),
            Text('eSense Device Name: \t' + widget.deviceName),
            Text('eSense Battery Level: \t' + widget.voltage.toString()),
            Text('eSense Button Event: \t' + widget.button),
            Text('eSense accel OffsetX: \t' + widget.offsetX),
            Text('eSense accel OffsetY: \t' + widget.offsetY),
            Text('eSense accel OffsetZ: \t' + widget.offsetZ),
            Text('eSense gyro OffsetX: \t' + widget.gyroX),
            Text('eSense gyro OffsetY: \t' + widget.gyroY),
            Text('eSense gyro OffsetZ: \t' + widget.gyroZ),
          ],
        ),
      ),
    );
  }

  void pressedButton() {
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();

  }
}
