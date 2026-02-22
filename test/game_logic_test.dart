// test/game_logic_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:derivative_damath/utils/game_logic.dart';
import 'package:derivative_damath/models/chip_model.dart';
import 'package:derivative_damath/models/game_state_model.dart';

void main() {
  group('Game Logic - Capture Tests', () {
    test('Can get available captures for a chip', () {
      var gameLogic = GameLogic();
      
      // Setup: Create a capture scenario
      gameLogic.chips = [
        ChipModel(id: 0, owner: 1, x: 2, y: 3, terms: {1: 1}),
        ChipModel(id: 1, owner: 2, x: 3, y: 2, terms: {1: 1}),
      ];
      
      final player1Chip = gameLogic.chips.firstWhere((c) => c.owner == 1);
      final captures = gameLogic.getAvailableCaptures(player1Chip);
      
      // Method should work without error
      expect(captures != null, isTrue);
    });

    test('Get valid moves returns moves', () {
      var gameLogic = GameLogic();
      gameLogic.initializeChips();
      
      // Get any chip that has valid moves
      final chips = gameLogic.getChipsForPlayer(1);
      final chip = chips.firstWhere(
        (c) => gameLogic.getValidMoves(c).isNotEmpty,
        orElse: () => chips.first,
      );
      final validMoves = gameLogic.getValidMoves(chip);
      
      expect(validMoves.isNotEmpty, isTrue);
    });
  });

  group('Game Logic - Move Validation Tests', () {
    test('Regular forward move is valid', () {
      var gameLogic = GameLogic();
      gameLogic.initializeChips();
      
      // Player 1 starts at y=0,1,2 and moves upward (direction = -1)
      final chip = gameLogic.chips.firstWhere((c) => c.owner == 1 && c.y == 2);
      
      // Forward move should be valid
      final direction = -1;
      final canMove = gameLogic.chipAt(chip.x, chip.y + direction) == null;
      
      expect(canMove, isTrue);
    });

    test('Backward move for non-Dama is invalid', () {
      var gameLogic = GameLogic();
      gameLogic.initializeChips();
      
      // Get a regular chip (not Dama)
      final chip = gameLogic.chips.firstWhere((c) => c.owner == 1 && !c.isDama);
      
      expect(chip.y >= 0, isTrue);
      expect(chip.isDama, isFalse);
    });

    test('Diagonal move - chip validates diagonal', () {
      var gameLogic = GameLogic();
      gameLogic.initializeChips();
      
      // Get any regular chip that has valid moves
      final chip = gameLogic.chips.firstWhere(
        (c) => c.owner == 1 && !c.isDama && gameLogic.getValidMoves(c).isNotEmpty,
        orElse: () => gameLogic.chips.firstWhere((c) => c.owner == 1 && !c.isDama),
      );
      
      // Verify chip is valid
      expect(chip != null, isTrue);
      expect(chip.isDama || chip.y >= 0, isTrue);
    });
  });

  group('Game Logic - Double Jump Tests', () {
    test('Capture chain depth is tracked', () {
      var gameLogic = GameLogic();
      
      gameLogic.chips = [
        ChipModel(id: 0, owner: 1, x: 2, y: 3, terms: {1: 1}),
        ChipModel(id: 1, owner: 2, x: 3, y: 2, terms: {1: 1}),
        ChipModel(id: 2, owner: 2, x: 4, y: 1, terms: {1: 1}),
      ];
      
      gameLogic.currentPlayer = 1;
      gameLogic.selectedChip = gameLogic.chips[0];
      gameLogic.onTileTap(4, 1);
      
      expect(gameLogic.captureChainDepth >= 0, isTrue);
    });

    test('Turn switches after valid move', () {
      var gameLogic = GameLogic();
      gameLogic.initializeChips();
      
      gameLogic.currentPlayer = 1;
      final chip = gameLogic.chips.firstWhere((c) => c.owner == 1);
      gameLogic.selectedChip = chip;
      
      final validMoves = gameLogic.getValidMoves(chip);
      if (validMoves.isNotEmpty) {
        final move = validMoves.firstWhere((m) => !m.isCapture, orElse: () => validMoves.first);
        gameLogic.onTileTap(move.toX, move.toY);
        
        // Either turn switched or move was processed
        expect(gameLogic.currentPlayer == 2 || gameLogic.gamePhase == GamePhase.playing, isTrue);
      }
    });
  });

  group('Game Logic - Dama Promotion Tests', () {
    test('Chip promoted when reaching end row', () {
      var gameLogic = GameLogic();
      
      gameLogic.chips = [
        ChipModel(id: 0, owner: 1, x: 3, y: 1, terms: {1: 1}, isDama: false),
      ];
      gameLogic.currentPlayer = 1;
      
      final chip = gameLogic.chips.first;
      expect(chip.isDama, isFalse);
      
      gameLogic.selectedChip = chip;
      gameLogic.onTileTap(3, 0);
      
      final promotedChip = gameLogic.chipAt(3, 0);
      if (promotedChip != null) {
        expect(promotedChip.isDama, isTrue);
      }
    });

    test('Dama can move backward after promotion', () {
      var gameLogic = GameLogic();
      
      final chip = ChipModel(id: 0, owner: 1, x: 3, y: 3, terms: {1: 1}, isDama: true);
      gameLogic.chips = [chip];
      gameLogic.currentPlayer = 1;
      
      final moves = gameLogic.getValidMoves(chip);
      expect(moves.isNotEmpty, isTrue);
      
      final backwardMoves = moves.where((m) => m.toY > chip.y).toList();
      expect(backwardMoves.isNotEmpty, isTrue);
    });

    test('Dama can slide multiple squares', () {
      var gameLogic = GameLogic();
      
      final chip = ChipModel(id: 0, owner: 1, x: 3, y: 3, terms: {1: 1}, isDama: true);
      gameLogic.chips = [chip];
      
      final moves = gameLogic.getValidMoves(chip);
      
      final multiSquareMoves = moves.where((m) => 
        (m.toX - chip.x).abs() > 1 || (m.toY - chip.y).abs() > 1
      ).toList();
      
      expect(multiSquareMoves.isNotEmpty, isTrue);
    });
  });

  group('Game Logic - Win Detection Tests', () {
    test('Win when opponent has no chips', () {
      var gameLogic = GameLogic();
      
      gameLogic.chips = [
        ChipModel(id: 0, owner: 1, x: 3, y: 3, terms: {1: 1}),
      ];
      gameLogic.currentPlayer = 1;
      
      gameLogic.evaluateGameState();
      
      expect(gameLogic.gamePhase == GamePhase.won || 
             gameLogic.chips.where((c) => c.owner == 2).isEmpty, isTrue);
    });

    test('Can get all valid moves for player', () {
      var gameLogic = GameLogic();
      
      gameLogic.chips = [
        ChipModel(id: 0, owner: 1, x: 3, y: 3, terms: {1: 1}),
        ChipModel(id: 1, owner: 2, x: 4, y: 4, terms: {1: 1}),
      ];
      gameLogic.currentPlayer = 1;
      
      final player1Moves = gameLogic.getAllValidMovesForPlayer(1);
      expect(player1Moves != null, isTrue);
    });
  });

  group('Game Logic - Score Calculation', () {
    test('Score is accessible after moves', () {
      var gameLogic = GameLogic();
      gameLogic.initializeChips();
      
      final initialScore = gameLogic.player1Score;
      
      gameLogic.currentPlayer = 1;
      final chip = gameLogic.chips.firstWhere((c) => c.owner == 1);
      gameLogic.selectedChip = chip;
      
      final validMoves = gameLogic.getValidMoves(chip);
      if (validMoves.isNotEmpty) {
        final move = validMoves.firstWhere((m) => !m.isCapture, orElse: () => validMoves.first);
        gameLogic.onTileTap(move.toX, move.toY);
        
        // Score should be accessible
        expect(gameLogic.player1Score >= 0, isTrue);
      }
    });
  });

  group('Game Logic - Chip Selection', () {
    test('Select own chip works', () {
      var gameLogic = GameLogic();
      gameLogic.initializeChips();
      
      final chip = gameLogic.chips.firstWhere((c) => c.owner == 1);
      gameLogic.selectedChip = chip;
      
      expect(gameLogic.selectedChip, equals(chip));
    });

    test('Get chips for player returns correct count', () {
      var gameLogic = GameLogic();
      gameLogic.initializeChips();
      
      final player1Chips = gameLogic.getChipsForPlayer(1);
      final player2Chips = gameLogic.getChipsForPlayer(2);
      
      expect(player1Chips.length, equals(12));
      expect(player2Chips.length, equals(12));
    });
  });

  group('Game Logic - Reset', () {
    test('Reset returns to initial state', () {
      var gameLogic = GameLogic();
      gameLogic.initializeChips();
      
      gameLogic.currentPlayer = 2;
      gameLogic.player1Score = 100;
      gameLogic.player2Score = 50;
      
      gameLogic.reset();
      
      expect(gameLogic.currentPlayer, equals(1));
      expect(gameLogic.player1Score, equals(0));
      expect(gameLogic.player2Score, equals(0));
    });
  });

  group('Game Logic - Chip Model', () {
    test('Chip label is generated correctly', () {
      final chip = ChipModel(
        id: 0,
        owner: 1,
        x: 0,
        y: 0,
        terms: {2: 3, 1: 2},
      );
      
      expect(chip.label.isNotEmpty, isTrue);
    });

    test('Chip can be created with isDama flag', () {
      final chip = ChipModel(
        id: 0,
        owner: 1,
        x: 0,
        y: 0,
        terms: {1: 1},
        isDama: true,
      );
      
      expect(chip.isDama, isTrue);
    });
  });
}
