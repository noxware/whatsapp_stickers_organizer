import 'package:flutter/material.dart';
import '../components/Sticker.dart';

import 'package:flutter_whatsapp_stickers/flutter_whatsapp_stickers.dart';
import '../apis/stickers.dart';

class StickersGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getStickersFiles(),
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data.toString());
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return CircularProgressIndicator();
        }
      },
    );
    /*Text((await WhatsAppStickers.isWhatsAppInstalled).toString());*/
  }
}
