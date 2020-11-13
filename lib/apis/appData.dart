import 'stickers.dart';

class AppData {
  String stickersFolder;
  List<String> fileNames;
  Set<String> ignored;
}

Future<AppData> loadAppData() async {
  final instance = AppData();

  instance.stickersFolder = await getStickersPath();
  instance.fileNames = await getStickersFiles();

  return instance;
}
