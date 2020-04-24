import 'package:flutter/material.dart';

class Info extends StatefulWidget {

  String deviceName;
  double voltage;
  String deviceStatus;
  bool sampling;
  String event;
  String button;
  String eSenseName;
  int offsetX;
  int offsetY;
  int offsetZ;

  Info(String deviceName, double voltage, String deviceStatus, bool sampling,
      String Stringevent, String button, String eSenseName, int offsetX, int offsetY, int offsetZ) {
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
            Text('eSense OffsetX: \t' + widget.offsetX.toString()),
            Text('eSense OffsetY: \t' + widget.offsetY.toString()),
            Text('eSense OffsetZ: \t' + widget.offsetZ.toString())
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment Counter',
        child: const Icon(Icons.add),
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
