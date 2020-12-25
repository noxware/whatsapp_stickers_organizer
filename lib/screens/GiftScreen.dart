import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class GiftScreen extends StatelessWidget {
  const GiftScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Regalo especial'),
      ),
      body: Center(
        child: Text(
          '',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
