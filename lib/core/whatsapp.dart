import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:ext_storage/ext_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_whatsapp_stickers/flutter_whatsapp_stickers.dart';
import 'package:image/image.dart';

/// Global variables
final WhatsAppStickers _waStickers = WhatsAppStickers();
bool _preparedOwnStorage = false;

Directory _applicationDirectory;
Directory _stickerPacksDirectory;
File _stickerPacksConfigFile;
Map<String, dynamic> _stickerPacksConfig;
List<dynamic> _storedStickerPacks;

/// Generic exception thrown from this module.
class WhatsAppException implements Exception {
  String _message;

  WhatsAppException([String message = 'WhatsApp API problem.']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

/// Utility temporal function from the 'flutter_whatsapp_stickers' repository.
Future<void> _processResponse(
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

/// Makes sure to call [prepareOwnStorage()] one time during the program execution.
Future<void> prepareOwnStorageOnce() async {
  if (!_preparedOwnStorage) await prepareOwnStorage();
}

/// Makes the folder structure for the stickers.
Future<void> prepareOwnStorage() async {
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

  // Set flag
  _preparedOwnStorage = true;
}

/// Takes [name] and returns a unique compatible identifier.
String identifierFromName(String name) {}

/// Copies [stickers] to the internal app storage and makes a pack with them.
///
/// [name] is the name of the pack and [identifierFromName(name)] will be used
/// to generate an identifier.
Future<void> buildPack(String name, Iterable<File> stickers) async {
  await prepareOwnStorageOnce();

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

  // Add to global config
  _storedStickerPacks
      .removeWhere((item) => item['identifier'] == packConfig['identifier']);
  _storedStickerPacks.add(packConfig);

  // Update config file
  _stickerPacksConfig['sticker_packs'] = _storedStickerPacks;
  JsonEncoder encoder = new JsonEncoder.withIndent('  ');
  String contentsOfFile = encoder.convert(_stickerPacksConfig) + "\n";
  _stickerPacksConfigFile.deleteSync();
  _stickerPacksConfigFile.createSync(recursive: true);
  _stickerPacksConfigFile.writeAsStringSync(contentsOfFile, flush: true);

  _waStickers.updatedStickerPacks(identifier);
}

/// Installs an stored pack by [name].
Future<void> installPack(BuildContext context, String name) async {
  await prepareOwnStorageOnce();
  String identifier = name.toLowerCase();

  _waStickers.addStickerPack(
    packageName: WhatsAppPackage.Consumer,
    stickerPackIdentifier: identifier,
    stickerPackName: name,
    listener: (action, result, {error}) => _processResponse(
      action: action,
      result: result,
      error: error,
      //successCallback: checkInstallationStatuses,
      context: context,
    ),
  );
}

/// Checks WhatsApp correct installation.
///
/// Returns false if it is not installed or the installation
/// does not have the necessary elements.
Future<bool> checkWhatsAppInstallation() async {
  return WhatsAppStickers.isWhatsAppInstalled;
}

/// Gets the directory where the WhatsApp's cached stickers reside.
///
/// Needs external storage permission.
Future<Directory> get cachedStickersDirectory async {
  Directory stickersDirectory;

  try {
    stickersDirectory = Directory(path.join(
        await ExtStorage.getExternalStorageDirectory(),
        'WhatsApp',
        'Media',
        'WhatsApp Stickers'));
  } catch (e) {
    throw WhatsAppException(
        'A problem ocurred when trying to get the path to the WhatsApp\'s cached stickers directory. Details:\n\n$e');
  }

  if (!await stickersDirectory.exists())
    throw WhatsAppException(
        'Can not find the WhatsApp\'s cached stickers directory in the external storage.');

  return stickersDirectory;
}

/// Gets an iterable of WhatsApp's cached stickers files.
///
/// Needs external storage permission.
Future<Iterable<File>> get cachedStickers async {
  var stickersDirectory = await cachedStickersDirectory;

  List<File> stickersFiles = (await stickersDirectory
      .list()
      .where((f) => f.path.endsWith('.webp') && f is File)
      .map((f) => f as File)
      .toList());

  return stickersFiles;
}
