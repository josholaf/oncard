import 'package:flutter/services.dart';

/// Plays card audio attachments through the platform channel.
/// Android only: the MainActivity side hosts a MediaPlayer.
class CardAudio {
  static const MethodChannel _channel = MethodChannel('oncard/share');

  static Future<void> play(String path) async {
    try {
      await _channel.invokeMethod<void>('playAudio', <String, dynamic>{
        'path': path,
      });
    } catch (_) {
      // Platform without audio support: ignore.
    }
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stopAudio');
    } catch (_) {
      // ignore
    }
  }
}
