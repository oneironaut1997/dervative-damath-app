import 'package:flutter/material.dart';
import '../models/move_history_model.dart';

/// Modal dialog that displays the move history of the game.
/// 
/// Shows each move with:
/// - Move number
/// - Player who made the move
/// - Movement coordinates
/// - Move type (move, capture, chain capture)
/// - Operation used (if any)
/// - Captured chip terms (if capture)
/// - Calculation details
/// - Points earned
class MoveHistoryModal extends StatelessWidget {
  /// List of all moves in the game
  final List<MoveHistoryEntry> history;

  const MoveHistoryModal({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.92,
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Move list
            Expanded(
              child: history.isEmpty 
                  ? _buildEmptyState()
                  : _buildMoveList(),
            ),
            // Footer with close button
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.history,
            color: Colors.white70,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'Move History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${history.length} moves',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            color: Colors.white30,
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            'No moves yet',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start playing to see the move history',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final entry = history[index];
        return _buildMoveCard(entry, index);
      },
    );
  }

  Widget _buildMoveCard(MoveHistoryEntry entry, int index) {
    // Alternate card colors for better readability
    final isEven = index % 2 == 0;
    final cardColor = isEven 
        ? Colors.white.withValues(alpha: 0.05) 
        : Colors.white.withValues(alpha: 0.1);
    
    // Player colors
    final playerColor = entry.player == 1 
        ? const Color(0xFF42A5F5) // Blue for Player 1
        : const Color(0xFFEF5350); // Red for Player 2
    
    // Move type icon and color
    IconData moveIcon;
    Color moveTypeColor;
    if (entry.isCapture) {
      if (entry.captureCount > 1) {
        moveIcon = Icons.bolt; // Chain capture
        moveTypeColor = Colors.orange;
      } else {
        moveIcon = Icons.gps_fixed; // Regular capture
        moveTypeColor = Colors.red;
      }
    } else if (entry.isDamaPromotion) {
      moveIcon = Icons.star;
      moveTypeColor = Colors.amber;
    } else {
      moveIcon = Icons.arrow_forward;
      moveTypeColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: playerColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Move number and player
            Row(
              children: [
                // Move number badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: playerColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#${entry.moveNumber}',
                    style: TextStyle(
                      color: playerColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Player name
                Text(
                  entry.playerName,
                  style: TextStyle(
                    color: playerColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                // Move type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: moveTypeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(moveIcon, size: 14, color: moveTypeColor),
                      const SizedBox(width: 4),
                      Text(
                        entry.moveTypeDescription,
                        style: TextStyle(
                          color: moveTypeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Movement coordinates
            Row(
              children: [
                const Icon(Icons.swap_horiz, size: 18, color: Colors.white54),
                const SizedBox(width: 8),
                Text(
                  entry.moveString,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 12),
                // Algebraic notation
                Text(
                  entry.algebraicNotation,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            
            // Chip terms (if any)
            if (entry.chipTerms.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.circle, size: 10, color: Colors.white38),
                  const SizedBox(width: 8),
                  Text(
                    'Chip: ${entry.chipTerms}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  if (entry.isDamaPromotion) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'DAMA',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            
            // Operation and capture info
            if (entry.isCapture && entry.capturedChipTerms != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.gps_fixed, size: 14, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    'Captured: ${entry.capturedChipTerms}',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
            
            // Operation tile used
            if (entry.operation.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        entry.operation,
                        style: const TextStyle(
                          color: Colors.purpleAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Operation tile',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            // Calculation details
            if (entry.calculationDetails.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  entry.calculationDetails,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
            
            // Points earned
            if (entry.pointsEarned > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.pointsString,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue.withValues(alpha: 0.3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Close',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the move history modal dialog.
/// 
/// [context] - The build context
/// [history] - The list of move history entries to display
void showMoveHistoryModal(BuildContext context, List<MoveHistoryEntry> history) {
  showDialog(
    context: context,
    builder: (context) => MoveHistoryModal(history: history),
  );
}
