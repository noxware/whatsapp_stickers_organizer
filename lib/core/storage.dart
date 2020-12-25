import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

final Map<String, Future<dynamic>> _cache = {};

class StoredJson {
  final String _uniqueName;
  final dynamic Function() _dataCreator;

  // Cuando sobrescriba tener en cuenta de que siempre se debe
  // devolver algo de _cache y no crear weas nuevas.
  Future<dynamic> get data {
    return _cache[_uniqueName];
  }

  void set data(Future<dynamic> asyncValue) {
    _cache[_uniqueName] = asyncValue;
  }

  StoredJson(this._uniqueName, this._dataCreator) {
    if (!_cache.containsKey(_uniqueName)) {
      reload();
    }
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(
        '${dir.path}/${_uniqueName.trim().replaceAll(RegExp(r' +'), '_')}.json');
  }

  Future<void> reload() async {
    _cache[_uniqueName] = Future(() async {
      var file = await _getFile();
      if (await file.exists()) {
        //return jsonDecode(await file.readAsString());
        return jsonDecode(await file.readAsString());
      } else {
        return _dataCreator();
      }
    });
  }

  Future<void> saveToDisk() async {
    var file = await _getFile();
    var d = await data;

    await file.writeAsString(jsonEncode(d), flush: true);
  }
}

class IgnoredStickers extends StoredJson {
  IgnoredStickers() : super('ignored stickers', () => List<String>());

  @override
  Future<List<String>> get data async {
    var d = await super.data;
    return (d as List<dynamic>).cast<String>();
  }

  void set data(covariant Future<List<String>> asyncValue) {
    super.data = asyncValue;
  }
}
