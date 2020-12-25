import 'dart:io';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../containers/MainDrawer.dart';
import '../containers/StickersGrid.dart';
import '../dialogs/askText.dart';
import '../core/whatsapp.dart' as wsp;
import '../core/storage.dart';

class IgnoredScreen extends StatefulWidget {
  @override
  _IgnoredScreenState createState() => _IgnoredScreenState();
}

class _IgnoredScreenState extends State<IgnoredScreen> {
  final selectedStickers = new Set<String>();

  @override
  Widget build(BuildContext context) {
    var ignored = IgnoredStickers();

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedStickers.length > 0
            ? 'Stickers ${selectedStickers.length}'
            : 'Stickers ignorados'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (String value) async {
              if (value == 'recover') {
                ignored.data = ignored.data.then((il) =>
                    il.where((e) => !selectedStickers.contains(e)).toList());
              }
              await ignored.data; // DO NOT CLEAR BEFORE FINISH
              selectedStickers.clear();
              setState(() {});
              await ignored.saveToDisk();
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'recover',
                child: Text('Recuperar estos stickers'),
              ),
            ],
          )
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: ignored.data,
          builder: (context, AsyncSnapshot<List<String>> snapshot) {
            if (snapshot.hasData) {
              return StickersGrid(
                stickersPath: snapshot.data,
                selectedStickers: selectedStickers,
                onStickerSelectionShoudChange: (_, String stickerPath) {
                  setState(() {
                    final selected = selectedStickers.remove(stickerPath);
                    if (!selected) selectedStickers.add(stickerPath);
                  });
                },
              );
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
