import 'package:flutter/material.dart';
import '../models/game_model.dart';

class GridWidget extends StatelessWidget {
  final GameModel gridModel;
  final Function(int, int) onCellTap;
  final bool enabled;

  const GridWidget({
    super.key,
    required this.gridModel,
    required this.onCellTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          gridModel.rows,
          (rowIndex) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              gridModel.columns,
              (colIndex) => GestureDetector(
                onTap: enabled ? () => onCellTap(rowIndex, colIndex) : null,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color:
                        gridModel.grid[rowIndex][colIndex]
                            ? Colors.black
                            : Colors.white,
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
