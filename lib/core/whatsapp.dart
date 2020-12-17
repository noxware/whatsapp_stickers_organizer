import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:path/path.dart' as path;
import 'package:ext_storage/ext_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_whatsapp_stickers/flutter_whatsapp_stickers.dart';
import 'package:image/image.dart';

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

class Whatsapp {
  // WhatsAppStickers instance.
  final WhatsAppStickers _waStickers = WhatsAppStickers();

  Directory _applicationDirectory;
  Directory _stickerPacksDirectory;
  File _stickerPacksConfigFile;
  Map<String, dynamic> _stickerPacksConfig;
  List<dynamic> _storedStickerPacks;

  Whatsapp() {
    prepareFolderStructure();
  }

  void prepareFolderStructure() async {
    _applicationDirectory = await getApplicationDocumentsDirectory();
    _stickerPacksDirectory =
        Directory("${_applicationDirectory.path}/sticker_packs");
    _stickerPacksConfigFile =
        File("${_stickerPacksDirectory.path}/sticker_packs.json");

    // Create the config file if it doesn't exist.
    if (!await _stickerPacksConfigFile.exists()) {
      _stickerPacksConfigFile.createSync(recursive: true);
      _stickerPacksConfig = {
        "android_play_store_link": "",
        "ios_app_store_link": "",
        "sticker_packs": [],
      };
      String contentsOfFile = jsonEncode(_stickerPacksConfig) + "\n";
      _stickerPacksConfigFile.writeAsStringSync(contentsOfFile, flush: true);
    }

    // Load sticker pack config
    _stickerPacksConfig =
        jsonDecode((await _stickerPacksConfigFile.readAsString()));
    _storedStickerPacks = _stickerPacksConfig['sticker_packs'];
  }

  void buildPack(String name, Iterable<File> stickers) async {
    String identifier = name.toLowerCase();
    Directory packDir = Directory("${_stickerPacksDirectory.path}/$identifier")
      ..createSync(recursive: true); // sync

    for (final File f in stickers) {
      f.copySync("${packDir.path}/${path.basename(f.path)}"
          .toLowerCase()); // TODO: async
    }

    var firstSticker = decodeImage(await stickers.first.readAsBytes());
    var trayIcon = copyResize(firstSticker, width: 96, height: 96);
    File("${packDir.path}/tray-icon.png")
        .writeAsBytesSync(encodePng(trayIcon)); // sync

    var packConfig = {
      "identifier": identifier,
      "name": name,
      "publisher": "You",
      "tray_image_file": "tray-icon.png",
      "image_data_version": "1",
      "avoid_cache": false,
      "publisher_email": "",
      "publisher_website":
          "https://github.com/Noxware/whatsapp_stickers_organizer",
      "privacy_policy_website":
          "https://github.com/Noxware/whatsapp_stickers_organizer",
      "license_agreement_website":
          "https://github.com/Noxware/whatsapp_stickers_organizer",
      "stickers": stickers
          .map((s) => {
                "image_file": path.basename(s.path).toLowerCase(),
                "emojis": ["☕"]
              })
          .toList()
    };
    File("${packDir.path}/config.json")
        .writeAsStringSync(jsonEncode(packConfig) + "\n", flush: true);

    /// Add to global config
    _storedStickerPacks
        .removeWhere((item) => item['identifier'] == packConfig['identifier']);
    _storedStickerPacks.add(packConfig);

    /// Update config file
    _stickerPacksConfig['sticker_packs'] = _storedStickerPacks;
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String contentsOfFile = encoder.convert(_stickerPacksConfig) + "\n";
    _stickerPacksConfigFile.deleteSync();
    _stickerPacksConfigFile.createSync(recursive: true);
    _stickerPacksConfigFile.writeAsStringSync(contentsOfFile, flush: true);

    _waStickers.updatedStickerPacks(identifier);
  }

  void installPack(BuildContext context, String name) async {
    String identifier = name.toLowerCase();

    _waStickers.addStickerPack(
      packageName: WhatsAppPackage.Consumer,
      stickerPackIdentifier: identifier,
      stickerPackName: name,
      listener: (action, result, {error}) => processResponse(
        action: action,
        result: result,
        error: error,
        //successCallback: checkInstallationStatuses,
        context: context,
      ),
    );
  }
}
