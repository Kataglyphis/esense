import 'package:flutter/material.dart';

class Info extends StatelessWidget {
  String _deviceName;
  double _voltage;
  String _deviceStatus;
  bool sampling;
  String _event;
  String _button;
  String eSenseName;

  Info(String _deviceName, double _voltage, String _deviceStatus, bool sampling,
      String _event, String _button, String eSenseName) {
    this._deviceName = _deviceName;
    this._voltage = _voltage;
    this._deviceStatus = _deviceStatus;
    this.sampling = sampling;
    this._event = _event;
    this._button = _button;
    this.eSenseName = eSenseName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Align(
        alignment: Alignment.topLeft,
        child: ListView(
          children: [
            Text('eSense Device Status: \t$_deviceStatus'),
            Text('eSense Device Name: \t$_deviceName'),
            Text('eSense Battery Level: \t$_voltage'),
            Text('eSense Button Event: \t$_button'),
            Text(''),
            Text('$_event'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment Counter',
        child: const Icon(Icons.add),
      ),
    );
  }
}
