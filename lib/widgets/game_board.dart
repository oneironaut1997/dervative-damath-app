import 'package:flutter/material.dart';
import 'dart:async';

import '../models/chip_model.dart';
import '../models/player_model.dart';
import '../utils/operations_layout.dart';
import '../utils/game_logic.dart';
import '../utils/ai_opponent.dart';
import '../utils/sound_service.dart';
import '../widgets/move_history_modal.dart';
import 'score_board.dart';
import 'player_info_card.dart';
import 'draggable_piece.dart';

class GameBoard extends StatefulWidget {
  final String mode; // "PvP" or "PvC"
  final bool useTimer; // Whether to enable turn timer
  
  const GameBoard({
    super.key,
    required this.mode,
    this.useTimer = true,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late GameLogic gameLogic;
  late List<ChipModel> chips;
  ChipModel? selectedChip;
  int currentPlayer = 1; // 1 = blue, 2 = red
  int player1Score = 0; // Player 1 (blue) score
  int player2Score = 0; // Player 2 (red) score
  int player1Captured = 0; // Number of pieces Player 1 has captured
  int player2Captured = 0; // Number of pieces Player 2 has captured
  bool isGameOver = false;
  String? winnerMessage;
  bool mustContinueCapturing = false; // Track if player must continue chain capture
  bool isCaptureAvailable = false; // Track if any capture is available (must capture rule)
  bool isAIThinking = false; // Track if AI is thinking

  // Board rotation for PvP mode (0 = Player 1 perspective, 180 = Player 2 perspective)
  double _boardRotation = 0;

  // Track previous counts for sound triggers
  int _previousPlayer1Chips = 12;
  int _previousPlayer2Chips = 12;
  int _previousDamaCount = 0;
  bool _moveMade = false; // Track if a move was made (for move sound)

  // Player models for PlayerInfoCard
  late PlayerModel player1;
  late PlayerModel player2;

  // AI Opponent (initialized when mode is PvC)
  AIOpponent? aiOpponent;

  // Turn timer variables
  Timer? _turnTimer;
  int _remainingSeconds = 120; // Remaining time for current turn
  static const int turnTimeLimit = 120; // 2 minutes per turn

  final operations = getOperationsBoard(); // 8x8 String grid

  @override
  void initState() {
    super.initState();
    // Initialize game logic
    gameLogic = GameLogic();
    chips = gameLogic.chips;
    
    // Initialize AI if PvC mode
    if (widget.mode == 'PvC') {
      aiOpponent = AIOpponent(
        difficulty: AIDifficulty.medium, // Default to medium
        // difficulty: AIDifficulty.hard, // Default to hard
        gameLogic: gameLogic,
      );
    }
    
    // Initialize player models
    player1 = PlayerModel(
      name: 'Player 1',
      color: PlayerColor.blue,
      score: 0,
    );
    player2 = PlayerModel(
      name: widget.mode == 'PvC' ? 'Computer' : 'Player 2',
      color: PlayerColor.red,
      score: 0,
    );

    // Start the turn timer only if useTimer is true
    if (widget.useTimer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTimer();
      });
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  /// Start the turn timer - resets to full 2 minutes for each new turn
  void _startTimer() {
    _stopTimer();
    _remainingSeconds = turnTimeLimit; // Always reset to full 2 minutes
    
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
      
      // Play timer warning sound when timer is <= 10 seconds
      if (_remainingSeconds <= 10 && _remainingSeconds > 0) {
        SoundService().playTimerWarning();
      }
      
      if (_remainingSeconds <= 0) {
        _onTurnTimeout();
      }
    });
  }

  /// Stop the turn timer
  void _stopTimer() {
    _turnTimer?.cancel();
    _turnTimer = null;
  }

  /// Handle turn timeout - deduct points and switch turn
  void _onTurnTimeout() {
    _stopTimer();
    
    // Deduct 10k points from current player
    // If score is already negative, subtracting more makes it more negative
    if (currentPlayer == 1) {
      player1Score -= 10000;
      player1.score = player1Score;
      // Also update gameLogic's internal score
      gameLogic.player1Score = player1Score.toDouble();
    } else {
      player2Score -= 10000;
      player2.score = player2Score;
      // Also update gameLogic's internal score
      gameLogic.player2Score = player2Score.toDouble();
    }
    
    // Play timeout sound
    SoundService().playTimeout();
    
    // Switch turn to opponent
    _switchTurnWithTimer();
  }

  /// Switch turn to opponent and start their timer
  void _switchTurnWithTimer() {
    gameLogic.currentPlayer = gameLogic.currentPlayer == 1 ? 2 : 1;
    
    // Toggle board rotation in PvP mode only
    if (widget.mode == 'PvP') {
      setState(() {
        _boardRotation = gameLogic.currentPlayer == 1 ? 0 : 180;
      });
    }
    
    _refreshState();
    
    // Start timer only if useTimer is enabled
    if (widget.useTimer) {
      _startTimer();
    }
    
    // In PvC mode, if it's now AI's turn (player 2), trigger AI move
    if (widget.mode == 'PvC' && gameLogic.currentPlayer == 2 && !isGameOver) {
      _triggerAIMove();
    }
  }

  /// Get formatted time string (MM:SS)
  String get _timerDisplay {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Refreshes state from gameLogic
  void _refreshState() {
    // Check for capture sound (when chip count decreases)
    final currentP1Chips = gameLogic.getChipCount(1);
    final currentP2Chips = gameLogic.getChipCount(2);
    final currentDamaCount = gameLogic.getDamaCount(1) + gameLogic.getDamaCount(2);
    
    // Detect captures
    if (currentP1Chips < _previousPlayer1Chips || currentP2Chips < _previousPlayer2Chips) {
      SoundService().playCaptured();
    } else if (_moveMade && !isGameOver) {
      // No capture happened but a move was made - play move sound
      SoundService().playMove();
    }
    
    // Reset move flag after handling
    _moveMade = false;
    
    // Detect Dama promotion
    if (currentDamaCount > _previousDamaCount) {
      SoundService().playDama();
    }
    
    // Update previous counts
    _previousPlayer1Chips = currentP1Chips;
    _previousPlayer2Chips = currentP2Chips;
    _previousDamaCount = currentDamaCount;
    
    setState(() {
      chips = gameLogic.chips;
      currentPlayer = gameLogic.currentPlayer;
      player1Score = gameLogic.player1Score.round();
      player2Score = gameLogic.player2Score.round();
      selectedChip = gameLogic.selectedChip;
      isGameOver = gameLogic.isGameOver;
      mustContinueCapturing = gameLogic.mustContinueCapturing;
      isCaptureAvailable = gameLogic.isCaptureAvailable; // Must capture rule
      
      // Update player models
      player1.score = player1Score;
      player2.score = player2Score;
      
      // Check for winner
      if (isGameOver) {
        final winner = gameLogic.currentWinner;
        if (winner != null) {
          winnerMessage = '${winner.name} Wins!';
        } else if (gameLogic.isDraw) {
          winnerMessage = 'Draw!';
        }
        // Play game over sound
        SoundService().playGameOver();
        // Stop the timer when game is over
        _stopTimer();
        // Show game over dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showGameOverDialog();
        });
      }
    });
  }

  bool isOccupied(int x, int y) => gameLogic.isOccupied(x, y);

  ChipModel? chipAt(int x, int y) {
    return gameLogic.chipAt(x, y);
  }

  bool isOpponent(ChipModel a, ChipModel b) => gameLogic.isOpponent(a, b);

  /// Check if a chip can move (considering must capture rule)
  bool _canChipMove(ChipModel chip) {
    // If must continue capturing (chain capture), only the chain chip can move
    if (mustContinueCapturing) {
      return gameLogic.currentChainChipModel != null &&
             gameLogic.currentChainChipModel!.x == chip.x &&
             gameLogic.currentChainChipModel!.y == chip.y;
    }
    // If capture is available, only chips that can capture can move
    if (isCaptureAvailable) {
      return gameLogic.chipCanCapture(chip);
    }
    // Otherwise, chip can move
    return true;
  }

  /// Build chip with glow effect for chips that can capture
  Widget _buildChipWithGlow(ChipModel chip, double cellSize) {
    final bool canCapture = gameLogic.chipCanCapture(chip);
    final bool shouldGlow = isCaptureAvailable && !mustContinueCapturing && canCapture && chip.owner == currentPlayer;
    
    return Container(
      decoration: shouldGlow
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.8),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            )
          : null,
      child: DraggablePiece(
        chip: chip,
        isDraggable: chip.owner == currentPlayer && !isGameOver && _canChipMove(chip),
        size: cellSize * 0.8,
      ),
    );
  }

  /// Check if a tile is a valid drop target
  bool _isValidDropTarget(int x, int y) {
    if (selectedChip == null) return false;
    
    // Can't drop on occupied tiles
    if (isOccupied(x, y)) return false;
    
    // Check if it's a valid move for the selected chip using public API
    final validMoves = gameLogic.getValidMoves(selectedChip!);
    return validMoves.any((move) => move.toX == x && move.toY == y);
  }

  /// Handle chip drop
  void _onChipDropped(ChipModel chip, int toX, int toY) {
    // Only allow dropping if it's the chip's turn and it's a valid move
    if (chip.owner != currentPlayer) return;
    if (!_isValidDropTarget(toX, toY)) return;
    
    // Select the chip and make the move
    selectedChip = chip;
    _moveMade = true; // Mark that a move was attempted
    onTileTap(toX, toY);
  }

  void onTileTap(int x, int y) {
    // If game is over, ignore taps
    if (isGameOver) return;
    
    // In PvC mode, ignore taps when it's AI's turn or AI is thinking
    // Use gameLogic.currentPlayer to get the actual current player
    if (widget.mode == 'PvC' && (gameLogic.currentPlayer == 2 || isAIThinking)) return;
    
    // Save the current player BEFORE making the move
    final previousPlayer = currentPlayer;
    
    // Check if a valid move was made by comparing move history
    // The gameLogic.onTileTap will only make a move if it's valid
    final previousMoveCount = gameLogic.history.length;
    
    // Delegate to game logic
    gameLogic.onTileTap(x, y);
    
    // If move history increased, a valid move was made - set flag for sound
    // This must be done BEFORE _refreshState() because it checks and resets this flag
    if (gameLogic.history.length > previousMoveCount) {
      _moveMade = true;
    }
    
    // Update captured count
    final p1Chips = gameLogic.getChipCount(1);
    final p2Chips = gameLogic.getChipCount(2);
    player1Captured = 12 - p1Chips;
    player2Captured = 12 - p2Chips;
    
    // Refresh state from game logic - this plays the move sound if _moveMade is true
    _refreshState();
    
    // Restart timer after a valid move (only if turn switched and timer is enabled)
    // Check if player changed (turn was switched)
    if (currentPlayer != previousPlayer && !mustContinueCapturing && widget.useTimer) {
      _startTimer();
    }
    
    // Toggle board rotation in PvP mode when turn switches
    if (currentPlayer != previousPlayer && !mustContinueCapturing && widget.mode == 'PvP') {
      // Add 1 second delay before rotating the board
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _boardRotation = gameLogic.currentPlayer == 1 ? 0 : 180;
          });
        }
      });
    }
    
    // Trigger AI move if it's PvC mode and now AI's turn
    // Use gameLogic.currentPlayer to check if it's AI's turn after the move
    // Only trigger if NOT must continue capturing (chain capture)
    if (widget.mode == 'PvC' && gameLogic.currentPlayer == 2 && !mustContinueCapturing && !isGameOver) {
      _triggerAIMove();
    }
  }

  /// Triggers AI move execution with a small delay for better UX
  void _triggerAIMove() async {
    if (aiOpponent == null || isGameOver) return;
    
    setState(() {
      isAIThinking = true;
    });
    
    // 1 second delay before computer moves for better UX
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (isGameOver) return;
    
    // Get the best move from AI
    final move = aiOpponent!.getBestMove();
    
    if (move != null) {
      // Execute the AI move
      _moveMade = true; // Mark that AI made a move
      gameLogic.executeMove(move);
      
      // Update captured count
      final p1Chips = gameLogic.getChipCount(1);
      final p2Chips = gameLogic.getChipCount(2);
      player1Captured = 12 - p1Chips;
      player2Captured = 12 - p2Chips;
      
      // Refresh state
      _refreshState();
      
      // Check if AI must continue capturing (chain capture)
      // If still AI's turn and must continue, trigger another move
      if (!isGameOver && gameLogic.currentPlayer == 2 && gameLogic.mustContinueCapturing) {
        // Continue with chain capture after a short delay
        await Future.delayed(const Duration(milliseconds: 300));
        if (!isGameOver) {
          _triggerAIMove();
        }
      }
    }
    
    setState(() {
      isAIThinking = false;
    });
    
    // Restart timer after AI move (if turn switched to human and timer is enabled)
    if (!isGameOver && gameLogic.currentPlayer == 1 && widget.useTimer) {
      _startTimer();
    }
  }

  /// Shows game over dialog
  void _showGameOverDialog() {
    if (!isGameOver || winnerMessage == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: Text(
          winnerMessage!,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Reset captured count for new game
              player1Captured = 0;
              player2Captured = 0;
              // Restart game
              gameLogic.reset();
              _refreshState();
              // Restart timer for new game (only if useTimer is true)
              if (widget.useTimer) {
                _startTimer();
              }
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  /// Shows confirmation dialog before resetting the game
  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Game?'),
        content: const Text(
          'Are you sure you want to reset the game? All progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Reset captured count
              player1Captured = 0;
              player2Captured = 0;
              // Reset game
              gameLogic.reset();
              _refreshState();
              // Restart timer (only if useTimer is true)
              if (widget.useTimer) {
                _startTimer();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  /// Shows the move history modal
  void _showMoveHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MoveHistoryModal(
        history: gameLogic.history,
      ),
    );
  }

  /// Gets the number of chips remaining for a player
  int chipsRemainingForPlayer(int playerNumber) {
    return gameLogic.getChipCount(playerNumber);
  }

  @override
  Widget build(BuildContext context) {
    final double cellSize = (MediaQuery.of(context).size.width - 64) / 8;
    const double labelWidth = 16; // Compact label width

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Player Info Cards - displays detailed player information
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: PlayerInfoCard(
                    player: player1,
                    chipsRemaining: chipsRemainingForPlayer(1),
                    capturedCount: player1Captured,
                    isActive: currentPlayer == 1,
                    remainingTime: widget.useTimer && currentPlayer == 1 ? _remainingSeconds : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PlayerInfoCard(
                    player: player2,
                    chipsRemaining: chipsRemainingForPlayer(2),
                    capturedCount: player2Captured,
                    isActive: currentPlayer == 2,
                    remainingTime: widget.useTimer && currentPlayer == 2 ? _remainingSeconds : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Score Board - displays scores for both players
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                ScoreBoard(
                  player1Score: player1Score,
                  player2Score: player2Score,
                  currentPlayer: currentPlayer,
                  player1Name: 'Player 1',
                  player2Name: 'Player 2',
                ),
                // Reset Game Button
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // History Button
                      IconButton(
                        onPressed: () => _showMoveHistory(context),
                        icon: const Icon(Icons.history),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(8),
                        ),
                        tooltip: 'Move History',
                      ),
                      const SizedBox(width: 12),
                      // Reset Button
                      IconButton(
                        onPressed: () => _showResetConfirmationDialog(),
                        icon: const Icon(Icons.refresh),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AnimatedRotation(
            turns: _boardRotation / 360,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
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
                children: [
                  // Board rows with y-axis labels (7 to 0 from top to bottom)
                  ...List.generate(8, (rowIndex) {
                    final y = 7 - rowIndex; // Reverse: 7 at top, 0 at bottom
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Y-axis label (left side)
                        SizedBox(
                          width: labelWidth,
                          child: Text(
                            '$y',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        // Board tiles (x goes 0 to 7 left to right)
                        ...List.generate(8, (x) {
                          final isWhite = (x + y) % 2 == 0;
                          final bgColor = isWhite
                              ? const Color(0xFFF1E9D2)
                              : const Color(0xFF6B4A3A);

                          final chipHere = chipAt(x, y);
                          final isSelected = selectedChip != null &&
                              selectedChip!.x == x &&
                              selectedChip!.y == y;
                          final isChainChip = mustContinueCapturing && 
                              gameLogic.currentChainChipModel != null &&
                              gameLogic.currentChainChipModel!.x == x &&
                              gameLogic.currentChainChipModel!.y == y;

                          final op = operations[y][x];

                          return DragTarget<ChipModel>(
                            onWillAcceptWithDetails: (details) {
                              final chip = details.data;
                              if (chip.owner == currentPlayer && !isOccupied(x, y)) {
                                // Check if this is a valid move
                                final validMoves = gameLogic.getValidMoves(chip);
                                return validMoves.any((move) => move.toX == x && move.toY == y);
                              }
                              return false;
                            },
                            onAcceptWithDetails: (details) {
                              _onChipDropped(details.data, x, y);
                            },
                            builder: (context, candidateData, rejectedData) {
                              final isValidTarget = candidateData.isNotEmpty;
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
                                        : isChainChip
                                            ? Border.all(color: Colors.orange, width: 3)
                                            : isValidTarget
                                                ? Border.all(color: Colors.green, width: 3)
                                                : null,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      if (op.isNotEmpty)
                                        Text(
                                          op,
                                          style: TextStyle(
                                            fontSize: cellSize * 0.5,
                                            fontWeight: FontWeight.bold,
                                            color: isWhite ? Colors.black87 : Colors.white,
                                          ),
                                        ),
                                      if (chipHere != null)
                                        _buildChipWithGlow(chipHere, cellSize),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    );
                  }),
                  // X-axis labels (0-7) at the bottom
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: labelWidth), // Spacer for y-axis labels
                      ...List.generate(8, (x) {
                        return SizedBox(
                          width: cellSize + 2, // Match cell width + margin
                          child: Text(
                            '$x',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
    );
  }
}
