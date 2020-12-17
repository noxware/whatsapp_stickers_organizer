import 'dart:io';

import 'stickers.dart';
import '../core/whatsapp.dart';

class AppData {
  Future<Directory> stickersDirectory;
  Future<List<File>> stickerFiles;
  Whatsapp whatsapp = Whatsapp();

  AppData() {
    stickersDirectory = getCachedStickersDirectory();
    stickerFiles = getCachedStickerFiles();
  }
}
