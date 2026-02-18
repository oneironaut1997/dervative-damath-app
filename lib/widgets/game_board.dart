import 'package:flutter/material.dart';
import '../models/chip_model.dart';
import '../models/player_model.dart';
import '../utils/operations_layout.dart';
import '../utils/game_logic.dart';
import '../utils/ai_opponent.dart';
import 'score_board.dart';
import 'player_info_card.dart';
import 'draggable_piece.dart';

class GameBoard extends StatefulWidget {
  final String mode; // "PvP" or "PvC"
  
  const GameBoard({super.key, required this.mode});

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
  bool isAIThinking = false; // Track if AI is thinking

  // Player models for PlayerInfoCard
  late PlayerModel player1;
  late PlayerModel player2;

  // AI Opponent (initialized when mode is PvC)
  AIOpponent? aiOpponent;

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
  }

  /// Refreshes state from gameLogic
  void _refreshState() {
    setState(() {
      chips = gameLogic.chips;
      currentPlayer = gameLogic.currentPlayer;
      player1Score = gameLogic.player1Score.round();
      player2Score = gameLogic.player2Score.round();
      selectedChip = gameLogic.selectedChip;
      isGameOver = gameLogic.isGameOver;
      mustContinueCapturing = gameLogic.mustContinueCapturing;
      
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
    onTileTap(toX, toY);
  }

  void onTileTap(int x, int y) {
    // If game is over, ignore taps
    if (isGameOver) return;
    
    // In PvC mode, ignore taps when it's AI's turn or AI is thinking
    // Use gameLogic.currentPlayer to get the actual current player
    if (widget.mode == 'PvC' && (gameLogic.currentPlayer == 2 || isAIThinking)) return;
    
    // Delegate to game logic
    gameLogic.onTileTap(x, y);
    
    // Update captured count
    final p1Chips = gameLogic.getChipCount(1);
    final p2Chips = gameLogic.getChipCount(2);
    player1Captured = 12 - p1Chips;
    player2Captured = 12 - p2Chips;
    
    // Refresh state from game logic - this updates mustContinueCapturing
    _refreshState();
    
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
    
    // Small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (isGameOver) return;
    
    // Get the best move from AI
    final move = aiOpponent!.getBestMove();
    
    if (move != null) {
      // Execute the AI move
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
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
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
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PlayerInfoCard(
                    player: player2,
                    chipsRemaining: chipsRemainingForPlayer(2),
                    capturedCount: player2Captured,
                    isActive: currentPlayer == 2,
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
                // Show "Must Continue Capturing" indicator
                if (mustContinueCapturing)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '⚠️ Must Continue Capturing!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                // Reset Game Button
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ElevatedButton.icon(
                    onPressed: () => _showResetConfirmationDialog(),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset Game'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
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
                                    DraggablePiece(
                                      chip: chipHere,
                                      isDraggable: chipHere.owner == currentPlayer && !isGameOver && !mustContinueCapturing,
                                      size: cellSize * 0.8,
                                    ),
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
      ],
    ),
    );
  }
}
