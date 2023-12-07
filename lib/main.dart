import 'dart:developer' as developer;
import 'dart:math';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom_swiper_controller.dart';
import 'questions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Defines Orientation Vertical
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(const MyApp()));
  MobileAds.instance.initialize();
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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
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

  Color currentCardColor = Colors.blue; // Add this line

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

  String getIconFromCategory(String? color) {
    switch (color) {
      case 'Blue':
        return 'assets/blue_icon.png';
      case 'Orange':
        return 'assets/orange_icon.png';
      case 'Green':
        return 'assets/green_icon.png';
      case 'Yellow':
        return 'assets/yellow_icon.png';
      case 'Red':
        return 'assets/red_icon.png';
      default:
        return 'assets/default_icon.png';
    }
  }

  @override
  void initState() {
    super.initState();

    // Shuffle allQuestions
    allQuestions = List<Map<String, String>>.from(questionsData)..shuffle();

    // Insert the instructional card
    filteredQuestions.insert(
      0,
      {
        'type': "Truth or Dare",
        'question': 'Each color is a different intensity. \n',
        'color': 'Blue',
      },
    );

    // Find and insert a random red card
    Map<String, String> redCard =
        allQuestions.firstWhere((card) => card['color'] == 'Red');
    filteredQuestions.insert(1, redCard);
    allQuestions.remove(redCard); // Remove the inserted card from allQuestions

    // Find and insert a random blue card
    Map<String, String> blueCard =
        allQuestions.firstWhere((card) => card['color'] == 'Blue');
    filteredQuestions.insert(2, blueCard);
    allQuestions.remove(blueCard); // Remove the inserted card from allQuestions

    // Find and insert a random yellow card
    Map<String, String> yellowCard =
        allQuestions.firstWhere((card) => card['color'] == 'Yellow');
    filteredQuestions.insert(3, yellowCard);
    allQuestions
        .remove(yellowCard); // Remove the inserted card from allQuestions

    // Remove the first occurrence of red, blue, and yellow cards from allQuestions
    redCard = allQuestions.firstWhere((card) => card['color'] == 'Red');
    blueCard = allQuestions.firstWhere((card) => card['color'] == 'Blue');
    yellowCard = allQuestions.firstWhere((card) => card['color'] == 'Yellow');
    allQuestions.remove(redCard);
    allQuestions.remove(blueCard);
    allQuestions.remove(yellowCard);

    // Add the rest of the cards
    filteredQuestions.addAll(allQuestions);

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

    myBanner = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', //TEST ADS
      //adUnitId: 'ca-app-pub-3064319417594991/3226829647',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          // Handle the ad load failure
          developer.log('Ad failed to load: $error');
          ad.dispose();
        },
        // Other listeners...
      ),
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
      colorIndex = colors.indexOf(getCardColor(filteredQuestions[0]['color']));
      _animationController.forward(from: 0.0);
    });

    // Simulate swiping right after shuffling to update the background gradient
    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        controller.swipeUp();
      },
    );
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        controller.swipeLeft();
      },
    );
    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        controller.swipeRight();
      },
    );
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

  Color getCardColor(String? color) {
    switch (color) {
      case 'Blue':
        return Colors.blue;
      case 'Orange':
        return Colors.orange;
      case 'Green':
        return Colors.green;
      case 'Yellow':
        return Colors.yellow;
      case 'Red':
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  GestureDetector buildColorButton(Color color) {
    bool isAllColors = _selectedColor == 'All Colors';
    Color color = colors[colorIndex];

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
      if (filteredQuestions.isNotEmpty) {
        _swipe(0, AppinioSwiperDirection.right); // Simulate a swipe
      }
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
      lastIndices[_selectedColor] =
          0; // Reset the last index for the current color
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
        child: Stack(
          children: [
            // Gradient background
            AnimatedContainer(
              duration: const Duration(
                  milliseconds: 450), // Adjust duration as needed
              curve: Curves.easeOut, // Adjust curve as needed
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    currentCardColor,
                  ],
                  stops: const [0.7, 1.0], // Adjust these values as needed
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 35.0), // Adjust this value as needed
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
                                child: GestureDetector(
                                  onDoubleTap: () {
                                    controller.unswipe();
                                  },
                                  child: AppinioSwiper(
                                    backgroundCardsCount: 3,
                                    swipeOptions:
                                        const AppinioSwipeOptions.all(),
                                    unlimitedUnswipe: true,
                                    controller: controller,
                                    unswipe: _unswipe,
                                    onSwiping:
                                        (AppinioSwiperDirection direction) {
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
                                              filteredQuestions[index]
                                                  ['color']),
                                          borderRadius:
                                              BorderRadius.circular(36.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.25),
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
                                              if (index == 0 &&
                                                  filteredQuestions[index]
                                                          ['type'] ==
                                                      "Truth or Dare")
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  height:
                                                      200, // Adjust this value as needed
                                                  child: Image.asset(
                                                      'assets/logo.png',
                                                      fit: BoxFit.fitHeight),
                                                ),
                                              Align(
                                                alignment: Alignment.topCenter,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .only(
                                                      top:
                                                          20.0), // Adjust this value as needed
                                                  child: Text(
                                                    filteredQuestions[index]
                                                        ['type']!,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'JUST Sans Variable',
                                                      fontSize: 32.0,
                                                      color: getTextColor(
                                                          filteredQuestions[
                                                              index]['color']),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                  height:
                                                      8), // Adjust this value as needed
                                              Align(
                                                alignment: index == 0
                                                    ? Alignment.centerLeft
                                                    : Alignment.center,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .only(
                                                      top:
                                                          10.0), // Adjust this value as needed
                                                  child: AutoSizeText(
                                                    filteredQuestions[index]
                                                        ['question']!,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'JUST Sans Variable',
                                                      fontSize: index == 0
                                                          ? 24.0
                                                          : 30.0,
                                                      color: getTextColor(
                                                          filteredQuestions[
                                                              index]['color']),
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    minFontSize:
                                                        16, // the minimum font size
                                                    maxFontSize:
                                                        48, // the maximum font size
                                                    maxLines:
                                                        7, // the maximum number of lines
                                                  ),
                                                ),
                                              ),

                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .only(
                                                      bottom:
                                                          20.0), // Add padding here
                                                  child: index == 0 &&
                                                          filteredQuestions[
                                                                      index]
                                                                  ['type'] ==
                                                              "Truth or Dare"
                                                      ? Container() // Render an empty container for the first card
                                                      : Align(
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          child: Image.asset(
                                                              getIconFromCategory(
                                                                  filteredQuestions[
                                                                          index]
                                                                      [
                                                                      'color']),
                                                              fit: BoxFit
                                                                  .scaleDown),
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
    lastIndices[_selectedColor] =
        index + 1; // Update the last index for the current color

    // Update the current card color
    setState(() {
      currentCardColor = getCardColor(filteredQuestions[index]['color']);
    });
  }

  void _unswipe(bool unswiped) {
    if (unswiped) {
      developer.log("SUCCESS: The card was unswiped");
      lastIndices[_selectedColor] = max(
          0,
          (lastIndices[_selectedColor] ?? 0) -
              1); // Update the last index for the current color
      if (lastIndices[_selectedColor]! > 0) {
        String previousCardColor =
            filteredQuestions[lastIndices[_selectedColor]! - 1]['color'] ??
                'All Colors';
        setState(() {
          currentCardColor = getCardColor(previousCardColor);
        });
      } else {
        setState(() {
          currentCardColor = getCardColor(_selectedColor);
        });
      }
    } else {
      developer.log("FAIL: No card left to unswipe");
    }
  }

  void _onEnd() {
    developer.log("All cards have been swiped");
  }
}
