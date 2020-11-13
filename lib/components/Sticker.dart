import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class Sticker extends StatefulWidget {
  final String baseFolder;
  final String fileName;
  final Function(bool, String, String) onSelectedChange;

  Sticker({
    @required this.baseFolder,
    @required this.fileName,
    this.onSelectedChange,
  });

  @override
  _StickerState createState() => _StickerState();
}

class _StickerState extends State<Sticker> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selected = !selected;
        });

        if (widget.onSelectedChange != null)
          widget.onSelectedChange(selected, widget.fileName, widget.baseFolder);
      },
      child: Stack(
        children: [
          Image.file(File(path.join(widget.baseFolder, widget.fileName))),
          if (selected)
            Positioned(
              top: 15,
              right: 15,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: BoxConstraints(
                  minWidth: 14,
                  minHeight: 14,
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
