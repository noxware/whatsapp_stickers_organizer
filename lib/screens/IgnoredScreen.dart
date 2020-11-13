import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class IgnoredScreen extends StatefulWidget {
  IgnoredScreen({Key key}) : super(key: key);

  @override
  _IgnoredScreenState createState() => _IgnoredScreenState();
}

class _IgnoredScreenState extends State<IgnoredScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ignored stickers'),
        actions: <Widget>[
          IconButton(
            icon: Icon(MdiIcons.eyeOutline),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
