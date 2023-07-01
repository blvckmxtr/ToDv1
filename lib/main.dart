import 'dart:developer' as developer;
import 'dart:math';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom_swiper_controller.dart';
import 'questions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


void main() {
  // Step 2
  WidgetsFlutterBinding.ensureInitialized();

  // Step 3
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(const MyApp()));
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(child: HomeScreen()),
    );
  }
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final CustomSwiperController controller = CustomSwiperController();
  List<Map<String, String>> allQuestions = [];
  List<Map<String, String>> filteredQuestions = [];
  String _selectedColor = 'All Colors';
  final Map<String, bool> _isPressed = {
    'rewind': false,
    'color_wheel': false,
    'shuffle': false,
  };

  late BannerAd myBanner; // Add this line

  late AnimationController _animationController;
  late Animation<double> _animation;
  int colorIndex = 0;
  List<Color> colors = [
    Colors.white,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.yellow,
  ];

  double titleTopMargin = 0;
  double questionTopMargin = 0;

  // Add a Map to keep track of the index for each color
  Map<String, int> colorIndices = {
    'All Colors': 0,
    'Red': 0,
    'Blue': 0,
    'Green': 0,
    'Orange': 0,
    'Yellow': 0,
  };

  Map<String, int> lastIndices = {
    'All Colors': 0,
    'Red': 0,
    'Blue': 0,
    'Green': 0,
    'Orange': 0,
    'Yellow': 0,
  };

  @override
  void initState() {
    super.initState();
    allQuestions = List<Map<String, String>>.from(questionsData)..shuffle();
    filteredQuestions = List<Map<String, String>>.from(allQuestions);

    filteredQuestions.insert(
      0,
      {
        'type': "Let's play a game.",
        'question': 'Each color is a different intensity.',
        'color': 'Blue',
      },
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    myBanner = BannerAd( // Add this block
      adUnitId: 'ca-app-pub-3064319417594991/4334025628',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );

    myBanner.load(); // Add this line
  }




  @override
  void dispose() {
    _animationController.dispose();
    myBanner.dispose(); // Add this line
    super.dispose();
  }

  void shuffleCards() {
    setState(() {
      filteredQuestions.shuffle();
      _animationController.forward(from: 0.0);
    });
  }

  GestureDetector buildButton(
      String asset,
      VoidCallback onPressed,
      String key,
      Color color, {
        bool applyColorFilter = true,
      }) {
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
        child: applyColorFilter
            ? ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            -1,
            0,
            0,
            0,
            255,
            0,
            -1,
            0,
            0,
            255,
            0,
            0,
            -1,
            0,
            255,
            0,
            0,
            0,
            1,
            0,
          ]),
          child: SvgPicture.asset(asset),
        )
            : SvgPicture.asset(asset, color: color),
      ),
      onTap: () {
        if (key == 'color_wheel') {
          cycleColors();
        } else {
          onPressed();
        }
      },
    );
  }

  GestureDetector buildColorButton(Color color) {
    bool isAllColors = _selectedColor == 'All Colors';

    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          _isPressed['color_wheel'] = true;
        });
        cycleColors();
      },
      onTapUp: (details) {
        setState(() {
          _isPressed['color_wheel'] = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed['color_wheel'] = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.bounceOut,
        width: (_isPressed['color_wheel'] ?? false) ? 40 : 50,
        height: (_isPressed['color_wheel'] ?? false) ? 40 : 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isAllColors ? getMulticolorGradient() : null,
          color: isAllColors ? null : color,
        ),
        child: SvgPicture.asset(
          'assets/color_wheel.svg',
          color: isAllColors ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  LinearGradient getMulticolorGradient() {
    return const LinearGradient(
      colors: [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.yellow,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  void cycleColors() {
    setState(() {
      controller.jumpTo(0); // Reset the swiper's index to 0
      colorIndex = (colorIndex + 1) % colors.length;
      switch (colors[colorIndex]) {
        case Colors.red:
          _selectedColor = 'Red';
          break;
        case Colors.blue:
          _selectedColor = 'Blue';
          break;
        case Colors.green:
          _selectedColor = 'Green';
          break;
        case Colors.orange:
          _selectedColor = 'Orange';
          break;
        case Colors.yellow:
          _selectedColor = 'Yellow';
          break;
        default:
          _selectedColor = 'All Colors';
          break;
      }
      filterQuestions();
    });
  }

  void filterQuestions() {
    setState(() {
      if (_selectedColor == 'All Colors') {
        filteredQuestions = List<Map<String, String>>.from(allQuestions);
      } else {
        filteredQuestions = allQuestions
            .where((question) => question['color'] == _selectedColor)
            .toList();
      }
      controller.jumpTo(0); // Reset the swiper's index to 0
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Colors.black],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
            padding: const EdgeInsets.only(top: 30.0), // Adjust this value as needed
            child: SizedBox(
              width: myBanner.size.width.toDouble(),
              height: myBanner.size.height.toDouble(),
              child: AdWidget(ad: myBanner),
            ),
          ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: ScaleTransition(
                  scale: _animation,
                  child: Center(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (BuildContext context, Widget? child) {
                          return Transform.scale(
                            scale: _animation.value - 0.02,
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
                                horizontal: 30,
                                vertical: 50,
                              ),
                              onEnd: _onEnd,
                              cardsCount: filteredQuestions.length,
                              cardsBuilder:
                                  (BuildContext context, int index) {
                                return Container(
                                  width: 500,
                                  height: 500,
                                  decoration: BoxDecoration(
                                    gradient: getGradient(
                                        filteredQuestions[index]['color']),
                                    borderRadius:
                                    BorderRadius.circular(36.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(30.40),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 10),
                                        if (index == 0&& filteredQuestions[index]['type'] == "Let's play a game.")
                                          Expanded(
                                            child: Transform.translate(
                                              offset: Offset(0,-25), // Adjust this value to change the size of the logo
                                              child: Image.asset(
                                                'assets/logo.png',
                                                fit: BoxFit.scaleDown,
                                              ),
                                            ),
                                          ),
                                        Align(
                                          alignment: Alignment.topCenter,
                                          child: Text(
                                            filteredQuestions[index]['type']!,
                                            style: TextStyle(
                                              fontFamily:
                                              'JUST Sans Variable',
                                              fontSize: 32.0,
                                              color: getTextColor(
                                                  filteredQuestions[index]
                                                  ['color']),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 26),
                                        Align(
                                          alignment: index == 0
                                              ? Alignment.centerLeft
                                              : Alignment.center,
                                          child: Text(
                                            filteredQuestions[index]
                                            ['question']!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily:
                                              'JUST Sans Variable',
                                              fontSize:
                                              index == 0 ? 24.0 : 30.0,
                                              color: getTextColor(
                                                  filteredQuestions[index]
                                                  ['color']),
                                              fontWeight: FontWeight.normal,
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
              ),
            ),
            SizedBox(
              height: 100.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton('assets/rewind_line.svg', () {
                    controller.unswipe();
                  }, 'rewind', Colors.white),
                  buildColorButton(colors[colorIndex]),
                  buildButton('assets/shuffle.svg', shuffleCards, 'shuffle',
                      Colors.white),
                ],
              ),
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
          colors: [Colors.orange[300]!, Colors.orange[800]!],
        );
      case 'Green':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green[300]!, Colors.green[800]!],
        );
      case 'Yellow':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.yellow[400]!, Colors.yellow[700]!],
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
        );
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
    developer.log("The card was swiped to the ${direction.name}");
    lastIndices[_selectedColor] = index + 1; // Update the last index for the current color
  }

  void _unswipe(bool unswiped) {
    if (unswiped) {
      developer.log("SUCCESS: The card was unswiped");
      lastIndices[_selectedColor] = max(0, lastIndices[_selectedColor] ?? 0 - 1); // Update the last index for the current color
    } else {
      developer.log("FAIL: No card left to unswipe");
    }
  }

  void _onEnd() {
    developer.log("All cards have been swiped");
  }

}

