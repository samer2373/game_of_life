import 'package:flutter/material.dart';
import 'grid.dart';

void main() {
  runApp(const GameOfLifeApp());
}

class GameOfLifeApp extends StatelessWidget {
  const GameOfLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game of Life',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GameOfLifeHomePage(),
    );
  }
}

class GameOfLifeHomePage extends StatefulWidget {
  const GameOfLifeHomePage({super.key});

  @override
  _GameOfLifeHomePageState createState() => _GameOfLifeHomePageState();
}

class _GameOfLifeHomePageState extends State<GameOfLifeHomePage> {
  bool isRunning = false;
  double speed = 1.0; // Default speed: 1 generation per second
  int rows = 10;
  int columns = 10;

  void startGame() {
    setState(() {
      isRunning = true;
    });
  }

  void pauseGame() {
    setState(() {
      isRunning = false;
    });
  }

  void stopGame() {
    setState(() {
      isRunning = false;
      // Reset logic for the grid can be added here.
    });
  }

  void updateSpeed(double newSpeed) {
    setState(() {
      speed = newSpeed;
    });
  }

  void updateGridSize(int newRows, int newColumns) {
    setState(() {
      rows = newRows;
      columns = newColumns;
    });
  }

  void importInitialState() {
    final initialState = List.generate(
      rows,
      (i) => List.generate(columns, (j) => (i + j) % 2 == 0), // Example pattern
    );
    setState(() {
      // Access the grid's importState method
      final gridKey = GlobalKey<_GameOfLifeGridState>();
      gridKey.currentState?.importState(initialState);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game of Life'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GameOfLifeGrid(
              key: GlobalKey<_GameOfLifeGridState>(),
              rows: rows,
              columns: columns,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: isRunning ? null : startGame,
                child: const Text('Start'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: isRunning ? pauseGame : null,
                child: const Text('Pause'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: stopGame,
                child: const Text('Stop'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: importInitialState,
                child: const Text('Import State'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Speed:'),
                Slider(
                  value: speed,
                  min: 0.1,
                  max: 5.0,
                  divisions: 49,
                  label: '${speed.toStringAsFixed(1)}x',
                  onChanged: updateSpeed,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Rows:'),
                SizedBox(
                  width: 50,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onSubmitted: (value) {
                      final newRows = int.tryParse(value) ?? rows;
                      updateGridSize(newRows, columns);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                const Text('Columns:'),
                SizedBox(
                  width: 50,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onSubmitted: (value) {
                      final newColumns = int.tryParse(value) ?? columns;
                      updateGridSize(rows, newColumns);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
