import 'package:flutter/material.dart';

import '../esense.dart';

class Info extends StatefulWidget {

  ESense eSense;

  Info(ESense eSense) {
    this.eSense = eSense;
  }

  @override
  _MyInfoState createState() => _MyInfoState();

}

  class _MyInfoState extends State<Info> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (widget.eSense.deviceStatus == 'device_not_found') ? Colors.redAccent : Colors.greenAccent,
      body:
      Align(
        alignment: Alignment.topLeft,
        child: ListView(
          children: [
            Text('eSense Device Status: \t'+ widget.eSense.deviceStatus),
            Text('eSense Device Name: \t' + widget.eSense.deviceName),
            Text('eSense Battery Level: \t' + widget.eSense.voltage.toString()),
            Text('eSense Button Event: \t' + widget.eSense.button),
            Text('eSense accel OffsetX: \t' + widget.eSense.accelX),
            Text('eSense accel OffsetY: \t' + widget.eSense.accelY),
            Text('eSense accel OffsetZ: \t' + widget.eSense.accelZ),
            Text('eSense gyro OffsetX: \t' + widget.eSense.gyroX),
            Text('eSense gyro OffsetY: \t' + widget.eSense.gyroY),
            Text('eSense gyro OffsetZ: \t' + widget.eSense.gyroZ),
          ],
        ),
      ),
    );
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
