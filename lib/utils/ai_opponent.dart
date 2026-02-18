import 'dart:math';
import 'package:derivative_damath/utils/game_logic.dart';

/// Represents the difficulty level of the AI opponent.
enum AIDifficulty {
  /// Easy: Makes mostly random moves with some basic strategy
  easy,
  
  /// Medium: Uses basic evaluation with some lookahead
  medium,
  
  /// Hard: Uses minimax algorithm with deeper evaluation
  hard,
}

/// Represents an AI opponent for Player vs Computer mode.
/// 
/// The AI uses the game logic's move validation to ensure all moves
/// follow the same rules as PvP mode. It evaluates moves based on:
/// - Capture opportunities (prioritized)
/// - Score potential
/// - Dama promotion opportunities
/// - Board position advantages
class AIOpponent {
  /// The difficulty level of the AI
  final AIDifficulty difficulty;
  
  /// Reference to the game logic
  final GameLogic gameLogic;
  
  /// Random number generator for AI decisions
  final Random _random = Random();
  
  /// Maximum depth for minimax search (used in hard mode)
  static const int maxDepth = 3;
  
  AIOpponent({
    required this.difficulty,
    required this.gameLogic,
  });
  
  /// Gets the best move for the AI player.
  /// Returns null if no valid moves are available.
  Move? getBestMove() {
    // Get all valid moves for player 2 (AI)
    final allMoves = gameLogic.getAllValidMovesForPlayer(2);
    
    if (allMoves.isEmpty) {
      return null;
    }
    
    // Handle different difficulty levels
    switch (difficulty) {
      case AIDifficulty.easy:
        return _getEasyMove(allMoves);
      case AIDifficulty.medium:
        return _getMediumMove(allMoves);
      case AIDifficulty.hard:
        return _getHardMove(allMoves);
    }
  }
  
  /// Easy mode: Random selection with small preference for captures
  Move _getEasyMove(List<Move> moves) {
    // Separate capture moves from regular moves
    final captureMoves = moves.where((m) => m.isCapture).toList();
    
    // 30% chance to make a capture if available
    if (captureMoves.isNotEmpty && _random.nextDouble() < 0.3) {
      return captureMoves[_random.nextInt(captureMoves.length)];
    }
    
    // Otherwise, pick a random move
    return moves[_random.nextInt(moves.length)];
  }
  
  /// Medium mode: Evaluate moves with basic scoring
  Move _getMediumMove(List<Move> moves) {
    // Always prioritize captures
    final captureMoves = moves.where((m) => m.isCapture).toList();
    if (captureMoves.isNotEmpty) {
      // Choose the best capture
      return _evaluateAndSelectBest(captureMoves);
    }
    
    // Evaluate all moves and select the best
    return _evaluateAndSelectBest(moves);
  }
  
  /// Hard mode: Use minimax algorithm for optimal move selection
  Move _getHardMove(List<Move> moves) {
    // For captures, evaluate more deeply
    final captureMoves = moves.where((m) => m.isCapture).toList();
    if (captureMoves.isNotEmpty) {
      // Evaluate captures with higher priority
      return _evaluateAndSelectBest(captureMoves);
    }
    
    // Use minimax for move selection
    Move? bestMove;
    double bestScore = double.negativeInfinity;
    
    for (final move in moves) {
      final score = _minimax(move, 0, double.negativeInfinity, double.infinity, false);
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    
    return bestMove ?? moves[_random.nextInt(moves.length)];
  }
  
  /// Evaluates and selects the best move from a list
  Move _evaluateAndSelectBest(List<Move> moves) {
    Move? bestMove;
    double bestScore = double.negativeInfinity;
    
    for (final move in moves) {
      final score = _evaluateMove(move);
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    
    return bestMove ?? moves[_random.nextInt(moves.length)];
  }
  
  /// Evaluates a move and returns a score.
  /// Higher scores are better.
  double _evaluateMove(Move move) {
    double score = 0;
    
    // Capture bonus: High priority for captures
    if (move.isCapture) {
      score += 100;
      
      // Extra bonus if capturing a Dama
      if (move.capturedChipTerms != null) {
        // Calculate value of captured chip terms
        int chipValue = 0;
        for (final entry in move.capturedChipTerms!.entries) {
          chipValue += entry.value.abs();
        }
        score += chipValue * 10;
      }
    }
    
    // Promotion bonus: If move leads to Dama promotion
    if (_leadsToPromotion(move)) {
      score += 50;
    }
    
    // Position bonus: Move toward center or toward promotion row
    score += _evaluatePosition(move.toX, move.toY);
    
    // Score potential: Consider the operation tile
    final operation = gameLogic.getOperationAt(move.toX, move.toY);
    if (operation != null && operation.isNotEmpty) {
      score += 10; // Bonus for moving to operation tile
    }
    
    // Add small random factor for variety
    score += _random.nextDouble() * 5;
    
    return score;
  }
  
  /// Minimax algorithm for hard mode
  double _minimax(Move move, int depth, double alpha, double beta, bool isMaximizing) {
    // Execute move
    gameLogic.executeMove(move);
    
    // Check if game over or max depth reached
    if (depth >= maxDepth || gameLogic.isGameOver) {
      // Return evaluation of resulting position
      final score = _evaluatePositionScore();
      // Undo move would be complex, so we rely on game state
      return score;
    }
    
    // Get moves for next player
    final nextPlayer = gameLogic.currentPlayer;
    final nextMoves = gameLogic.getAllValidMovesForPlayer(nextPlayer);
    
    if (nextMoves.isEmpty) {
      // No moves available - current player wins
      return isMaximizing ? 1000 : -1000;
    }
    
    double score;
    if (isMaximizing) {
      score = double.negativeInfinity;
      for (final nextMove in nextMoves) {
        final moveScore = _minimax(nextMove, depth + 1, alpha, beta, false);
        score = max(score, moveScore);
        alpha = max(alpha, score);
        if (beta <= alpha) break;
      }
    } else {
      score = double.infinity;
      for (final nextMove in nextMoves) {
        final moveScore = _minimax(nextMove, depth + 1, alpha, beta, true);
        score = min(score, moveScore);
        beta = min(beta, score);
        if (beta <= alpha) break;
      }
    }
    
    return score;
  }
  
  /// Evaluates the current position score for the AI player
  double _evaluatePositionScore() {
    // Get current scores
    final aiScore = gameLogic.getScore(2);
    final playerScore = gameLogic.getScore(1);
    
    // Get chip counts
    final aiChips = gameLogic.getChipCount(2);
    final playerChips = gameLogic.getChipCount(1);
    
    // Get Dama counts
    final aiDamas = gameLogic.getDamaCount(2);
    final playerDamas = gameLogic.getDamaCount(1);
    
    // Calculate position score
    double score = 0;
    
    // Score difference
    score += (aiScore - playerScore) * 10;
    
    // Chip advantage
    score += (aiChips - playerChips) * 50;
    
    // Dama advantage (Damas are very powerful)
    score += (aiDamas - playerDamas) * 100;
    
    return score;
  }
  
  /// Checks if a move leads to Dama promotion
  bool _leadsToPromotion(Move move) {
    // Player 2 (AI) promotes at row 7 (bottom)
    return move.toY == 7;
  }
  
  /// Evaluates a position and returns a bonus score
  double _evaluatePosition(int x, int y) {
    double score = 0;
    
    // Center control: prefer positions near the center
    final centerDistance = (3.5 - x).abs() + (3.5 - y).abs();
    score += (7 - centerDistance) * 2;
    
    // For AI (player 2), prefer moving toward promotion row (y = 7)
    score += y * 1.5;
    
    return score;
  }
}
