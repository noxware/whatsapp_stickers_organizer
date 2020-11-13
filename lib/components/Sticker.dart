import 'package:flutter/material.dart';

class Sticker extends StatelessWidget {
  Sticker({
    @required this.image,
    this.tick,
    this.onTap,
  });

  final String tick;
  final String image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 'https://api.sticker.place/v2/images/5dc96428e4b0e670e6ec2d3a'
    return Stack(
      children: [
        Image.network(this.image),
        if (this.tick != null)
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
                this.tick,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
