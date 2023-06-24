import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'questions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Game',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentCardIndex = 0;

  final List<String> mockCards = questions;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SizedBox(
          width: 300,
          height: 540,
          child: Swiper(
            itemBuilder: (BuildContext context, int index) {
              return FlipCard(
                direction: FlipDirection.VERTICAL,
                front: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                ),
                back: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        mockCards[index],
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'JUST Sans Variable'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            },
            itemCount: mockCards.length,
            itemWidth: 280.0,
            itemHeight: 380.0,
            layout: SwiperLayout.STACK,
            scale: 1.1,
          ),
        ),
      ),
    );
  }
}
