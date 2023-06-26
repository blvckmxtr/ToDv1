import 'package:appinio_swiper/appinio_swiper.dart';

class CustomSwiperController extends AppinioSwiperController {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  int cardsCount = 0; // Add this line to define the cardsCount variable

  void next({bool force = false}) {
    if (force || canSwipeForward()) {
      _currentIndex++;
    }
  }

  void previous({bool force = false}) {
    if (force || canSwipeBackward()) {
      _currentIndex--;
    }
  }

  bool canSwipeForward() {
    return _currentIndex < cardsCount - 1;
  }

  bool canSwipeBackward() {
    return _currentIndex > 0;
  }

  void reset() {
    _currentIndex = 0;
  }

  void jumpTo(int index) {
    _currentIndex = index;
  }
}
