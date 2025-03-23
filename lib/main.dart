import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const GameOfLifeApp());
}

class GameOfLifeApp extends StatelessWidget {
  const GameOfLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conway\'s Game of Life',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
