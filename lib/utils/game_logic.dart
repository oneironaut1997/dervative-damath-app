import 'package:logging/logging.dart';
import 'package:derivative_damath/models/chip_model.dart';
import 'package:derivative_damath/models/operation_model.dart';
import 'package:derivative_damath/models/game_state_model.dart';
import 'package:derivative_damath/models/player_model.dart';
import 'package:derivative_damath/utils/derivative_rules.dart';
import 'package:derivative_damath/utils/score_calculator.dart';
import 'initial_positions.dart';
import 'operations_layout.dart';

/// Represents a move in the game.
class Move {
  final int fromX;
  final int fromY;
  final int toX;
  final int toY;
  final bool isCapture;
  final Map<int, int>? capturedChipTerms;

  Move({
    required this.fromX,
    required this.fromY,
    required this.toX,
    required this.toY,
    this.isCapture = false,
    this.capturedChipTerms,
  });

  @override
  String toString() => 'Move(($fromX,$fromY) -> ($toX,$toY), capture: $isCapture)';
}

/// Represents a capture move with details.
class CaptureMove {
  final int fromX;
  final int fromY;
  final int toX;
  final int toY;
  final int midX;
  final int midY;
  final ChipModel capturedChip;

  CaptureMove({
    required this.fromX,
    required this.fromY,
    required this.toX,
    required this.toY,
    required this.midX,
    required this.midY,
    required this.capturedChip,
  });
}

class GameLogic {
  List<ChipModel> chips = [];
  ChipModel? selectedChip;
  int currentPlayer = 1; // 1 = blue, 2 = red

  // Score tracking (now using double for PDF-compliant scoring)
  double player1Score = 0;
  double player2Score = 0;

  // Last move result for feedback
  MoveResult? lastMoveResult;
  String? lastErrorMessage;

  // ==================== PHASE 3: GAME MECHANICS ====================

  // Double Jump / Chain Capture tracking
  bool mustContinueCapture = false;
  ChipModel? currentChainChip;
  int captureChainDepth = 0;

  // Win/Lose Detection
  GamePhase gamePhase = GamePhase.playing;
  PlayerModel? winner;

  // Position tracking for draw detection
  final List<String> positionHistory = [];
  static const int maxPositionRepeats = 3;

  // Create a logger instance
  final Logger _logger = Logger('GameLogic');

  GameLogic() {
    setupLogging();
    initializeChips();
  }

  // Setup logging configuration
  void setupLogging() {
    // For testing compatibility, use a simpler logging setup
    // that doesn't cause async issues
  }

  // Initializes the game chips
  void initializeChips() {
    chips = getInitialChips();
    _recordPosition();
  }

  // Records the current position for draw detection
  void _recordPosition() {
    final position = _getPositionSignature();
    positionHistory.add(position);

    // Keep only recent positions
    if (positionHistory.length > 20) {
      positionHistory.removeAt(0);
    }
  }

  // Gets a signature string for the current position
  String _getPositionSignature() {
    final buffer = StringBuffer();
    final sortedChips = List<ChipModel>.from(chips)
      ..sort((a, b) => '${a.owner},${a.x},${a.y}'.compareTo('${b.owner},${b.x},${b.y}'));
    for (final chip in sortedChips) {
      buffer.write('${chip.owner}:${chip.x},${chip.y}:${chip.isDama};');
    }
    buffer.write('P$currentPlayer');
    return buffer.toString();
  }

  // Checks if position has repeated maxPositionRepeats times (for draw)
  bool _hasRepeatedPosition() {
    final current = _getPositionSignature();
    int count = 0;
    for (final pos in positionHistory) {
      if (pos == current) count++;
    }
    return count >= maxPositionRepeats;
  }

  // ==================== TILE TAP HANDLING ====================

  /// Simulate tile tap (a player making a move or capturing)
  void onTileTap(int x, int y) {
    // If game is over, ignore taps
    if (gamePhase != GamePhase.playing) {
      lastErrorMessage = 'Game is over';
      return;
    }

    // If must continue capture, handle specially
    if (mustContinueCapture) {
      _handleChainCaptureTap(x, y);
      return;
    }

    // Check if any capture is available for current player (must capture rule)
    final bool captureAvailable = hasAnyCaptureAvailable(currentPlayer);

    // Normal selection/move handling
    if (selectedChip == null) {
      // Try to select a chip
      final chip = chipAt(x, y);
      if (chip != null && chip.owner == currentPlayer) {
        // Must capture rule: if capture is available, can only select chips that can capture
        if (captureAvailable) {
          if (chipCanCapture(chip)) {
            selectedChip = chip;
            _logger.info('Selected capturing chip at ($x, $y)');
          } else {
            lastErrorMessage = 'Capture is available - must capture!';
            _logger.warning('Cannot select non-capturing chip when capture is available');
          }
        } else {
          // No capture available - can select any chip
          selectedChip = chip;
          _logger.info('Selected chip at ($x, $y)');
        }
      }
      return;
    }

    // If tapping on own chip, change selection (respecting must capture rule)
    final tappedChip = chipAt(x, y);
    if (tappedChip != null && tappedChip.owner == currentPlayer) {
      // Must capture rule: if capture is available, can only select chips that can capture
      if (captureAvailable) {
        if (chipCanCapture(tappedChip)) {
          selectedChip = tappedChip;
          _logger.info('Changed selection to capturing chip at ($x, $y)');
        } else {
          lastErrorMessage = 'Capture is available - must capture!';
          _logger.warning('Cannot select non-capturing chip when capture is available');
        }
      } else {
        // No capture available - can select any chip
        selectedChip = tappedChip;
        _logger.info('Changed selection to chip at ($x, $y)');
      }
      return;
    }

    // Try to make a move or capture
    final direction = currentPlayer == 1 ? -1 : 1;

    // Check for capture first
    if (_canCapture(x, y, direction)) {
      _executeCapture(x, y);
    } else if (_canMove(x, y, direction)) {
      // Must capture rule: if capture is available, cannot make regular move
      if (captureAvailable) {
        lastErrorMessage = 'Capture is available - must capture!';
        _logger.warning('Cannot make regular move when capture is available');
        return;
      }
      _executeMove(x, y);
    } else {
      lastErrorMessage = 'Invalid move';
      _logger.warning('Invalid move attempt from (${selectedChip!.x},${selectedChip!.y}) to ($x, $y)');
    }
  }

  /// Handle taps during chain capture
  void _handleChainCaptureTap(int x, int y) {
    // Only allow the chaining chip to be selected/used
    if (selectedChip != currentChainChip) {
      selectedChip = currentChainChip;
    }

    final direction = currentPlayer == 1 ? -1 : 1;

    // Try to make another capture
    if (_canCapture(x, y, direction)) {
      _executeCapture(x, y);
    } else {
      lastErrorMessage = 'Must continue capturing!';
      _logger.warning('Player must continue capturing, but invalid tap at ($x, $y)');
    }
  }

  // ==================== MOVEMENT LOGIC ====================

  /// Check if a move to (x, y) is valid
  bool _canMove(int x, int y, int direction) {
    if (selectedChip == null || isOccupied(x, y)) return false;

    final dx = x - selectedChip!.x;
    final dy = y - selectedChip!.y;

    // Dama can move in both diagonal directions (forward and backward)
    if (selectedChip!.isDama) {
      // Multi-square slide for Dama - diagonal only
      if (dx.abs() == dy.abs()) {
        // Check if path is clear for multi-square move
        return _isPathClear(selectedChip!.x, selectedChip!.y, x, y);
      }
      return false;
    }

    // Regular chip: diagonal only, 1 square
    // Damath rules: chips move diagonally to capture/interact
    return dx.abs() == 1 && dy == direction;
  }

  /// Check if path is clear for multi-square Dama movement
  bool _isPathClear(int fromX, int fromY, int toX, int toY) {
    final dx = (toX - fromX).sign;
    final dy = (toY - fromY).sign;

    int x = fromX + dx;
    int y = fromY + dy;

    while (x != toX || y != toY) {
      if (isOccupied(x, y)) return false;
      x += dx;
      y += dy;
    }

    return true;
  }

  /// Check if capture is possible
  bool _canCapture(int x, int y, int direction) {
    if (selectedChip == null) return false;
    
    // Check bounds first
    if (x < 0 || x > 7 || y < 0 || y > 7) return false;

    final dx = x - selectedChip!.x;
    final dy = y - selectedChip!.y;

    // Dama can capture in any direction (forward and backward)
    if (selectedChip!.isDama) {
      return _canCaptureDama(x, y, dx, dy);
    }

    // Regular chip: can capture forward AND backward
    // Allow both forward (direction) and backward (-direction) captures
    if (dx.abs() != 2) return false;
    if (dy != 2 * direction && dy != 2 * -direction) return false;

    final midX = (x + selectedChip!.x) ~/ 2;
    final midY = (y + selectedChip!.y) ~/ 2;
    final midChip = chipAt(midX, midY);

    return midChip != null && isOpponent(selectedChip!, midChip) && !isOccupied(x, y);
  }

  /// Check if Dama can capture (in any direction)
  bool _canCaptureDama(int x, int y, int dx, int dy) {
    // Check bounds
    if (x < 0 || x > 7 || y < 0 || y > 7) return false;
    if (dx.abs() != 2 || dy.abs() != 2) return false;
    if (isOccupied(x, y)) return false;

    final midX = (x + selectedChip!.x) ~/ 2;
    final midY = (y + selectedChip!.y) ~/ 2;
    final midChip = chipAt(midX, midY);

    if (midChip == null || !isOpponent(selectedChip!, midChip)) return false;

    // Check if path is clear (excluding the captured chip position)
    return _isPathClearForCapture(selectedChip!.x, selectedChip!.y, x, y);
  }

  /// Check if path is clear for capture (allowing capture in middle)
  bool _isPathClearForCapture(int fromX, int fromY, int toX, int toY) {
    final dx = (toX - fromX).sign;
    final dy = (toY - fromY).sign;

    int x = fromX + dx;
    int y = fromY + dy;

    // Stop before the target (which is the landing spot after capture)
    while (x != toX || y != toY) {
      final chip = chipAt(x, y);
      // Allow the middle chip (the one being captured)
      if (chip != null && (x != (fromX + toX) ~/ 2 || y != (fromY + toY) ~/ 2)) {
        return false;
      }
      x += dx;
      y += dy;
    }

    return true;
  }

  // ==================== EXECUTE MOVE/CAPTURE ====================

  /// Execute a regular move
  void _executeMove(int x, int y) {
    _logger.info('Executing move from (${selectedChip!.x},${selectedChip!.y}) to ($x, $y)');

    // Check for operation tile
    final moveResult = processOperationMove(x, y);

    if (!moveResult.isValid) {
      lastErrorMessage = lastErrorMessage ?? 'Invalid move';
      return;
    }

    // Move the chip
    selectedChip!.x = x;
    selectedChip!.y = y;

    // Check for Dama promotion after move
    _checkAndPromoteDama(x, y);

    // Record position for draw detection
    _recordPosition();

    // Check for win condition
    _evaluateGameState();

    // End turn if game not over
    if (gamePhase == GamePhase.playing) {
      _endTurn();
    }
  }

  /// Execute a capture
  void _executeCapture(int x, int y) {
    // Check for Dama promotion before capture (Dama can capture from promotion row)
    final willPromote = _checkAndPromoteDama(x, y);
    
    int captureMidX, captureMidY;

    if (selectedChip!.isDama) {
      captureMidX = (x + selectedChip!.x) ~/ 2;
      captureMidY = (y + selectedChip!.y) ~/ 2;
    } else {
      captureMidX = (x + selectedChip!.x) ~/ 2;
      captureMidY = (y + selectedChip!.y) ~/ 2;
    }

    final capturedChip = chipAt(captureMidX, captureMidY);

    if (capturedChip == null || !isOpponent(selectedChip!, capturedChip)) {
      lastErrorMessage = 'No opponent to capture';
      return;
    }

    _logger.info('Executing capture from (${selectedChip!.x},${selectedChip!.y}) to ($x, $y), capturing at ($captureMidX, $captureMidY)');

    // Remove captured chip
    chips.remove(capturedChip);

    // Move the capturing chip
    selectedChip!.x = x;
    selectedChip!.y = y;

    // Increment chain depth
    captureChainDepth++;

    // Check for Dama promotion after capture (if not already promoted)
    final promoted = willPromote || _checkAndPromoteDama(x, y);

    // Check if another capture is available
    final canContinue = _hasAnotherCapture();

    if (canContinue) {
      // Must continue capturing
      mustContinueCapture = true;
      currentChainChip = selectedChip;
      _logger.info('Chain capture available, must continue. Depth: $captureChainDepth');
    } else {
      // End of capture chain
      mustContinueCapture = false;
      currentChainChip = null;
    }

    // Calculate score with chain captures using PDF specification
    double moveScore = 0;
    
    // For captures, we need to calculate per PDF spec
    final operationSymbol = getOperationAt(x, y);
    if (capturedChip != null && operationSymbol != null) {
      // Check if either chip is Dama for multiplier
      bool isTakerDama = selectedChip?.isDama ?? false;
      bool isTakenDama = capturedChip.isDama;
      
      moveScore = ScoreCalculator.calculateScorePDF(
        movingChipTerms: selectedChip!.terms,
        targetChipTerms: capturedChip.terms,
        operationSymbol: operationSymbol,
        targetX: x,
        targetY: y,
        isCapture: true,
        isDamaPromotion: promoted,
      );
      
      // Apply Dama multipliers per PDF spec
      if (isTakerDama && isTakenDama) {
        moveScore *= 4; // Both are Dama
      } else if (isTakerDama || isTakenDama) {
        moveScore *= 2; // One is Dama
      }
    }

    // Add chain capture bonus (1 point per additional capture)
    if (captureChainDepth > 1) {
      moveScore += (captureChainDepth - 1) * 1;
    }

    _updateScore(moveScore);

    // Record position for draw detection
    _recordPosition();

    // Check for win condition
    _evaluateGameState();

    // End turn if no more captures or game over
    if (!mustContinueCapture && gamePhase == GamePhase.playing) {
      _endTurn();
    }
  }

  /// Check if chip can capture again from current position
  bool _hasAnotherCapture() {
    if (selectedChip == null) return false;

    // Dama can capture in all diagonal directions
    if (selectedChip!.isDama) {
      final directions = [
        [-2, -2], [2, -2], [-2, 2], [2, 2]
      ];
      for (final dir in directions) {
        final targetX = selectedChip!.x + dir[0];
        final targetY = selectedChip!.y + dir[1];
        if (_canCapture(targetX, targetY, currentPlayer == 1 ? -1 : 1)) {
          return true;
        }
      }
      return false;
    }

    // Regular chip: can capture forward AND backward
    final forwardDir = currentPlayer == 1 ? -1 : 1;
    final backwardDir = -forwardDir;
    
    // Check forward captures
    final forwardCaptureX = selectedChip!.x + 2;
    final forwardCaptureY = selectedChip!.y + 2 * forwardDir;
    if (_canCapture(forwardCaptureX, forwardCaptureY, forwardDir)) return true;
    
    final forwardCaptureX2 = selectedChip!.x - 2;
    if (_canCapture(forwardCaptureX2, forwardCaptureY, forwardDir)) return true;
    
    // Check backward captures
    final backwardCaptureX = selectedChip!.x + 2;
    final backwardCaptureY = selectedChip!.y + 2 * backwardDir;
    if (_canCapture(backwardCaptureX, backwardCaptureY, backwardDir)) return true;
    
    final backwardCaptureX2 = selectedChip!.x - 2;
    if (_canCapture(backwardCaptureX2, backwardCaptureY, backwardDir)) return true;

    return false;
  }

  /// Check if the player must continue capturing (public getter)
  bool get mustContinueCapturing => mustContinueCapture;

  /// Get the current chain chip (the chip that must continue capturing)
  ChipModel? get currentChainChipModel => currentChainChip;

  /// Check if any capture is available for the current player (public getter for must capture rule)
  bool get isCaptureAvailable => hasAnyCaptureAvailable(currentPlayer);

  /// Get chips that can capture for the current player
  List<ChipModel> get capturingChips => getChipsThatCanCapture(currentPlayer);

  /// End the current player's turn
  void _endTurn() {
    currentPlayer = currentPlayer == 1 ? 2 : 1;
    selectedChip = null;
    captureChainDepth = 0;
    // Reset chain capture state
    mustContinueCapture = false;
    currentChainChip = null;
    _logger.info('Turn ended. Current player: $currentPlayer');
  }

  /// Update player score (now uses double for PDF-compliant scoring)
  void _updateScore(double score) {
    if (currentPlayer == 1) {
      player1Score += score;
    } else {
      player2Score += score;
    }
    _logger.info('Score updated. Player 1: $player1Score, Player 2: $player2Score');
  }

  // ==================== DAMA PROMOTION ====================

  /// Check and promote chip to Dama if applicable
  bool _checkAndPromoteDama(int x, int y) {
    if (selectedChip == null || selectedChip!.isDama) return false;

    // Player 1 (blue) promotes at row 0 (top)
    if (currentPlayer == 1 && y == 0) {
      selectedChip!.isDama = true;
      _logger.info('Player 1 chip promoted to Dama at ($x, $y)');
      return true;
    }

    // Player 2 (red) promotes at row 7 (bottom)
    if (currentPlayer == 2 && y == 7) {
      selectedChip!.isDama = true;
      _logger.info('Player 2 chip promoted to Dama at ($x, $y)');
      return true;
    }

    return false;
  }

  /// Check if a position is a promotion row for a player
  bool isPromotionRow(int y, int player) {
    return (player == 1 && y == 0) || (player == 2 && y == 7);
  }

  // ==================== VALID MOVE GETTERS ====================

  /// Get all valid moves for a chip
  /// This validates both geometric validity AND derivative requirements
  List<Move> getValidMoves(ChipModel chip) {
    final moves = <Move>[];

    // Determine allowed directions
    final directions = <List<int>>[];

    if (chip.isDama) {
      // Dama can move in all 4 diagonal directions (forward and backward)
      directions.addAll([
        [-1, -1], [1, -1], [-1, 1], [1, 1], // Diagonals only
      ]);
    } else {
      // Regular chip: diagonal only (forward only, but only diagonal directions)
      // Damath rules: chips move diagonally to capture/interact with operation tiles
      final forwardDir = chip.owner == 1 ? -1 : 1;
      directions.addAll([
        [-1, forwardDir], [1, forwardDir], // Diagonals only - no straight moves
      ]);
    }

    for (final dir in directions) {
      // For multi-slide (Dama), check all squares in direction
      final maxSteps = chip.isDama ? 7 : 1;

      for (int step = 1; step <= maxSteps; step++) {
        final targetX = chip.x + dir[0] * step;
        final targetY = chip.y + dir[1] * step;

        // Check bounds
        if (targetX < 0 || targetX > 7 || targetY < 0 || targetY > 7) {
          break;
        }

        // Check if occupied
        if (isOccupied(targetX, targetY)) {
          // For Dama, can capture if opponent is there and landing spot is empty
          if (chip.isDama && step > 1) {
            final midChip = chipAt(chip.x + dir[0] * (step - 1), chip.y + dir[1] * (step - 1));
            if (midChip != null && isOpponent(chip, midChip)) {
              final landingX = chip.x + dir[0] * (step + 1);
              final landingY = chip.y + dir[1] * (step + 1);
              if (landingX >= 0 && landingX <= 7 && landingY >= 0 && landingY <= 7 && !isOccupied(landingX, landingY)) {
                moves.add(Move(
                  fromX: chip.x,
                  fromY: chip.y,
                  toX: landingX,
                  toY: landingY,
                  isCapture: true,
                  capturedChipTerms: midChip.terms,
                ));
              }
            }
          }
          break;
        }

        // Valid move position - add to moves
        moves.add(Move(
          fromX: chip.x,
          fromY: chip.y,
          toX: targetX,
          toY: targetY,
        ));

        // For regular chips, only 1 step
        if (!chip.isDama) break;
      }
    }

    // Also add captures as moves
    for (final capture in getAvailableCaptures(chip)) {
      moves.add(Move(
        fromX: capture.fromX,
        fromY: capture.fromY,
        toX: capture.toX,
        toY: capture.toY,
        isCapture: true,
        capturedChipTerms: capture.capturedChip.terms,
      ));
    }

    // Filter moves to ensure derivative validation would pass
    // This prevents AI from selecting moves that would fail during execution
    final validatedMoves = _filterMovesByDerivativeValidation(chip, moves);
    
    return validatedMoves;
  }

  /// Filter moves based on derivative validation
  /// Removes moves that fail derivative validation during execution
  /// Also enforces that regular chips can only move DIAGONALLY (not forward/straight)
  List<Move> _filterMovesByDerivativeValidation(ChipModel chip, List<Move> moves) {
    final validatedMoves = <Move>[];
    
    for (final move in moves) {
      // For non-Dama chips, only allow diagonal moves (not straight forward)
      // This matches Damath rules: chips move diagonally to capture/interact
      if (!chip.isDama) {
        final dx = (move.toX - move.fromX).abs();
        
        // Only allow diagonal moves (dx == 1), NOT straight moves (dx == 0)
        // Regular chips can only move diagonally in Damath
        if (dx == 0) {
          // Skip straight moves for regular chips
          continue;
        }
      }
      
      // Get the operation at target position and check if there's an opponent chip there
      final targetChip = chipAt(move.toX, move.toY);
      
      // Derivative validation is ONLY required when moving to a tile WITH an opponent chip
      // (i.e., trying to interact with/capture that chip)
      if (targetChip != null && isOpponent(chip, targetChip)) {
        // There's an opponent chip at target - validate derivative
        final computedDerivative = computeDerivative(chip);
        final expectedResult = targetChip.terms;
        
        // Only include move if derivative matches
        if (!_mapsEqual(computedDerivative, expectedResult)) {
          // Derivative doesn't match - skip this move
          continue;
        }
      }
      
      // For all other cases (empty tile or own chip), allow the move
      // The chip can move forward even without an immediate derivative match
      validatedMoves.add(move);
    }
    
    return validatedMoves;
  }

  /// Check if chip has any opponent chip on board that matches its derivative
  bool _hasOpponentWithMatchingDerivative(ChipModel chip, Map<int, int> derivative) {
    final opponentChips = chips.where((c) => c.owner != chip.owner);
    
    for (final opponent in opponentChips) {
      if (_mapsEqual(derivative, opponent.terms)) {
        return true;
      }
    }
    return false;
  }

  /// Get all available capture moves for a chip
  List<CaptureMove> getAvailableCaptures(ChipModel chip) {
    final captures = <CaptureMove>[];

    // Dama captures in all diagonal directions
    if (chip.isDama) {
      final directions = [
        [-2, -2], [2, -2], [-2, 2], [2, 2]
      ];
      for (final dir in directions) {
        final targetX = chip.x + dir[0];
        final targetY = chip.y + dir[1];

        if (targetX < 0 || targetX > 7 || targetY < 0 || targetY > 7) continue;

        final midX = (chip.x + targetX) ~/ 2;
        final midY = (chip.y + targetY) ~/ 2;

        final midChip = chipAt(midX, midY);
        if (midChip != null && isOpponent(chip, midChip) && !isOccupied(targetX, targetY)) {
          captures.add(CaptureMove(
            fromX: chip.x,
            fromY: chip.y,
            toX: targetX,
            toY: targetY,
            midX: midX,
            midY: midY,
            capturedChip: midChip,
          ));
        }
      }
      return captures;
    }

    // Regular chip: captures forward AND backward
    final forwardDir = chip.owner == 1 ? -1 : 1;
    final backwardDir = -forwardDir;
    
    // Forward diagonal captures
    final forwardDirections = [
      [2, 2 * forwardDir],
      [-2, 2 * forwardDir],
    ];
    
    // Backward diagonal captures
    final backwardDirections = [
      [2, 2 * backwardDir],
      [-2, 2 * backwardDir],
    ];
    
    final allDirections = [...forwardDirections, ...backwardDirections];

    for (final dir in allDirections) {
      final targetX = chip.x + dir[0];
      final targetY = chip.y + dir[1];

      if (targetX < 0 || targetX > 7 || targetY < 0 || targetY > 7) continue;

      final midX = (chip.x + targetX) ~/ 2;
      final midY = (chip.y + targetY) ~/ 2;

      final midChip = chipAt(midX, midY);
      if (midChip != null && isOpponent(chip, midChip) && !isOccupied(targetX, targetY)) {
        captures.add(CaptureMove(
          fromX: chip.x,
          fromY: chip.y,
          toX: targetX,
          toY: targetY,
          midX: midX,
          midY: midY,
          capturedChip: midChip,
        ));
      }
    }

    return captures;
  }

  // ==================== MUST CAPTURE RULE ====================

  /// Check if any capture is available for a player
  /// This implements the "must capture" rule: if a capture is available,
  /// the player must capture with a chip that can capture
  bool hasAnyCaptureAvailable(int player) {
    for (final chip in chips.where((c) => c.owner == player)) {
      if (getAvailableCaptures(chip).isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// Get all chips that can capture for a player
  List<ChipModel> getChipsThatCanCapture(int player) {
    final capturingChips = <ChipModel>[];
    for (final chip in chips.where((c) => c.owner == player)) {
      if (getAvailableCaptures(chip).isNotEmpty) {
        capturingChips.add(chip);
      }
    }
    return capturingChips;
  }

  /// Check if a specific chip can capture
  bool chipCanCapture(ChipModel chip) {
    return getAvailableCaptures(chip).isNotEmpty;
  }

  /// Get all valid moves for a player
  List<Move> getAllValidMovesForPlayer(int player) {
    final allMoves = <Move>[];

    for (final chip in chips.where((c) => c.owner == player)) {
      allMoves.addAll(getValidMoves(chip));
    }

    return allMoves;
  }

  // ==================== WIN/LOSE DETECTION ====================

  /// Gets the current score for a player.
  double getScore(int playerNumber) {
    return playerNumber == 1 ? player1Score : player2Score;
  }

  /// Calculates final scores including remaining chips (per PDF spec).
  /// Call this when game ends to get accurate final scores.
  double getFinalScore(int playerNumber) {
    double score = playerNumber == 1 ? player1Score : player2Score;
    
    // Add remaining chips' values
    final remainingChips = chips.where((c) => c.owner == playerNumber).toList();
    for (final chip in remainingChips) {
      for (final entry in chip.terms.entries) {
        score += entry.value.abs();
      }
      // Double if Dama
      if (chip.isDama) {
        score *= 2;
      }
    }
    
    return score;
  }

  /// Legacy method for int score (kept for compatibility)
  int getScoreInt(int playerNumber) {
    return (playerNumber == 1 ? player1Score : player2Score).round();
  }

  /// Evaluates the game state for win/draw conditions using PDF scoring.
  /// Per PDF: Player with greater accumulated total scores wins.
  void _evaluateGameState() {
    // Check game end conditions per PDF rules:
    // - 20-minute game period lapses (not implemented - untimed mode)
    // - Moves are repetitive (threefold repetition)
    // - A player has no more chips to move
    // - An opponent's chip is 'cornered'
    
    final opponent = currentPlayer == 1 ? 2 : 1;

    // Check win by elimination
    final opponentChips = chips.where((c) => c.owner == opponent).toList();
    if (opponentChips.isEmpty) {
      // Add remaining chips to current player's score
      _applyEndGameScore(currentPlayer);
      _declareWinnerByScore(currentPlayer);
      return;
    }

    // Check win by blocking (opponent has no valid moves)
    final opponentMoves = getAllValidMovesForPlayer(opponent);
    if (opponentMoves.isEmpty) {
      _applyEndGameScore(currentPlayer);
      _declareWinnerByScore(currentPlayer);
      return;
    }

    // Check draw by repeated position
    if (_hasRepeatedPosition()) {
      // Both players get remaining chip scores, compare
      _applyEndGameScore(1);
      _applyEndGameScore(2);
      _declareDrawByScore();
      return;
    }
  }

  /// Applies end-of-game scores from remaining chips
  void _applyEndGameScore(int playerNumber) {
    final remainingChips = chips.where((c) => c.owner == playerNumber).toList();
    
    for (final chip in remainingChips) {
      double chipValue = 0;
      for (final entry in chip.terms.entries) {
        chipValue += entry.value.abs();
      }
      // Double if Dama
      if (chip.isDama) {
        chipValue *= 2;
      }
      
      if (playerNumber == 1) {
        player1Score += chipValue;
      } else {
        player2Score += chipValue;
      }
    }
    
    _logger.info('End game chips added for Player $playerNumber');
  }

  /// Declare winner based on accumulated score (per PDF)
  void _declareWinnerByScore(int playerNumber) {
    gamePhase = GamePhase.won;
    winner = playerNumber == 1
        ? PlayerModel(name: 'Player 1', color: PlayerColor.blue)
        : PlayerModel(name: 'Player 2', color: PlayerColor.red);
    
    final p1Final = getFinalScore(1);
    final p2Final = getFinalScore(2);
    
    // Determine winner by final score
    if (p1Final > p2Final) {
      gamePhase = GamePhase.won;
      winner = PlayerModel(name: 'Player 1', color: PlayerColor.blue);
    } else if (p2Final > p1Final) {
      gamePhase = GamePhase.won;
      winner = PlayerModel(name: 'Player 2', color: PlayerColor.red);
    } else {
      gamePhase = GamePhase.draw;
      winner = null;
    }
    
    _logger.info('Game over! Final scores - Player 1: $p1Final, Player 2: $p2Final. Winner: ${winner?.name ?? "Draw"}');
  }

  /// Declare draw when scores are equal
  void _declareDrawByScore() {
    final p1Final = getFinalScore(1);
    final p2Final = getFinalScore(2);
    
    if (p1Final == p2Final) {
      gamePhase = GamePhase.draw;
      winner = null;
      _logger.info('Game over! Draw by equal scores: $p1Final');
    } else {
      // One player has higher score
      _declareWinnerByScore(p1Final > p2Final ? 1 : 2);
    }
  }

  /// Check if game is over
  bool get isGameOver => gamePhase != GamePhase.playing;

  /// Check if game is a draw
  bool get isDraw => gamePhase == GamePhase.draw;

  /// Get current winner
  PlayerModel? get currentWinner => winner;

  /// Declare a winner
  void _declareWinner(int playerNumber) {
    gamePhase = GamePhase.won;
    winner = playerNumber == 1
        ? PlayerModel(name: 'Player 1', color: PlayerColor.blue)
        : PlayerModel(name: 'Player 2', color: PlayerColor.red);
    _logger.info('Game over! Winner: Player $playerNumber');
  }

  /// Declare a draw
  void _declareDraw() {
    gamePhase = GamePhase.draw;
    winner = null;
    _logger.info('Game over! Draw by repeated position');
  }

  /// Public method to check game state (for external calls)
  void evaluateGameState() {
    _evaluateGameState();
  }

  /// Check if a player has any valid moves
  bool hasValidMoves(int player) {
    return getAllValidMovesForPlayer(player).isNotEmpty;
  }

  // ==================== HELPER METHODS ====================

  /// Check if a tile is occupied by another chip
  bool isOccupied(int x, int y) {
    return chips.any((chip) => chip.x == x && chip.y == y);
  }

  /// Check if the given chips are opponents
  bool isOpponent(ChipModel a, ChipModel b) {
    return a.owner != b.owner;
  }

  /// Get the chip at a specific position
  ChipModel? chipAt(int x, int y) {
    try {
      return chips.firstWhere((chip) => chip.x == x && chip.y == y);
    } catch (e) {
      return null;
    }
  }

  // ==================== DERIVATIVE INTEGRATION ====================

  /// Gets the operation symbol at a given board position.
  String? getOperationAt(int x, int y) {
    final operationsBoard = getOperationsBoard();
    if (x >= 0 && x < 8 && y >= 0 && y < 8) {
      return operationsBoard[y][x];
    }
    return null;
  }

  /// Checks if a position contains an operation tile (+, −, ×, ÷)
  bool isOperationTile(int x, int y) {
    final operation = getOperationAt(x, y);
    return operation != null && operation.isNotEmpty;
  }

  /// Gets the operation type from the symbol
  OperationType? getOperationType(String symbol) {
    switch (symbol) {
      case '+':
        return OperationType.add;
      case '−':
        return OperationType.subtract;
      case '×':
        return OperationType.multiply;
      case '÷':
        return OperationType.divide;
      default:
        return null;
    }
  }

  /// Computes the derivative of a chip's polynomial.
  Map<int, int> computeDerivative(ChipModel chip) {
    return DerivativeRules.powerRule(chip.terms);
  }

  /// Validates if the moving chip's derivative matches the expected result
  bool validateDerivativeMove(ChipModel movingChip, int targetX, int targetY) {
    final operationSymbol = getOperationAt(targetX, targetY);
    if (operationSymbol == null || operationSymbol.isEmpty) {
      return true;
    }

    final opponentChip = chipAt(targetX, targetY);
    if (opponentChip == null) {
      return true;
    }

    final computedDerivative = computeDerivative(movingChip);
    final expectedResult = opponentChip.terms;

    return _mapsEqual(computedDerivative, expectedResult);
  }

  /// Compares two polynomial maps for equality.
  bool _mapsEqual(Map<int, int> map1, Map<int, int> map2) {
    if (map1.length != map2.length) return false;
    for (final entry in map1.entries) {
      if (map2[entry.key] != entry.value) return false;
    }
    return true;
  }

  /// Processes a move to an operation tile with derivative validation.
  MoveResult processOperationMove(int x, int y) {
    if (selectedChip == null) {
      lastErrorMessage = 'No chip selected';
      return MoveResult.failure();
    }

    final operationSymbol = getOperationAt(x, y);
    if (operationSymbol == null || operationSymbol.isEmpty) {
      return MoveResult.success();
    }

    final opponentChip = chipAt(x, y);

    final computedDerivative = computeDerivative(selectedChip!);

    bool isCorrect = true;
    if (opponentChip != null) {
      final expectedResult = opponentChip.terms;
      isCorrect = _mapsEqual(computedDerivative, expectedResult);

      if (!isCorrect) {
        lastErrorMessage = 'Incorrect derivative!';
        _logger.warning('Derivative validation failed: $lastErrorMessage');
        return MoveResult.failure();
      }
    }

    Map<int, int>? resultPolynomial;
    if (opponentChip != null) {
      resultPolynomial = _applyOperation(
        selectedChip!.terms,
        opponentChip.terms,
        operationSymbol,
      );
    }

    // Transform the chip with the result polynomial
    if (resultPolynomial != null) {
      selectedChip!.terms.clear();
      selectedChip!.terms.addAll(resultPolynomial);
    }

    lastMoveResult = MoveResult.success(
      isCapture: opponentChip != null,
      isDamaPromotion: false,
      captureCount: 0,
      resultPolynomial: resultPolynomial,
    );

    _logger.info('Operation move successful. Operation: $operationSymbol');
    return lastMoveResult!;
  }

  /// Applies a mathematical operation between two polynomials.
  Map<int, int> _applyOperation(
    Map<int, int> left,
    Map<int, int> right,
    String operation,
  ) {
    final result = <int, int>{};

    switch (operation) {
      case '+':
        for (final entry in left.entries) {
          result[entry.key] = entry.value;
        }
        for (final entry in right.entries) {
          result[entry.key] = (result[entry.key] ?? 0) + entry.value;
        }
        break;

      case '−':
        for (final entry in left.entries) {
          result[entry.key] = entry.value;
        }
        for (final entry in right.entries) {
          result[entry.key] = (result[entry.key] ?? 0) - entry.value;
        }
        break;

      case '×':
        for (final entry1 in left.entries) {
          for (final entry2 in right.entries) {
            final newExp = entry1.key + entry2.key;
            final newCoeff = entry1.value * entry2.value;
            result[newExp] = (result[newExp] ?? 0) + newCoeff;
          }
        }
        break;

      case '÷':
        for (final entry in left.entries) {
          result[entry.key] = entry.value;
        }
        break;
    }

    result.removeWhere((key, value) => value == 0);
    return result;
  }

  /// Resets the game to initial state.
  void reset() {
    chips = getInitialChips();
    selectedChip = null;
    currentPlayer = 1;
    player1Score = 0;
    player2Score = 0;
    lastMoveResult = null;
    lastErrorMessage = null;

    // Reset Phase 3 state
    mustContinueCapture = false;
    currentChainChip = null;
    captureChainDepth = 0;
    gamePhase = GamePhase.playing;
    winner = null;
    positionHistory.clear();
  }

  /// Get chips for a player
  List<ChipModel> getChipsForPlayer(int player) {
    return chips.where((chip) => chip.owner == player).toList();
  }

  /// Get chip count for a player
  int getChipCount(int player) {
    return chips.where((chip) => chip.owner == player).length;
  }

  /// Get Dama count for a player
  int getDamaCount(int player) {
    return chips.where((chip) => chip.owner == player && chip.isDama).length;
  }

  /// Execute a move from the AI opponent.
  /// This method handles selecting the chip and moving it to the destination.
  void executeMove(Move move) {
    // If game is over, ignore
    if (gamePhase != GamePhase.playing) return;

    // First, clear any existing selection to ensure clean state
    selectedChip = null;

    // Find and select the chip at the from position
    final chip = chipAt(move.fromX, move.fromY);
    if (chip == null) {
      _logger.warning('Cannot execute move: no chip at (${move.fromX}, ${move.fromY})');
      return;
    }
    
    if (chip.owner != currentPlayer) {
      _logger.warning('Cannot execute move: chip at (${move.fromX}, ${move.fromY}) belongs to player ${chip.owner}, but current player is $currentPlayer');
      return;
    }

    // Verify this exact move is still valid (executability check)
    // This ensures derivative validation passes before attempting execution
    final validMoves = getValidMoves(chip);
    final isValidMove = validMoves.any((m) => 
      m.toX == move.toX && m.toY == move.toY);
    
    if (!isValidMove) {
      _logger.warning('Move from (${move.fromX}, ${move.fromY}) to (${move.toX}, ${move.toY}) failed executability check - derivative validation likely failed');
      return;
    }

    // Select the chip
    selectedChip = chip;
    _logger.info('AI selected chip at (${move.fromX}, ${move.fromY}), attempting to move to (${move.toX}, ${move.toY})');

    // Execute the move via tile tap
    onTileTap(move.toX, move.toY);
    
    _logger.info('AI move completed. New position: (${chip.x}, ${chip.y}), currentPlayer is now $currentPlayer');
  }
}
