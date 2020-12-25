import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:whatsapp_stickers_organizer/core/storage.dart';
import '../core/whatsapp.dart' as wsp;

class MainDrawer extends StatelessWidget {
  final void Function() update;

  const MainDrawer({
    Key key,
    this.update,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<int> ignoredCount = IgnoredStickers().data.then((l) => l.length);
    Future<int> cachedCount = wsp.cachedStickers.then((l) => l.length);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: FutureBuilder(
              future: Future.wait([cachedCount, ignoredCount]),
              builder: (context, AsyncSnapshot<List<int>> snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${snapshot.data[1]} stickers ignorados',
                            style: TextStyle(color: Colors.white)),
                        Text('${snapshot.data[0]} stickers cacheados',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            decoration: BoxDecoration(
              color: Colors.pink[300],
            ),
          ),
          ListTile(
            title: Text('Stickers ignorados'),
            leading: Icon(MdiIcons.eyeOffOutline),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ignored').then((v) => update());
            },
          ),
          /*ListTile(
            title: Text('Settings'),
            leading: Icon(MdiIcons.cogOutline),
          ),*/
          ListTile(
            title: Text('Ayuda'),
            leading: Icon(MdiIcons.helpCircleOutline),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/help');
            },
          ),
          ListTile(
            title: Text('Regalo especial'),
            leading: Icon(MdiIcons.giftOutline),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/gift');
            },
          ),
        ],
      ),
    );
  }
}
