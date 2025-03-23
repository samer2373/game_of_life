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
  double _speed = 1.0; 
  final TextEditingController _rowsController = TextEditingController(
    text: '20',
  );
  final TextEditingController _colsController = TextEditingController(
    text: '20',
  );
  final TextEditingController _importController = TextEditingController();
  bool _gameEnded = false;
  int _finalGenerationCount = 0;
  String? _importError;

  static const int _minGridSize = 4;
  static const int _maxGridSize = 30;

  String? _rowsError;
  String? _colsError;

  @override
  void initState() {
    super.initState();
    _importController.addListener(_validateJsonInput);

    // _rowsController.addListener(_validateGridSizeInput);
    // _colsController.addListener(_validateGridSizeInput);
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
    // if (_isRunning && !_isPaused) return;

    setState(() {
      _isRunning = true;
      _isPaused = false;
      _gameEnded = false;
    });

    int milliseconds = (1000 / _speed).round();

    _timer = Timer.periodic(Duration(milliseconds: milliseconds), (timer) {
      setState(() {
        bool hasChanged = _gameModel.updateToNextGeneration();

        if (!hasChanged) {
          _finalGenerationCount = _gameModel.generationCount;
          _gameEnded = true;
          _stopSimulation();
        }
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
      _gameEnded = false;
    });
  }

  void _resizeGrid() {
    int rows = int.tryParse(_rowsController.text) ?? 20;
    int cols = int.tryParse(_colsController.text) ?? 20;

    rows = rows.clamp(_minGridSize, _maxGridSize);
    cols = cols.clamp(_minGridSize, _maxGridSize);
    _rowsError = null;
    _colsError = null;

    _rowsController.text = rows.toString();
    _colsController.text = cols.toString();

    _stopSimulation();

    setState(() {
      _gameModel.resizeGrid(rows, cols);
    });
  }

  void _validateJsonInput() {
    if (_importController.text.trim().isEmpty) {
      setState(() {
        _importError = null;
      });
      return;
    }

    try {
      final jsonText = _importController.text.trim();
      final decoded = jsonDecode(jsonText);

      if (decoded is! List) {
        setState(() {
          _importError = 'Input must be a JSON array';
        });
        return;
      }

      if (decoded.isEmpty) {
        setState(() {
          _importError = 'Grid cannot be empty';
        });
        return;
      }

      int rowLength = -1;
      for (var i = 0; i < decoded.length; i++) {
        final row = decoded[i];
        if (row is! List) {
          setState(() {
            _importError = 'Row $i must be an array';
          });
          return;
        }

        if (rowLength == -1) {
          rowLength = row.length;
        } else if (row.length != rowLength) {
          setState(() {
            _importError = 'All rows must have the same length';
          });
          return;
        }

        for (var j = 0; j < row.length; j++) {
          final cell = row[j];
          if (cell != 0 && cell != 1 && cell != true && cell != false) {
            setState(() {
              _importError = 'Cell values must be 0, 1, true, or false';
            });
            return;
          }
        }
      }

      setState(() {
        _importError = null;
      });
    } catch (e) {
      setState(() {
        _importError = 'Invalid JSON format';
      });
    }
  }

  void _importGrid() {
    try {
      final String importText = _importController.text.trim();
      if (importText.isEmpty) return;

      _validateJsonInput();
      if (_importError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_importError!), backgroundColor: Colors.red),
        );
        return;
      }

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

  void _dismissEndScreen() {
    setState(() {
      _gameEnded = false;
    });
  }

  void _validateGridSizeInput() {
    setState(() {
      final rowsValue = int.tryParse(_rowsController.text);
      if (rowsValue == null) {
        _rowsError = 'Invalid number';
      } else if (rowsValue < _minGridSize) {
        _rowsError = 'Min is $_minGridSize';
      } else if (rowsValue > _maxGridSize) {
        _rowsError = 'Max is $_maxGridSize';
      } else {
        _rowsError = null;
      }

      final colsValue = int.tryParse(_colsController.text);
      if (colsValue == null) {
        _colsError = 'Invalid number';
      } else if (colsValue < _minGridSize) {
        _colsError = 'Min is $_minGridSize';
      } else if (colsValue > _maxGridSize) {
        _colsError = 'Max is $_maxGridSize';
      } else {
        _colsError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conway\'s Game of Life'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Stack(
        children: [
          SafeArea(
            child:
                isWideScreen
                    ? _buildHorizontalLayout()
                    : _buildVerticalLayout(),
          ),
          if (_gameEnded) _buildEndScreen(),
        ],
      ),
    );
  }

  Widget _buildHorizontalLayout() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridWidget(
                gridModel: _gameModel,
                onCellTap: _toggleCell,
                enabled: !_isRunning || _isPaused,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildControlPanel(
            isFullHeight: true,
          ), 
        ),
      ],
    );
  }

  Widget _buildVerticalLayout() {
    return Center(
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
          _buildControlPanel(
            isFullHeight: false,
          ), 
        ],
      ),
    );
  }

  Widget _buildControlPanel({bool isFullHeight = false}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      height:
          isFullHeight
              ? double.infinity
              : null, 
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, 
            mainAxisAlignment:
                MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.spaceEvenly,
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

              Row(
                children: [
                  const Text('Grid Size: '),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _rowsController,
                      onChanged: (value) => _validateGridSizeInput(),
                      decoration: InputDecoration(
                        labelText: 'Rows',
                        helperText: '4-30',
                        counterText: '',
                        errorText: _rowsError,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const Text(' × '),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _colsController,
                      onChanged: (value) => _validateGridSizeInput(),
                      decoration: InputDecoration(
                        labelText: 'Cols',
                        helperText: '4-30',
                        counterText: '',
                        errorText: _colsError,
                      ),
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

              Card(
                child: ExpansionTile(
                  title: const Text('Import Initial State'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _importController,
                            decoration: InputDecoration(
                              labelText: 'Paste JSON array configuration',
                              hintText: '[[0,1,0],[1,1,1],[0,1,0]]',
                              errorText:
                                  _importError, 
                              errorMaxLines:
                                  3, 
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed:
                                _importError == null
                                    ? _importGrid
                                    : null, 
                            child: const Text('Import'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEndScreen() {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Card(
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.flag_rounded, size: 64.0, color: Colors.green),
              const SizedBox(height: 16.0),
              const Text(
                'Simulation Complete',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                'The simulation has reached a stable state after $_finalGenerationCount generations.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: _dismissEndScreen,
                    child: const Text('Continue Observing'),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: _resetGrid,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text('Reset Game'),
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
