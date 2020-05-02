import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

    void new_data(){
      setState(() {

      });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (widget.eSense.deviceStatus == 'device_not_found') ? Colors.deepOrangeAccent : Colors.greenAccent,
      body:
      Align(
        alignment: Alignment.topLeft,
        child: ListView(
          children: [
            Text('eSense Device Status: \t'+ widget.eSense.deviceStatus),
            Text('eSense Device Name: \t' + widget.eSense.deviceName),
            Text('Find he source code to this project and many others here'),
            new RaisedButton(
              onPressed: _launchGithub,
              child: new Text('Visit my Github :)')),
            Text('Author Jonas Heinle'),
            Text('For more Information about me go on my website'),
            new RaisedButton(
                onPressed: _launchHomepage,
                child: new Text('Visit my homepage :)')),
          ],
        ),
      ),
      /*floatingActionButton: new FloatingActionButton(
        // a floating button that starts/stops listening to sensor events.
        // is disabled until we're connected to the device.
        onPressed:  this.new_data,
        tooltip: 'Refresh',
        child: Icon(Icons.play_arrow),
      ),*/
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

  _launchGithub() async {
      const url = 'https://github.com/Kataglyphis';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    _launchHomepage() async {
      const url = 'https://jotrockenmitlocken.de/';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
}
