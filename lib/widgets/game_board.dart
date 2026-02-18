import 'package:flutter/material.dart';
import '../models/chip_model.dart';
import '../utils/initial_positions.dart';
import '../utils/operations_layout.dart'; // your operations grid
import 'chip_widget.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late List<ChipModel> chips;
  ChipModel? selectedChip;
  int currentPlayer = 1; // 1 = blue, 2 = red

  final operations = getOperationsBoard(); // 8x8 String grid

  @override
  void initState() {
    super.initState();
    chips = getInitialChips(); // get chips immediately
  }

  bool isOccupied(int x, int y) => chips.any((c) => c.x == x && c.y == y);

  ChipModel? chipAt(int x, int y) {
    try {
      return chips.firstWhere((chip) => chip.x == x && chip.y == y);
    } catch (e) {
      return null;
    }
  }

  bool isOpponent(ChipModel a, ChipModel b) => a.owner != b.owner;

  void onTileTap(int x, int y) {
    setState(() {
      final tappedChip = chipAt(x, y);

      // Step 1 – Select chip
      if (tappedChip != null && tappedChip.owner == currentPlayer) {
        selectedChip = tappedChip;
        return;
      }

      // Step 2 – Move / Capture
      if (selectedChip == null) return;

      final dx = x - selectedChip!.x;
      final dy = y - selectedChip!.y;
      final direction = currentPlayer == 1 ? -1 : 1;

      // Simple move
      if ((dx.abs() == 1 && dy == direction) && !isOccupied(x, y)) {
        selectedChip!
          ..x = x
          ..y = y;
        _endTurn();
        selectedChip = null;
        return;
      }

      // Capture (jump)
      if (dx.abs() == 2 && dy == 2 * direction) {
        final midX = (x + selectedChip!.x) ~/ 2;
        final midY = (y + selectedChip!.y) ~/ 2;
        final midChip = chipAt(midX, midY);

        if (midChip != null &&
            isOpponent(selectedChip!, midChip) &&
            !isOccupied(x, y)) {
          chips.remove(midChip);
          selectedChip!
            ..x = x
            ..y = y;
          _endTurn();
          selectedChip = null;
          return;
        }
      }

      selectedChip = null;
    });
  }

  void _endTurn() {
    currentPlayer = currentPlayer == 1 ? 2 : 1;
  }

  @override
  Widget build(BuildContext context) {
    final double cellSize = (MediaQuery.of(context).size.width - 32) / 8;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          currentPlayer == 1 ? "🔵 Player 1’s Turn" : "🔴 Player 2’s Turn",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(8, (y) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(8, (x) {
                  final isWhite = (x + y) % 2 == 0;
                  final bgColor = isWhite
                      ? const Color(0xFFF1E9D2)
                      : const Color(0xFF6B4A3A);

                  final chipHere = chipAt(x, y);
                  final isSelected = selectedChip != null &&
                      selectedChip!.x == x &&
                      selectedChip!.y == y;

                  final op = operations[y][x];

                  return GestureDetector(
                    onTap: () => onTileTap(x, y),
                    child: Container(
                      width: cellSize,
                      height: cellSize,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: bgColor,
                        border: isSelected
                            ? Border.all(color: Colors.yellowAccent, width: 3)
                            : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (op.isNotEmpty)
                            Text(
                              op,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isWhite ? Colors.black87 : Colors.white,
                              ),
                            ),
                          if (chipHere != null) ChipWidget(chip: chipHere),
                        ],
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
      ],
    );
  }
}
