import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import '../components/Sticker.dart';

class StickersGrid extends StatelessWidget {
  final String baseFolder;
  final List<String> fileNames;
  final Function(bool, String, String) onSelectedChange;

  StickersGrid({
    @required this.baseFolder,
    @required this.fileNames,
    this.onSelectedChange,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 100,
        childAspectRatio: 1,
      ),
      itemCount: fileNames.length,
      itemBuilder: (context, index) => Sticker(
        baseFolder: baseFolder,
        fileName: fileNames[index],
        onSelectedChange: onSelectedChange,
      ),
    );
  }
}
