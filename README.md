# Conway's Game of Life

A Flutter implementation of Conway's Game of Life cellular automaton.

## Features

1. **Interactive Grid Setup**
   - Tap on cells to toggle between alive (black) and dead (white) states
   - Customize your initial pattern before starting the simulation

2. **Game Controls**
   - Start/Resume: Begin or continue the simulation
   - Pause: Temporarily halt the simulation
   - Stop: End the simulation completely
   - Reset: Clear the grid and return to the initial state

3. **Speed Adjustment**
   - Use the slider to change the simulation speed from 0.2 to 5.0 generations per second
   - Default speed is set to 1.0 generations per second

4. **Custom Grid Sizes**
   - Adjust the grid dimensions by entering the desired number of rows and columns
   - Grid sizes are limited to between 3x3 and 100x100 for performance reasons

5. **Import Initial State**
   - Import predefined patterns using JSON array format
   - Example format: `[[0,1,0],[1,1,1],[0,1,0]]` (represents a "glider" pattern)

## Rules of Conway's Game of Life

1. Any live cell with fewer than two live neighbors dies (underpopulation)
2. Any live cell with two or three live neighbors survives to the next generation
3. Any live cell with more than three live neighbors dies (overpopulation)
4. Any dead cell with exactly three live neighbors becomes a live cell (reproduction)

## How to Run

1. Make sure you have Flutter installed on your system
2. Clone this repository
3. Navigate to the project directory
4. Run `flutter pub get` to install dependencies
5. Run `flutter run` to start the application

## Common Patterns

You can import these common patterns by copying the JSON and pasting it into the import field:

### Glider
```json
[[0,1,0],[0,0,1],[1,1,1]]
```

### Blinker (oscillator)
```json
[[0,0,0],[1,1,1],[0,0,0]]
```

### Beacon (oscillator)
```json
[[1,1,0,0],[1,1,0,0],[0,0,1,1],[0,0,1,1]]
```

### Pulsar (larger oscillator)
```json
[[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,0,1,0,0,0,0,1,0,1,0,0,0,0,1,0,0],[0,0,1,0,0,0,0,1,0,1,0,0,0,0,1,0,0],[0,0,1,0,0,0,0,1,0,1,0,0,0,0,1,0,0],[0,0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,0],[0,0,1,0,0,0,0,1,0,1,0,0,0,0,1,0,0],[0,0,1,0,0,0,0,1,0,1,0,0,0,0,1,0,0],[0,0,1,0,0,0,0,1,0,1,0,0,0,0,1,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]]
```

## Technical Implementation

This implementation uses:
- Flutter for the user interface
- Dart's Timer class for simulation timing
- JSON decoding for importing patterns
