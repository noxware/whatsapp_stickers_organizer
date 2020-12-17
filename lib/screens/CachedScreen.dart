import 'dart:io';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:whatsapp_stickers_organizer/dialogs/askText.dart';

import '../containers/MainDrawer.dart';
import '../containers/StickersGrid.dart';

import '../apis/appData.dart';
import '../apis/stickers.dart';

class CachedScreen extends StatefulWidget {
  final AppData appData;

  CachedScreen({@required this.appData});

  @override
  _CachedScreenState createState() => _CachedScreenState();
}

class _CachedScreenState extends State<CachedScreen> {
  final selectedStickers = new Set<String>();

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
            onPressed: () async {
              var res = await askText(
                  context: context,
                  title: 'Make sticker pack',
                  labelText: 'Name');

              if (res != null) {
                await widget.appData.whatsapp
                    .buildPack(res, selectedStickers.map((s) => File(s)));
                await widget.appData.whatsapp.installPack(context, res);
              }
            },
          ),
        ],
      ),
      drawer: MainDrawer(),
      body: FutureBuilder(
        future: Future.wait<List<File>>([widget.appData.stickerFiles]),
        builder: (context, AsyncSnapshot<List<List<File>>> snapshot) {
          if (snapshot.hasData) {
            return StickersGrid(
              stickersPath: snapshot.data[0].map((f) => f.path).toList(),
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
    );
  }
}
