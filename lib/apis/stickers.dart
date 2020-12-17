import 'dart:convert';

import 'package:flutter/material.dart';

import './errors.dart';

import 'os.dart';
import 'package:path/path.dart' as path;
import 'package:ext_storage/ext_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_whatsapp_stickers/flutter_whatsapp_stickers.dart';
import 'package:image/image.dart';

final WhatsAppStickers _waStickers = WhatsAppStickers();

Future<bool> isWhatsAppInstalled() async {
  return WhatsAppStickers.isWhatsAppInstalled;
}

Future<Directory> getCachedStickersDirectory() async {
  if (!await requestExternalStorageAccess())
    throw CachedStickersDirectoryNotFoundException(
        'This app does not have permission to access the external storage.');

  Directory stickersDirectory;

  try {
    stickersDirectory = Directory(path.join(
        await ExtStorage.getExternalStorageDirectory(),
        'WhatsApp',
        'Media',
        'WhatsApp Stickers'));
  } catch (e) {
    throw CachedStickersDirectoryNotFoundException(
        'A problem ocurred when trying to get the path to the WhatsApp cached stickers directory. Details:\n\n$e');
  }

  if (!await stickersDirectory.exists())
    throw CachedStickersDirectoryNotFoundException(
        'Can not find the WhatsApp cached stickers directory in the external storage.');

  return stickersDirectory;
}

Future<List<File>> getCachedStickerFiles() async {
  var stickersDirectory = await getCachedStickersDirectory();

  List<File> stickersFiles = List<File>.from(
      (await stickersDirectory.list().toList())
          .where((f) => f.path.endsWith('.webp') && f is File));

  return stickersFiles;
}

Future<Directory> getStickerPacksDirectory() async {
  var applicationDirectory = await getApplicationDocumentsDirectory();
  var stickerPacksDirectory =
      Directory("${applicationDirectory.path}/sticker_packs");

  if (!await stickerPacksDirectory.exists()) {
    await stickerPacksDirectory.create(recursive: true);
  }

  return stickerPacksDirectory;
}

Future<File> getStickerPacksConfigFile() async {
  var stickerPacksDirectory = await getStickerPacksDirectory();
  Map<String, dynamic> stickerPacksConfig;

  var stickerPacksConfigFile =
      File("${stickerPacksDirectory.path}/sticker_packs.json");

  // Create the config file if it doesn't exist.
  if (!await stickerPacksConfigFile.exists()) {
    await stickerPacksConfigFile.create(recursive: true);

    stickerPacksConfig = {
      "android_play_store_link": "",
      "ios_app_store_link": "",
      "sticker_packs": [],
    };

    String contentsOfFile = jsonEncode(stickerPacksConfig) + "\n";
    await stickerPacksConfigFile.writeAsString(contentsOfFile, flush: true);
  }

  // Load sticker pack config
  /*stickerPacksConfig =
      jsonDecode((await stickerPacksConfigFile.readAsString()));
  storedStickerPacks = stickerPacksConfig['sticker_packs'];*/

  return stickerPacksConfigFile;
}

Future<Map<String, dynamic>> getStickerPacksConfig() async {
  var stickerPacksConfigFile = await getStickerPacksConfigFile();
  var stickerPacksConfig =
      jsonDecode((await stickerPacksConfigFile.readAsString()));
  //storedStickerPacks = stickerPacksConfig['sticker_packs'];

  return stickerPacksConfig;
}

Future<void> processResponse(
    {StickerPackResult action,
    bool result,
    String error,
    BuildContext context,
    Function successCallback}) async {
  print("_listener");
  print(action);
  print(result);
  print(error);

  SnackBar snackBar;

  switch (action) {
    case StickerPackResult.SUCCESS:
    case StickerPackResult.ADD_SUCCESSFUL:
    case StickerPackResult.ALREADY_ADDED:
      successCallback();
      break;
    case StickerPackResult.CANCELLED:
      snackBar = SnackBar(content: Text('Cancelled Sticker Pack Install'));
      break;
    case StickerPackResult.ERROR:
      snackBar = SnackBar(content: Text(error));
      break;
    case StickerPackResult.UNKNOWN:
      snackBar = SnackBar(content: Text('Unkown Error - check the logs'));
      break;
  }

  /// Display a snack bar
  if (snackBar != null && context != null) {
    Scaffold.of(context).showSnackBar(snackBar);
  }
}

Future<void> makeStickerPack(
    BuildContext context, String name, List<File> stickers) async {
  // Generate the sticker pack directory
  var dir = Directory("${(await getStickerPacksDirectory()).path}/$name");
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  // Copy the list of stickers to that folder
  for (File s in stickers) {
    await s.copy("${dir.path}/${path.basename(s.path)}");
  }

  // Make the first sticker the tray icon
  // TODO: Check animated support
  var firstSticker = decodeImage(await stickers[0].readAsBytes());
  var trayIcon = copyResize(firstSticker, width: 96, height: 96);
  await File("${dir.path}/tray-icon.png").writeAsBytes(encodePng(trayIcon));

  // Create config file
  var config = {
    "identifier": name,
    "name": name,
    "publisher": "You",
    "tray_image_file": "tray-icon.png", // !!!!!!!!!!!!!!
    "image_data_version": "1",
    "avoid_cache": false,
    "publisher_email": "",
    "publisher_website": "",
    "privacy_policy_website": "",
    "license_agreement_website": "",
    "stickers:": stickers
        .map((s) => {
              "image_file": path.basename(s.path),
              "emojis": ["☕"],
            })
        .toList(),
  };

  // Save
  await File("${dir.path}/config.json")
      .writeAsString(jsonEncode(config) + "\n", flush: true);

  // Load the common configuration and add the sticker pack
  var generalConfig = await getStickerPacksConfig();
  generalConfig['sticker_packs'] = (generalConfig['sticker_packs'] as List)
      .cast<Map<String, dynamic>>()
      .where((e) => e["identifier"] != config["identifier"])
      .toList();
  (generalConfig['sticker_packs'] as List<dynamic>).add(config);

  // Save
  (await getStickerPacksConfigFile()).writeAsString(
      jsonEncode(generalConfig) + "\n",
      flush: true,
      mode: FileMode.write);

  // Update sticker packs
  _waStickers.updatedStickerPacks(config["identifier"]);

  // Send sticker pack
  _waStickers.addStickerPack(
    packageName: WhatsAppPackage.Consumer,
    stickerPackIdentifier: config["identifier"],
    stickerPackName: name,
    listener: (action, result, {error}) => processResponse(
      action: action,
      result: result,
      error: error,
      context: context,
    ),
  );
}
