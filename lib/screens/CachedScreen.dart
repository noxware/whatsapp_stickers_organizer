import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../containers/MainDrawer.dart';
import '../containers/StickersGrid.dart';

import '../apis/appData.dart';

class CachedScreen extends StatefulWidget {
  final Future<AppData> appData;

  CachedScreen({@required this.appData});

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
      body: FutureBuilder(
        future: widget.appData,
        builder: (context, AsyncSnapshot<AppData> snapshot) {
          if (snapshot.hasData) {
            return StickersGrid(
              baseFolder: snapshot.data.stickersFolder,
              fileNames: snapshot.data.fileNames,
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
