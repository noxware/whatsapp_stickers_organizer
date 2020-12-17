import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class Sticker extends StatelessWidget {
  final String filePath;
  final bool selected;
  final void Function(bool selected, String filePath) onSelectedShoudChange;

  Sticker({
    Key key,
    @required this.filePath,
    this.selected = false,
    this.onSelectedShoudChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onSelectedShoudChange != null)
          onSelectedShoudChange(selected, filePath);
      },
      child: Stack(
        children: [
          Image.file(File(filePath)),
          if (selected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
