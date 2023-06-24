import 'dart:developer';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'questions.dart'; // Import your questions.dart file here
import 'package:flutter_svg/flutter_svg.dart'; // Import the flutter_svg package

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final AppinioSwiperController controller = AppinioSwiperController();
  List<Map<String, String>> questions = [];
  bool _isPressed = false; // Add a new state variable

  @override
  void initState() {
    super.initState();
    questions = List<Map<String, String>>.from(questionsData)..shuffle(); // Use your questions list here
  }

  void shuffleCards() {
    setState(() {
      questions.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent, // Make the background transparent
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Colors.black87], // Soft gradient black background
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the column
          children: [
            Center( // Center the swiper
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: AppinioSwiper(
                  backgroundCardsCount: 3,
                  swipeOptions: const AppinioSwipeOptions.all(),
                  unlimitedUnswipe: true,
                  controller: controller,
                  unswipe: _unswipe,
                  onSwiping: (AppinioSwiperDirection direction) {
                    debugPrint(direction.toString());
                  },
                  onSwipe: _swipe,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50, // Increase horizontal padding
                    vertical: 100, // Increase vertical padding
                  ),
                  onEnd: _onEnd,
                  cardsCount: questions.length,
                  cardsBuilder: (BuildContext context, int index) {
                    return Container(
                      width: 300, // Set a fixed width
                      height: 400, // Set a fixed height
                      decoration: BoxDecoration(
                        gradient: getGradient(questions[index]['color']), // Set card gradient based on question color
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(30.10), // Increasepadding for the text
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start, // Align the text to the top
                          crossAxisAlignment: CrossAxisAlignment.center, // Center the text horizontally
                          children: [
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                questions[index]['type']!,
                                style: TextStyle(
                                  fontFamily: 'JUST Sans Variable', // Replace with your custom font
                                  fontSize: 32.0,
                                  color: getTextColor(questions[index]['color']), // Set text color based on question color
                                  fontWeight: FontWeight.normal, // Make text bold
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                questions[index]['question']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'JUST Sans Variable', // Replace with your custom font
                                  fontSize: 26.0,
                                  color: getTextColor(questions[index]['color']), // Set text color based on question color
                                  fontWeight: FontWeight.normal, // Make text bold
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            GestureDetector(
              onTapDown: (details) {
                setState(() {
                  _isPressed = true;
                });
                controller.unswipe();
              },
              onTapUp: (details) {
                setState(() {
                  _isPressed = false;
                });
              },
              onTapCancel: () {
                setState(() {
                  _isPressed = false;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                curve: Curves.bounceOut,
                width: _isPressed ? 60 : 70,
                height: _isPressed ? 60 : 70,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    -1, 0, 0, 0, 255,
                    0, -1, 0, 0, 255,
                    0, 0, -1, 0, 255,
                    0, 0, 0, 1, 0,
                  ]),
                  child: SvgPicture.asset('assets/rewind_line.svg'),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: shuffleCards,
              child: const Text('Shuffle Cards'),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient? getGradient(String? color) {
    switch (color) {
      case 'Blue':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[300]!, Colors.blue[700]!],
        );
      case 'Orange':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange[300]!, Colors.orange[700]!],
        );
      case 'Green':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green[300]!, Colors.green[700]!],
        );
      case 'Yellow':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.yellow[300]!, Colors.yellow[700]!],
        );
      case 'Red':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red[300]!, Colors.red[700]!],
        );
      default:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[300]!, Colors.grey[700]!],
        ); // Default color
    }
  }

  Color getTextColor(String? color) {
    if (color == 'Yellow') {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  void _swipe(int index, AppinioSwiperDirection direction) {
    log("the card was swiped to the: ${direction.name}");
  }

  void _unswipe(bool unswiped) {
    if (unswiped) {
      log("SUCCESS: card was unswiped");
    } else {
      log("FAIL: no card left to unswipe");
    }
  }

  void _onEnd() {
    log("end reached!");
  }
}
