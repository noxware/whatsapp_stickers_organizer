import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Sticker extends StatelessWidget {
  final String filePath;
  final int selectedIndex;
  final void Function(bool selected, String filePath) onSelectedShoudChange;

  Sticker({
    Key key,
    @required this.filePath,
    this.selectedIndex,
    this.onSelectedShoudChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onSelectedShoudChange != null)
          onSelectedShoudChange(selectedIndex != null, filePath);
      },
      child: Container(
        padding: EdgeInsets.all(selectedIndex != null ? 8 : 0),
        child: Stack(
          children: [
            Image.file(File(filePath)),
            if (selectedIndex != null)
              Container(
                color: Colors.pink[200].withOpacity(0.4),
              ),
            if (selectedIndex != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.pink[500],
                    //borderRadius: BorderRadius.circular(6),
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$selectedIndex',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
