import 'package:flutter/material.dart';
import 'package:whatsapp_stickers_organizer/screens/GiftScreen.dart';
import 'package:whatsapp_stickers_organizer/screens/HelpScreen.dart';

import 'containers/ContainerWithPermissions.dart';
import 'screens/CachedScreen.dart';
import 'screens/IgnoredScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whatsapp Stickers Organizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.pink[300],
        accentColor: Colors.pink[500],
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/cached',
      routes: <String, WidgetBuilder>{
        '/cached': (context) => ContainerWithPermissions(
            Permission.extStorage, (context) => CachedScreen()),
        '/ignored': (context) => IgnoredScreen(),
        '/help': (context) => HelpScreen(),
        '/gift': (context) => GiftScreen(),
      },
    );
  }
}
