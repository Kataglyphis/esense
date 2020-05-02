import 'package:flutter/material.dart';

import 'package:epic_esense_app/navigation_screens/Modus.dart';
import 'package:epic_esense_app/esense.dart';

enum LastButtonPressed {VolumeModulator,Workout,None }

class Modi extends StatelessWidget {

  ESense esense;
  Modi({this.esense});

  static const _modiNames = <String>[
    'Workout',
    'None',
    'None',
    'None',
    'None',
    'None',
    'None',
    'None'
  ];

  static const _baseColors = <Color>[
    Colors.teal,
    Colors.red,
    Colors.red,
    Colors.red,
    Colors.red,
    Colors.red,
    Colors.red,
    Colors.red
  ];

  static const _baseIcons = <IconData>[
    Icons.fitness_center,
    Icons.block,
    Icons.block,
    Icons.block,
    Icons.block,
    Icons.block,
    Icons.block,
    Icons.block,
    Icons.block
  ];
  
  Widget _buildModiWidgets(List<Widget> modi) {
    return ListView.builder(
        itemBuilder: (BuildContext context, int index) => modi[index],
        itemCount: modi.length
    );
  }

  @override
  Widget build (BuildContext context) {

    final modi = <Modus>[];

    for(var i = 0; i < _modiNames.length;i++) {
      modi.add(Modus(
        name: _modiNames[i],
        color: _baseColors[i],
        iconLocation: _baseIcons[i],
      ));
    }

    final listView = Container(
      color: (esense.deviceStatus == 'device_not_found') ? Colors.deepOrangeAccent : Colors.greenAccent,//Colors.greenAccent,
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: _buildModiWidgets(modi),
    );

    return Scaffold(
      backgroundColor: (esense.deviceStatus == 'device_not_found') ? Colors.redAccent : Colors.greenAccent,
      body: listView,
    );

  }
}