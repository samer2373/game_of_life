class GameModel {
  late List<List<bool>> grid;
  int rows;
  int columns;

  GameModel({required this.rows, required this.columns}) {
    // Initialize empty grid
    resetGrid();
  }

  void resetGrid() {
    grid = List.generate(rows, (_) => List.generate(columns, (_) => false));
  }

  void toggleCell(int row, int col) {
    if (row >= 0 && row < rows && col >= 0 && col < columns) {
      grid[row][col] = !grid[row][col];
    }
  }

  List<List<bool>> nextGeneration() {
    List<List<bool>> newGrid = List.generate(
      rows,
      (_) => List.generate(columns, (_) => false),
    );

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        int liveNeighbors = countLiveNeighbors(i, j);
        bool isAlive = grid[i][j];

        // Apply Conway's Game of Life rules
        if (isAlive && (liveNeighbors == 2 || liveNeighbors == 3)) {
          // Rule: Any live cell with two or three live neighbors survives
          newGrid[i][j] = true;
        } else if (!isAlive && liveNeighbors == 3) {
          // Rule: Any dead cell with exactly three live neighbors becomes alive
          newGrid[i][j] = true;
        } else {
          // Rule: All other cells die or remain dead
          newGrid[i][j] = false;
        }
      }
    }

    return newGrid;
  }

  int countLiveNeighbors(int row, int col) {
    int count = 0;

    // Define the relative positions of the 8 neighboring cells
    List<List<int>> directions = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1],
    ];

    for (var direction in directions) {
      int newRow = row + direction[0];
      int newCol = col + direction[1];

      // Check if the neighboring cell is valid and alive
      if (newRow >= 0 && newRow < rows && newCol >= 0 && newCol < columns) {
        if (grid[newRow][newCol]) {
          count++;
        }
      }
    }

    return count;
  }

  void updateToNextGeneration() {
    grid = nextGeneration();
  }

  // Import a predefined grid configuration
  void importGrid(List<List<bool>> newGrid) {
    if (newGrid.isNotEmpty && newGrid[0].isNotEmpty) {
      rows = newGrid.length;
      columns = newGrid[0].length;
      grid = List.from(newGrid);
    }
  }

  // Resize the grid to new dimensions
  void resizeGrid(int newRows, int newColumns) {
    List<List<bool>> newGrid = List.generate(
      newRows,
      (_) => List.generate(newColumns, (_) => false),
    );

    // Copy existing values where possible
    for (int i = 0; i < newRows && i < rows; i++) {
      for (int j = 0; j < newColumns && j < columns; j++) {
        newGrid[i][j] = grid[i][j];
      }
    }

    rows = newRows;
    columns = newColumns;
    grid = newGrid;
  }
}
