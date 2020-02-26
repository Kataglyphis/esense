import 'package:flutter/material.dart';

import 'package:epic_esense_app/navigation_screens/Modus.dart';

class Modi extends StatelessWidget {

  static const _modiNames = <String>[
    'Length',
    'Area',
    'Volume',
    'Mass',
    'Time',
    'Digital Storage',
    'Energy',
    'Currency',
  ];

  static const _baseColors = <Color>[
    Colors.teal,
    Colors.orange,
    Colors.pinkAccent,
    Colors.blueAccent,
    Colors.yellow,
    Colors.greenAccent,
    Colors.purpleAccent,
    Colors.red,
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
        iconLocation: Icons.cake,
      ));
    }

    final listView = Container(
      color: Colors.greenAccent,
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: _buildModiWidgets(modi),
    );

    return Scaffold(
      body: listView,
    );

  }
}