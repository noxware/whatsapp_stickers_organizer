class WhatsAppNotInstalledException implements Exception {
  @override
  String toString() {
    return "WhatsApp does not seem to be installed.";
  }
}

class CachedStickersDirectoryNotFoundException implements Exception {
  final String _customMessage;

  CachedStickersDirectoryNotFoundException([this._customMessage]);

  @override
  String toString() {
    return _customMessage != null
        ? _customMessage
        : "Can not find the directory of the cached WhatsApp stickers.";
  }
}
