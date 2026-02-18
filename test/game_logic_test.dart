// lib/test/game_logic_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:derivative_damath/utils/game_logic.dart';  // Import GameLogic from utils/game_logic.dart

void main() {
  group('Game Logic Tests', () {
    test('Capture should be enforced if available', () {
      // Initialize GameLogic
      var gameLogic = GameLogic();

      // Initialize chips using getInitialChips (mock setup)
      gameLogic.initializeChips();

      // Select Player 1's chip
      gameLogic.selectedChip = gameLogic.chips.firstWhere((chip) => chip.owner == 1);

      // Simulate a valid capture (Player 1 capturing an opponent's chip)
      gameLogic.onTileTap(2, 2);  // Select Player 1's chip
      gameLogic.onTileTap(3, 3);  // Player 1 captures the opponent's chip

      // Assert that the opponent's chip was removed after the capture
      expect(gameLogic.chips.length, equals(1));  // Only Player 1's chip should remain
    });

    test('Player cannot move if capture is available', () {
      var gameLogic = GameLogic();

      // Initialize chips
      gameLogic.initializeChips();

      // Select Player 1's chip
      gameLogic.selectedChip = gameLogic.chips.firstWhere((chip) => chip.owner == 1);

      // Simulate a scenario where Player 1 tries to move, but a capture is available
      gameLogic.onTileTap(2, 2);  // Player 1 selects a chip
      gameLogic.onTileTap(3, 3);  // A capture is available

      // Assert that Player 1 was forced to capture and couldn't make a regular move
      expect(gameLogic.chips.length, equals(1));  // The opponent's chip should be captured
      expect(gameLogic.selectedChip, isNull); // Ensure that the selected chip is reset after the capture
    });
  });
}
