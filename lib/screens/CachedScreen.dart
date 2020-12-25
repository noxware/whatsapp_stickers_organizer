import 'dart:io';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../containers/MainDrawer.dart';
import '../containers/StickersGrid.dart';
import '../dialogs/askText.dart';
import '../core/whatsapp.dart' as wsp;
import '../core/storage.dart';

class CachedScreen extends StatefulWidget {
  @override
  _CachedScreenState createState() => _CachedScreenState();
}

class _CachedScreenState extends State<CachedScreen> {
  var selectedStickers = new Set<String>();

  @override
  Widget build(BuildContext context) {
    var ignored = IgnoredStickers();

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedStickers.length > 0
            ? 'Stickers ${selectedStickers.length}'
            : 'Stickers cacheados'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (String value) async {
              final data = await ignored.data;
              if (value == 'ignore') {
                data.addAll(selectedStickers);
                selectedStickers.clear();
                ignored.saveToDisk();
              } else if (value == 'selectAll') {
                selectedStickers =
                    (await wsp.cachedStickers).map((f) => f.path).toSet();
              } else if (value == 'unselectAll') {
                selectedStickers.clear();
              }
              setState(() {});
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'ignore',
                child: Text('Esconder estos stickers'),
              ),
              PopupMenuItem(
                value: 'selectAll',
                child: Text('Seleccionar todos'),
              ),
              PopupMenuItem(
                value: 'unselectAll',
                child: Text('Deseleccionar todos'),
              ),
            ],
          )
        ],
      ),
      drawer: MainDrawer(update: () => setState(() {})),
      body: Center(
        child: FutureBuilder(
          future: Future.wait([wsp.cachedStickers, ignored.data]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasData) {
              final Set<String> i = (snapshot.data[1] as List<String>).toSet();
              final List<String> c = (snapshot.data[0] as Iterable<File>)
                  .map((f) => f.path)
                  .where((s) => !i.contains(s))
                  .toList();

              return StickersGrid(
                stickersPath: c,
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
      floatingActionButton: selectedStickers.length > 0
          ? FloatingActionButton(
              onPressed: () async {
                var res = await askText(
                    context: context,
                    title: 'Crear paquete de stickers',
                    labelText: 'Nombre unico');

                if (res != null) {
                  await wsp.buildPack(
                      res, selectedStickers.map((s) => File(s)));
                  await wsp.installPack(context, res);
                  selectedStickers.clear();
                  setState(() {});
                }
              },
              child: Icon(MdiIcons.send),
              //backgroundColor: Colors.pink[500],
            )
          : null,
    );
  }
}
