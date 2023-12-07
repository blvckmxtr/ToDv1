import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return '<ca-app-pub-3940256099942544~3347511713>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
