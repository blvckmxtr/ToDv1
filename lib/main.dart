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
  final Map<String, bool> _isPressed = {
    'rewind': false,
    'color_wheel': false,
    'shuffle': false,
  };

  late AnimationController _animationController;
  late Animation<double> _animation;
  String? _selectedColor; // Track the selected color for filtering

  @override
  void initState() {
    super.initState();
    questions = List<Map<String, String>>.from(questionsData)..shuffle(); // Use your questions list here

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300), // Increase the animation duration
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut, // Use a different curve for a more subtle animation
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void shuffleCards() {
    setState(() {
      questions.shuffle();
      _animationController.forward(from: 0.0); // Trigger the animation when shuffling the cards
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
            ScaleTransition(
              scale: _animation,
              child: Center( // Center the swiper
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (BuildContext context, Widget? child) {
                      return Transform.scale(
                        scale: _animation.value - 0.02, // Adjust the scale to make the animation more subtle
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
                            if (_selectedColor != null && questions[index]['color'] != _selectedColor) {
                              return Container(); // Skip cards with different color if a color is selected
                            }
                            return Container(
                              width: 300, // Set a fixed width
                              height: 400, // Set a fixed height
                              decoration: BoxDecoration(
                                gradient: getGradient(questions[index]['color']), // Set card gradient based on question color
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25), // Adjust the shadow color and opacity
                                    blurRadius: 10, // Adjust the blur radius
                                    spreadRadius: 2, // Adjust the spread radius
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(30.10), // Increase padding
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
                      );
                    },
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildButton('assets/rewind_line.svg', () {
                  controller.unswipe();
                }, 'rewind'),
                buildButton('assets/color_wheel.svg', () {
                  // Add your color wheel functionality here
                }, 'color_wheel', applyColorFilter: true),

                buildButton('assets/shuffle.svg', shuffleCards, 'shuffle'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector buildButton(String asset, VoidCallback onPressed, String key, {bool applyColorFilter = true}) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          _isPressed[key] = true;
        });
        onPressed();
      },
      onTapUp: (details) {
        setState(() {
          _isPressed[key] = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed[key] = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.bounceOut,
        width: (_isPressed[key] ?? false) ? 40 : 50,
        height: (_isPressed[key] ?? false) ? 40 : 50,
        child: applyColorFilter ? ColorFiltered(colorFilter: const ColorFilter.matrix(<double>[
          -1, 0, 0, 0, 255,
          0, -1, 0, 0, 255,
          0, 0, -1, 0, 255,
          0, 0, 0, 1, 0,
        ]),
          child: SvgPicture.asset(asset),
        ) : SvgPicture.asset(asset),
      ),
      onTap: () {
        if (key == 'color_wheel') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Select Color'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: getColorOptions(),
                  ),
                ),
              );
            },
          );
        } else {
          onPressed();
        }
      },
    );
  }

  List<Color> colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.yellow];
  int colorIndex = 0;


  List<Widget> getColorOptions() {
    return [
      buildColorOption('All Colors'), // Add an option for all colors
      buildColorOption('Red'),
      buildColorOption('Blue'),
      buildColorOption('Orange'),
      buildColorOption('Green'),
      buildColorOption('Yellow'),
    ];
  }

  Widget buildColorOption(String color) {
    final bool isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color == 'All Colors' ? null : color;
          Navigator.pop(context);
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[300] : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          color,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
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
    switch (color) {
      case 'Yellow':
      case 'LightBlue':
      case 'White':
        return Colors.black;
      default:
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