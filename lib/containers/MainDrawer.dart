import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text(''),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Ignored stickers'),
            leading: Icon(MdiIcons.eyeOffOutline),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ignored');
            },
          ),
          ListTile(
            title: Text('Settings'),
            leading: Icon(MdiIcons.cogOutline),
          ),
          ListTile(
            title: Text('Help'),
            leading: Icon(MdiIcons.helpCircleOutline),
          ),
          ListTile(
            title: Text('Special gift'),
            leading: Icon(MdiIcons.giftOutline),
          ),
        ],
      ),
    );
  }
}
