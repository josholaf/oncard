import 'package:flutter/services.dart';

/// Native sharing bridge. The Android side lives in
/// android_override/MainActivity.kt and is installed by CI.
class DeckShare {
  static const MethodChannel _channel = MethodChannel('oncard/share');

  /// Shares [content] as a file through the Android share sheet.
  static Future<bool> shareFile(String fileName, String content,
      {String mimeType = 'text/csv'}) async {
    try {
      await _channel.invokeMethod('shareFile', {
        'fileName': fileName,
        'content': content,
        'mimeType': mimeType,
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}
