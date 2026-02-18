import 'dart:math';
import 'package:derivative_damath/models/chip_model.dart';
import 'package:derivative_damath/utils/game_logic.dart';

/// Represents the difficulty level of the AI opponent.
enum AIDifficulty {
  /// Random valid moves
  easy,

  /// Depth 2 lookahead with basic evaluation
  medium,

  /// Depth 4 lookahead with alpha-beta pruning
  hard,
}

/// Saved game state for undo operations in AI simulation.
class SavedGameState {
  final List<ChipModel> chips;
  final int currentPlayer;
  final int player1Score;
  final int player2Score;
  final bool mustContinueCapture;
  final int captureChainDepth;
  final int? currentChainChipIndex;

  SavedGameState({
    required this.chips,
    required this.currentPlayer,
    required this.player1Score,
    required this.player2Score,
    required this.mustContinueCapture,
    required this.captureChainDepth,
    this.currentChainChipIndex,
  });
}

/// AI opponent for Derivative Damath.
class AIOpponent {
  /// The difficulty level of the AI.
  final AIDifficulty difficulty;

  /// Random number generator for easy mode.
  final Random _random = Random();

  /// Reference to the game logic (for board state access).
  final GameLogic gameLogic;

  AIOpponent({
    required this.difficulty,
    required this.gameLogic,
  });

  /// Gets the best move for the current player.
  ///
  /// Returns a [Move] object representing the chosen move,
  /// or null if no valid moves are available.
  Move? getBestMove() {
    final currentPlayer = gameLogic.currentPlayer;
    final validMoves = gameLogic.getAllValidMovesForPlayer(currentPlayer);

    if (validMoves.isEmpty) {
      return null;
    }

    switch (difficulty) {
      case AIDifficulty.easy:
        return _getEasyMove(validMoves);
      case AIDifficulty.medium:
        return _getMediumMove(validMoves, currentPlayer);
      case AIDifficulty.hard:
        return _getHardMove(validMoves, currentPlayer);
    }
  }

  /// Easy mode: randomly select a valid move.
  Move _getEasyMove(List<Move> validMoves) {
    return validMoves[_random.nextInt(validMoves.length)];
  }

  /// Medium mode: depth 2 minimax without alpha-beta pruning.
  Move _getMediumMove(List<Move> validMoves, int player) {
    Move? bestMove;
    int bestScore = -999999;

    for (final move in validMoves) {
      // Apply move
      final savedState = _saveState();
      _applyMove(move, player);

      // Evaluate at depth 2 (opponent's best response)
      int score = _minimax(1, false, player, -999999, 999999);

      // Undo move
      _restoreState(savedState);

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove ?? validMoves.first;
  }

  /// Hard mode: depth 4 minimax with alpha-beta pruning.
  Move _getHardMove(List<Move> validMoves, int player) {
    Move? bestMove;
    int bestScore = -999999;

    for (final move in validMoves) {
      // Apply move
      final savedState = _saveState();
      _applyMove(move, player);

      // Evaluate at depth 4 with alpha-beta
      int score = _minimax(3, false, player, -999999, 999999);

      // Undo move
      _restoreState(savedState);

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove ?? validMoves.first;
  }

  /// Minimax algorithm with optional alpha-beta pruning.
  ///
  /// [depth] - Remaining depth to search.
  /// [isMaximizing] - Whether we're maximizing or minimizing.
  /// [originalPlayer] - The AI player (for evaluation perspective).
  /// [alpha] - Best value maximizer can guarantee.
  /// [beta] - Best value minimizer can guarantee.
  int _minimax(int depth, bool isMaximizing, int originalPlayer, int alpha, int beta) {
    final currentPlayer = isMaximizing ? originalPlayer : (originalPlayer == 1 ? 2 : 1);

    // Terminal conditions
    if (depth == 0) {
      return _evaluatePosition(currentPlayer, originalPlayer);
    }

    final validMoves = gameLogic.getAllValidMovesForPlayer(currentPlayer);

    // No moves available - this is bad for the current player
    if (validMoves.isEmpty) {
      if (isMaximizing) {
        return -10000; // Losing position
      } else {
        return 10000; // Good for maximizer (opponent has no moves)
      }
    }

    if (isMaximizing) {
      int maxEval = -999999;
      for (final move in validMoves) {
        final savedState = _saveState();
        _applyMove(move, currentPlayer);

        int eval = _minimax(depth - 1, false, originalPlayer, alpha, beta);
        maxEval = max(maxEval, eval);

        alpha = max(alpha, eval);
        _restoreState(savedState);

        if (beta <= alpha) {
          break; // Beta cutoff
        }
      }
      return maxEval;
    } else {
      int minEval = 999999;
      for (final move in validMoves) {
        final savedState = _saveState();
        _applyMove(move, currentPlayer);

        int eval = _minimax(depth - 1, true, originalPlayer, alpha, beta);
        minEval = min(minEval, eval);

        beta = min(beta, eval);
        _restoreState(savedState);

        if (beta <= alpha) {
          break; // Alpha cutoff
        }
      }
      return minEval;
    }
  }

  /// Evaluates the current board position.
  ///
  /// Higher scores are better for the AI player.
  /// [aiPlayer] - The player the AI is playing as.
  /// [perspectivePlayer] - The player from whose perspective to evaluate.
  int _evaluatePosition(int aiPlayer, int perspectivePlayer) {
    int score = 0;

    // Get all chips
    final player1Chips = gameLogic.getChipsForPlayer(1);
    final player2Chips = gameLogic.getChipsForPlayer(2);

    // Piece count: +10 per regular chip, +20 per Dama
    final aiChips = aiPlayer == 1 ? player1Chips : player2Chips;
    final opponentChips = aiPlayer == 1 ? player2Chips : player1Chips;

    // Score from chip counts
    for (final chip in aiChips) {
      score += chip.isDama ? 20 : 10;
      // Position bonus: chips closer to promotion row
      if (aiPlayer == 1) {
        score += (7 - chip.y) * 2; // Player 1 promotes at row 0
      } else {
        score += chip.y * 2; // Player 2 promotes at row 7
      }
    }

    for (final chip in opponentChips) {
      score -= chip.isDama ? 20 : 10;
      // Opponent position bonus (reduce our score)
      if (opponentChips.length == 1) {
        // More urgent if opponent has few pieces
        if (aiPlayer == 1) {
          score -= (7 - chip.y) * 3;
        } else {
          score -= chip.y * 3;
        }
      }
    }

    // Capture opportunities: +5 if can capture
    final aiCaptures = _getCaptureCount(aiPlayer);
    final opponentCaptures = _getCaptureCount(aiPlayer == 1 ? 2 : 1);
    score += aiCaptures * 5;
    score -= opponentCaptures * 5;

    // Derivative potential: check operation tiles
    score += _evaluateDerivativePotential(aiPlayer);

    return score;
  }

  /// Evaluates the derivative potential for a player.
  /// Higher score if chips can apply correct derivatives on operation tiles.
  int _evaluateDerivativePotential(int player) {
    int potential = 0;
    final chips = gameLogic.getChipsForPlayer(player);

    for (final chip in chips) {
      // Check if chip has derivative opportunities
      final moves = gameLogic.getValidMoves(chip);
      for (final move in moves) {
        final operation = gameLogic.getOperationAt(move.toX, move.toY);
        if (operation != null && operation.isNotEmpty) {
          // Check if there's an opponent chip to interact with
          final targetChip = gameLogic.chipAt(move.toX, move.toY);
          if (targetChip != null && gameLogic.isOpponent(chip, targetChip)) {
            // Check if derivative would be correct
            final computedDerivative = gameLogic.computeDerivative(chip);
            if (_mapsEqual(computedDerivative, targetChip.terms)) {
              potential += 3;
            }
          }
        }
      }
    }

    return potential;
  }

  /// Gets the number of captures available for a player.
  int _getCaptureCount(int player) {
    int count = 0;
    final chips = gameLogic.getChipsForPlayer(player);

    for (final chip in chips) {
      final captures = gameLogic.getAvailableCaptures(chip);
      count += captures.length;
    }

    return count;
  }

  /// Compares two polynomial maps for equality.
  bool _mapsEqual(Map<int, int> map1, Map<int, int> map2) {
    if (map1.length != map2.length) return false;
    for (final entry in map1.entries) {
      if (map2[entry.key] != entry.value) return false;
    }
    return true;
  }

  // ==================== STATE MANAGEMENT ====================

  /// Saves the current game state.
  SavedGameState _saveState() {
    // Deep copy chips
    final chipsCopy = gameLogic.chips.map((c) => ChipModel(
      owner: c.owner,
      x: c.x,
      y: c.y,
      terms: Map<int, int>.from(c.terms),
      isDama: c.isDama,
    )).toList();

    // Find the current chain chip index in the original
    int? chainChipIndex;
    if (gameLogic.currentChainChip != null) {
      final index = gameLogic.chips.indexOf(gameLogic.currentChainChip!);
      if (index >= 0) chainChipIndex = index;
    }

    return SavedGameState(
      chips: chipsCopy,
      currentPlayer: gameLogic.currentPlayer,
      player1Score: gameLogic.player1Score,
      player2Score: gameLogic.player2Score,
      mustContinueCapture: gameLogic.mustContinueCapture,
      captureChainDepth: gameLogic.captureChainDepth,
      currentChainChipIndex: chainChipIndex,
    );
  }

  /// Restores a previously saved game state.
  void _restoreState(SavedGameState state) {
    gameLogic.chips.clear();
    gameLogic.chips.addAll(state.chips);
    gameLogic.currentPlayer = state.currentPlayer;
    gameLogic.player1Score = state.player1Score;
    gameLogic.player2Score = state.player2Score;
    gameLogic.mustContinueCapture = state.mustContinueCapture;
    gameLogic.captureChainDepth = state.captureChainDepth;
    
    // Restore chain chip reference
    if (state.currentChainChipIndex != null && state.currentChainChipIndex! < gameLogic.chips.length) {
      gameLogic.currentChainChip = gameLogic.chips[state.currentChainChipIndex!];
    } else {
      gameLogic.currentChainChip = null;
    }
  }

  /// Applies a move to the board (for AI simulation).
  void _applyMove(Move move, int player) {
    // Find the chip at the from position
    ChipModel? chip;
    try {
      chip = gameLogic.chips.firstWhere(
        (c) => c.x == move.fromX && c.y == move.fromY && c.owner == player,
      );
    } catch (e) {
      return;
    }

    // Check if it's a capture
    if (move.isCapture) {
      // Find and remove the captured chip
      final midX = (move.fromX + move.toX) ~/ 2;
      final midY = (move.fromY + move.toY) ~/ 2;
      gameLogic.chips.removeWhere((c) => c.x == midX && c.y == midY);
    }

    // Move the chip
    chip.x = move.toX;
    chip.y = move.toY;

    // Check for Dama promotion
    if ((player == 1 && move.toY == 0) || (player == 2 && move.toY == 7)) {
      chip.isDama = true;
    }

    // Switch player
    gameLogic.currentPlayer = player == 1 ? 2 : 1;
  }
}

/// Factory for creating AI opponents.
class AIOpponentFactory {
  /// Creates an AI opponent with the specified difficulty.
  static AIOpponent create({
    required AIDifficulty difficulty,
    required GameLogic gameLogic,
  }) {
    return AIOpponent(
      difficulty: difficulty,
      gameLogic: gameLogic,
    );
  }

  /// Creates an AI opponent from a string difficulty level.
  static AIOpponent fromString({
    required String difficulty,
    required GameLogic gameLogic,
  }) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return create(difficulty: AIDifficulty.easy, gameLogic: gameLogic);
      case 'medium':
        return create(difficulty: AIDifficulty.medium, gameLogic: gameLogic);
      case 'hard':
        return create(difficulty: AIDifficulty.hard, gameLogic: gameLogic);
      default:
        return create(difficulty: AIDifficulty.medium, gameLogic: gameLogic);
    }
  }
}
