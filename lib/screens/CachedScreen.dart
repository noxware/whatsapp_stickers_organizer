import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../containers/MainDrawer.dart';
import '../containers/StickersGrid.dart';

class CachedScreen extends StatefulWidget {
  @override
  _CachedScreenState createState() => _CachedScreenState();
}

class _CachedScreenState extends State<CachedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cached stickers'),
        actions: <Widget>[
          IconButton(
            icon: Icon(MdiIcons.eyeOffOutline),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(MdiIcons.check),
            onPressed: () {},
          ),
        ],
      ),
      drawer: MainDrawer(),
      body: StickersGrid(),
    );
  }
}
