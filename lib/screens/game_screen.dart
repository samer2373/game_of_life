import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../widgets/grid_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameModel _gameModel = GameModel(rows: 20, columns: 20);
  Timer? _timer;
  bool _isRunning = false;
  bool _isPaused = false;
  double _speed = 1.0; // Default speed: 1 generation per second
  final TextEditingController _rowsController = TextEditingController(
    text: '20',
  );
  final TextEditingController _colsController = TextEditingController(
    text: '20',
  );
  final TextEditingController _importController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _stopSimulation();
    _rowsController.dispose();
    _colsController.dispose();
    _importController.dispose();
    super.dispose();
  }

  void _toggleCell(int row, int col) {
    setState(() {
      _gameModel.toggleCell(row, col);
    });
  }

  void _startSimulation() {
    if (_isRunning && !_isPaused) return;

    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    // Calculate milliseconds from the speed (which is in generations per second)
    int milliseconds = (1000 / _speed).round();

    _timer = Timer.periodic(Duration(milliseconds: milliseconds), (timer) {
      setState(() {
        _gameModel.updateToNextGeneration();
      });
    });
  }

  void _pauseSimulation() {
    if (!_isRunning || _isPaused) return;

    setState(() {
      _isPaused = true;
    });

    _timer?.cancel();
  }

  void _stopSimulation() {
    _timer?.cancel();

    setState(() {
      _isRunning = false;
      _isPaused = false;
    });
  }

  void _resetGrid() {
    _stopSimulation();

    setState(() {
      _gameModel.resetGrid();
    });
  }

  void _resizeGrid() {
    int rows = int.tryParse(_rowsController.text) ?? 20;
    int cols = int.tryParse(_colsController.text) ?? 20;

    // Ensure reasonable limits
    rows = rows.clamp(3, 100);
    cols = cols.clamp(3, 100);

    _rowsController.text = rows.toString();
    _colsController.text = cols.toString();

    _stopSimulation();

    setState(() {
      _gameModel.resizeGrid(rows, cols);
    });
  }

  void _importGrid() {
    try {
      final String importText = _importController.text.trim();
      if (importText.isEmpty) return;

      // Parse the imported text as a JSON array
      List<dynamic> jsonList = jsonDecode(importText) as List<dynamic>;
      List<List<bool>> newGrid =
          jsonList
              .map(
                (row) =>
                    (row as List<dynamic>)
                        .map((cell) => cell == 1 || cell == true)
                        .toList(),
              )
              .toList();

      _stopSimulation();

      setState(() {
        _gameModel.importGrid(newGrid);
        _rowsController.text = _gameModel.rows.toString();
        _colsController.text = _gameModel.columns.toString();
      });

      _importController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grid imported successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing grid: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conway\'s Game of Life'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridWidget(
                gridModel: _gameModel,
                onCellTap: _toggleCell,
                enabled: !_isRunning || _isPaused,
              ),
            ),
            _buildControlPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Game controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!_isRunning || _isPaused)
                    ElevatedButton(
                      onPressed: _startSimulation,
                      child: Text(_isPaused ? 'Resume' : 'Start'),
                    ),
                  if (_isRunning && !_isPaused)
                    ElevatedButton(
                      onPressed: _pauseSimulation,
                      child: const Text('Pause'),
                    ),
                  ElevatedButton(
                    onPressed: _stopSimulation,
                    child: const Text('Stop'),
                  ),
                  ElevatedButton(
                    onPressed: _resetGrid,
                    child: const Text('Reset'),
                  ),
                ],
              ),
          
              const SizedBox(height: 16),
          
              // Speed control
              Row(
                children: [
                  const Text('Speed: '),
                  Expanded(
                    child: Slider(
                      min: 0.2,
                      max: 5.0,
                      divisions: 48,
                      value: _speed,
                      label: '${_speed.toStringAsFixed(1)} gen/s',
                      onChanged: (value) {
                        setState(() {
                          _speed = value;
          
                          // If simulation is running, restart it with the new speed
                          if (_isRunning && !_isPaused) {
                            _timer?.cancel();
                            _startSimulation();
                          }
                        });
                      },
                    ),
                  ),
                  Text('${_speed.toStringAsFixed(1)} gen/s'),
                ],
              ),
          
              const SizedBox(height: 16),
          
              // Grid size controls
              Row(
                children: [
                  const Text('Grid Size: '),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _rowsController,
                      decoration: const InputDecoration(labelText: 'Rows'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const Text(' × '),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _colsController,
                      decoration: const InputDecoration(labelText: 'Cols'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _resizeGrid,
                    child: const Text('Apply'),
                  ),
                ],
              ),
          
              const SizedBox(height: 16),
          
              // Import controls
              ExpansionTile(
                title: const Text('Import Initial State'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _importController,
                          decoration: const InputDecoration(
                            labelText: 'Paste JSON array configuration',
                            hintText: '[[0,1,0],[1,1,1],[0,1,0]]',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _importGrid,
                          child: const Text('Import'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
