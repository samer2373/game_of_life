import 'package:flutter/material.dart';

class GameOfLifeGrid extends StatefulWidget {
  final int rows;
  final int columns;

  const GameOfLifeGrid({
    super.key,
    required this.rows,
    required this.columns,
  });

  @override
  _GameOfLifeGridState createState() => _GameOfLifeGridState();
}

class _GameOfLifeGridState extends State<GameOfLifeGrid> {
  late List<List<bool>> grid;

  @override
  void initState() {
    super.initState();
    grid = List.generate(widget.rows, (_) => List.generate(widget.columns, (_) => false));
  }

  void toggleCellState(int row, int col) {
    setState(() {
      grid[row][col] = !grid[row][col];
    });
  }

  void importState(List<List<bool>> newState) {
    setState(() {
      grid = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.columns,
      ),
      itemCount: widget.rows * widget.columns,
      itemBuilder: (context, index) {
        final row = index ~/ widget.columns;
        final col = index % widget.columns;
        return GestureDetector(
          onTap: () => toggleCellState(row, col),
          child: Container(
            margin: const EdgeInsets.all(1.0),
            color: grid[row][col] ? Colors.black : Colors.white,
          ),
        );
      },
    );
  }
}