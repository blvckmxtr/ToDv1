import 'dart:io';

class AdHelper {

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return '<ca-app-pub-3064319417594991/4334025628>';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }
}