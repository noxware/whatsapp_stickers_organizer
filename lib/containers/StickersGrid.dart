import 'package:flutter/material.dart';

import '../components/Sticker.dart';

class StickersGrid extends StatelessWidget {
  final List<String> stickersPath;
  final Set<String> selectedStickers;
  final void Function(bool currentSelectionValue, String stickerPath)
      onStickerSelectionShoudChange;

  StickersGrid({
    @required this.stickersPath,
    this.selectedStickers,
    this.onStickerSelectionShoudChange,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 100,
        childAspectRatio: 1,
      ),
      itemCount: stickersPath.length,
      itemBuilder: (context, index) => Sticker(
        key: ValueKey(stickersPath[index]),
        filePath: stickersPath[index],
        selected: selectedStickers.contains(stickersPath[index]),
        onSelectedShoudChange: onStickerSelectionShoudChange,
      ),
    );
  }
}
