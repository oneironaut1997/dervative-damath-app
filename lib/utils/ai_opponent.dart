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
  /// Note: Minimax is currently disabled due to game state corruption issues
  static const int maxDepth = 3;
  
  /// Transposition table for caching evaluated positions
  /// Key: position signature, Value: evaluated score
  final Map<String, double> _transpositionTable = {};
  
  /// Maximum entries in transposition table
  static const int maxTranspositionSize = 10000;
  
  AIOpponent({
    required this.difficulty,
    required this.gameLogic,
  });
  
  /// Gets the best move for the AI player.
  /// Returns null if no valid moves are available.
  Move? getBestMove() {
    // Handle chain captures - if must continue capturing, only use chain chip
    if (gameLogic.mustContinueCapturing) {
      final chainChip = gameLogic.currentChainChipModel;
      if (chainChip != null) {
        final captures = gameLogic.getAvailableCaptures(chainChip);
        if (captures.isNotEmpty) {
          // Return best capture from chain chip based on difficulty
          return _getBestChainCapture(captures);
        }
      }
      return null; // No more captures available
    }
    
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
  
  /// Gets the best capture move from the chain chip during chain capture
  Move? _getBestChainCapture(List<CaptureMove> captures) {
    if (captures.isEmpty) return null;
    
    switch (difficulty) {
      case AIDifficulty.easy:
        // Random selection - no strategy
        final randomCapture = captures[_random.nextInt(captures.length)];
        return Move(
          fromX: randomCapture.fromX,
          fromY: randomCapture.fromY,
          toX: randomCapture.toX,
          toY: randomCapture.toY,
          isCapture: true,
          capturedChipTerms: randomCapture.capturedChip.terms,
        );
      case AIDifficulty.medium:
      case AIDifficulty.hard:
        // Evaluate and pick best capture
        return _evaluateAndSelectBestCapture(captures);
    }
  }
  
  /// Evaluates and selects the best capture move from available captures
  Move? _evaluateAndSelectBestCapture(List<CaptureMove> captures) {
    Move? bestMove;
    double bestScore = double.negativeInfinity;
    
    for (final capture in captures) {
      final move = Move(
        fromX: capture.fromX,
        fromY: capture.fromY,
        toX: capture.toX,
        toY: capture.toY,
        isCapture: true,
        capturedChipTerms: capture.capturedChip.terms,
      );
      
      final score = _evaluateMove(move);
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    
    return bestMove;
  }
  
  /// Easy mode: Random selection but always follows must capture rule
  Move _getEasyMove(List<Move> moves) {
    // Separate capture moves from regular moves
    final captureMoves = moves.where((m) => m.isCapture).toList();
    
    // Must capture rule: if capture is available, MUST capture
    if (captureMoves.isNotEmpty) {
      // Easy still picks randomly among captures (no strategy)
      return captureMoves[_random.nextInt(captureMoves.length)];
    }
    
    // No captures available - pick random regular move
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
  
  /// Hard mode: Uses enhanced evaluation with multiple factors
  /// More sophisticated than medium but doesn't corrupt game state
  Move _getHardMove(List<Move> moves) {
    // Always prioritize captures (must capture rule)
    final captureMoves = moves.where((m) => m.isCapture).toList();
    if (captureMoves.isNotEmpty) {
      // Use enhanced position evaluation for captures
      return _evaluateAndSelectBestHard(captureMoves);
    }
    
    // No captures available - use enhanced evaluation for regular moves
    return _evaluateAndSelectBestHard(moves);
  }
  
  /// Hard mode evaluation - simulates position after move
  Move _evaluateAndSelectBestHard(List<Move> moves) {
    Move? bestMove;
    double bestScore = double.negativeInfinity;
    
    for (final move in moves) {
      final score = _evaluateMoveHard(move);
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    
    return bestMove ?? moves[_random.nextInt(moves.length)];
  }
  
  /// Hard mode move evaluation - considers position after move
  double _evaluateMoveHard(Move move) {
    double score = 0;
    
    // Capture bonus: High priority for captures
    if (move.isCapture) {
      score += 100;
      
      // Extra bonus if capturing a Dama
      if (move.capturedChipTerms != null) {
        int chipValue = 0;
        for (final entry in move.capturedChipTerms!.entries) {
          chipValue += entry.value.abs();
        }
        score += chipValue * 10;
      }
    }
    
    // Promotion bonus
    if (_leadsToPromotion(move)) {
      score += 50;
    }
    
    // Position bonus
    score += _evaluatePosition(move.toX, move.toY);
    
    // Operation tile bonus
    final operation = gameLogic.getOperationAt(move.toX, move.toY);
    if (operation != null && operation.isNotEmpty) {
      score += 10;
    }
    
    return score;
  }
  
  /// Get best move using minimax algorithm
  Move _getBestMoveWithMinimax(List<Move> moves) {
    Move? bestMove;
    double bestScore = double.negativeInfinity;
    
    // Clear transposition table at start of new move calculation
    _transpositionTable.clear();
    
    for (final move in moves) {
      final score = _minimax(move, 0, double.negativeInfinity, double.infinity, false);
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    
    return bestMove ?? moves[_random.nextInt(moves.length)];
  }
  
  /// Minimax algorithm for hard mode with enhanced evaluation
  double _minimax(Move move, int depth, double alpha, double beta, bool isMaximizing) {
    // Get position signature for transposition table
    final positionKey = _getPositionSignature();
    
    // Check transposition table
    if (depth > 0 && _transpositionTable.containsKey(positionKey)) {
      return _transpositionTable[positionKey]!;
    }
    
    // Execute move
    gameLogic.executeMove(move);
    
    // Check if game over
    if (gameLogic.isGameOver) {
      final score = _evaluatePositionScore();
      _transpositionTable[positionKey] = score;
      return score;
    }
    
    // Handle chain captures: if must continue capturing, only explore chain captures
    if (gameLogic.mustContinueCapturing) {
      final chainChip = gameLogic.currentChainChipModel;
      if (chainChip != null) {
        final captures = gameLogic.getAvailableCaptures(chainChip);
        if (captures.isNotEmpty) {
          double bestScore = isMaximizing ? double.negativeInfinity : double.infinity;
          for (final capture in captures) {
            final captureMove = Move(
              fromX: capture.fromX,
              fromY: capture.fromY,
              toX: capture.toX,
              toY: capture.toY,
              isCapture: true,
              capturedChipTerms: capture.capturedChip.terms,
            );
            final score = _minimax(captureMove, depth + 1, alpha, beta, isMaximizing);
            if (isMaximizing) {
              bestScore = max(bestScore, score);
              alpha = max(alpha, bestScore);
            } else {
              bestScore = min(bestScore, score);
              beta = min(beta, bestScore);
            }
            if (beta <= alpha) break;
          }
          _transpositionTable[positionKey] = bestScore;
          return bestScore;
        }
      }
    }
    
    // Check depth limit
    if (depth >= maxDepth) {
      final score = _evaluatePositionScore();
      _transpositionTable[positionKey] = score;
      return score;
    }
    
    // Get moves for next player (respecting must capture rule)
    final nextPlayer = gameLogic.currentPlayer;
    List<Move> nextMoves;
    
    // Check if capture is available for next player
    if (gameLogic.hasAnyCaptureAvailable(nextPlayer)) {
      // Must capture - only get capture moves
      final allMoves = gameLogic.getAllValidMovesForPlayer(nextPlayer);
      nextMoves = allMoves.where((m) => m.isCapture).toList();
      if (nextMoves.isEmpty) {
        // No valid captures but capture is required - this is a losing position
        return isMaximizing ? -1000 : 1000;
      }
    } else {
      nextMoves = gameLogic.getAllValidMovesForPlayer(nextPlayer);
    }
    
    if (nextMoves.isEmpty) {
      // No moves available - current player wins
      final score = isMaximizing ? 1000.0 : -1000.0;
      _transpositionTable[positionKey] = score;
      return score;
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
    
    // Store in transposition table (limit size)
    if (_transpositionTable.length < maxTranspositionSize) {
      _transpositionTable[positionKey] = score;
    }
    
    return score;
  }
  
  /// Get position signature for transposition table
  String _getPositionSignature() {
    final buffer = StringBuffer();
    final chips = gameLogic.chips.toList()..sort((a, b) => '${a.owner},${a.x},${a.y}'.compareTo('${b.owner},${b.x},${b.y}'));
    for (final chip in chips) {
      buffer.write('${chip.owner}:${chip.x},${chip.y}:${chip.isDama};');
    }
    buffer.write('P${gameLogic.currentPlayer}');
    return buffer.toString();
  }
  
  /// Enhanced evaluation function with more factors
  /// Balanced for challenging but fair gameplay
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
    
    // 1. Score difference (important for endgame)
    score += (aiScore - playerScore) * 5;
    
    // 2. Chip advantage (each chip is valuable) - reduced from 50
    score += (aiChips - playerChips) * 30;
    
    // 3. Dama advantage (Damas are very powerful) - reduced from 100
    score += (aiDamas - playerDamas) * 60;
    
    // 4. Position control - evaluate each piece
    score += _evaluateBoardControl();
    
    // 5. Piece safety - check if pieces are defended (increased importance)
    score += _evaluatePieceSafety() * 1.5;
    
    // 6. Promotion potential - pieces close to promotion
    score += _evaluatePromotionPotential();
    
    // 7. Operation tile control
    score += _evaluateOperationTileControl();
    
    // 8. Capture opportunities - reduced weight to prevent overly aggressive play
    score += _evaluateCaptureOpportunities() * 0.8;
    
    return score;
  }
  
  /// Evaluate board control - prefer center and strategic positions
  double _evaluateBoardControl() {
    double score = 0;
    
    for (final chip in gameLogic.chips) {
      // Center control (positions around 3,3 are best)
      final centerDist = (3.5 - chip.x).abs() + (3.5 - chip.y).abs();
      final centerBonus = (7 - centerDist) * 1.5;
      
      if (chip.owner == 2) {
        score += centerBonus; // AI controls center
      } else {
        score -= centerBonus; // Opponent controls center
      }
    }
    
    return score;
  }
  
  /// Evaluate piece safety - check if pieces are protected
  double _evaluatePieceSafety() {
    double score = 0;
    
    for (final chip in gameLogic.chips) {
      // Check if chip is defended (has own piece nearby)
      bool isDefended = false;
      int defenderCount = 0;
      
      for (final other in gameLogic.chips) {
        if (other.owner == chip.owner && other != chip) {
          // Check diagonal adjacency (defensive positions)
          if ((chip.x - other.x).abs() == 1 && (chip.y - other.y).abs() == 1) {
            isDefended = true;
            defenderCount++;
          }
        }
      }
      
      // More nuanced safety evaluation
      final double safetyBonus;
      if (isDefended) {
        // Bonus for defended pieces, more bonus for multiple defenders
        safetyBonus = 5.0 + (defenderCount - 1) * 2.0;
      } else {
        // Penalty for unprotected pieces
        safetyBonus = -4.0;
      }
      
      if (chip.owner == 2) {
        score += safetyBonus;
      } else {
        score -= safetyBonus;
      }
    }
    
    return score;
  }
  
  /// Evaluate promotion potential - pieces close to promotion row
  double _evaluatePromotionPotential() {
    double score = 0;
    
    for (final chip in gameLogic.chips) {
      if (chip.isDama) continue; // Already promoted
      
      // AI (player 2) promotes at row 0 (top)
      // Player 1 promotes at row 7 (bottom)
      int distanceToPromotion;
      if (chip.owner == 2) {
        distanceToPromotion = chip.y; // Closer to 0 is better
      } else {
        distanceToPromotion = 7 - chip.y; // Closer to 7 is better
      }
      
      // Closer to promotion is worth more
      final promotionBonus = (7 - distanceToPromotion) * 3;
      
      if (chip.owner == 2) {
        score += promotionBonus;
      } else {
        score -= promotionBonus;
      }
    }
    
    return score;
  }
  
  /// Evaluate operation tile control
  double _evaluateOperationTileControl() {
    double score = 0;
    
    for (final chip in gameLogic.chips) {
      // Check if chip is on an operation tile
      final operation = gameLogic.getOperationAt(chip.x, chip.y);
      if (operation != null && operation.isNotEmpty) {
        final tileBonus = 8;
        if (chip.owner == 2) {
          score += tileBonus;
        } else {
          score -= tileBonus;
        }
      }
    }
    
    return score;
  }
  
  /// Evaluate future capture opportunities
  double _evaluateCaptureOpportunities() {
    double score = 0;
    
    // AI's capture opportunities
    final aiCaptureCount = gameLogic.getChipsThatCanCapture(2).length;
    score += aiCaptureCount * 30;
    
    // Opponent's capture opportunities (reduce score)
    final playerCaptureCount = gameLogic.getChipsThatCanCapture(1).length;
    score -= playerCaptureCount * 30;
    
    return score;
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
