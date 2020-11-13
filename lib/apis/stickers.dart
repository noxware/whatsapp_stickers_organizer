import 'os.dart';
import 'package:path/path.dart' as path;
import 'package:ext_storage/ext_storage.dart';
import 'dart:io';
import 'package:flutter_whatsapp_stickers/flutter_whatsapp_stickers.dart';

Future<bool> isWhatsAppInstalled() async {
  return WhatsAppStickers.isWhatsAppInstalled;
}

Future<String> getStickersPath() async {
  if (!await requestExternalStorageAccess()) return null;

  var stickersDirectory = Directory(path.join(
      await ExtStorage.getExternalStorageDirectory(),
      'WhatsApp',
      'Media',
      'WhatsApp Stickers'));

  return await stickersDirectory.exists() ? stickersDirectory.path : null;
}

Future<List<String>> getStickersFiles() async {
  var stickersPath = await getStickersPath();

  if (stickersPath == null) return null;

  var stickersFiles = (await Directory(stickersPath).list().toList())
      .map((f) => path.basename(f.path))
      .where((fname) => fname.endsWith('.webp'))
      .toList();

  return stickersFiles;
}
