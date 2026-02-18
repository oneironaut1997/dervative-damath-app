import 'package:flutter/material.dart';
import '../models/player_model.dart';

/// A card widget that displays player information including:
/// - Player name
/// - Color indicator
/// - Chips remaining count
/// - Captured pieces count
class PlayerInfoCard extends StatelessWidget {
  /// The player model containing all player data
  final PlayerModel player;

  /// Number of chips currently on the board for this player
  final int chipsRemaining;

  /// Number of pieces captured by this player
  final int capturedCount;

  /// Whether this player is currently active (it's their turn)
  final bool isActive;

  const PlayerInfoCard({
    super.key,
    required this.player,
    required this.chipsRemaining,
    required this.capturedCount,
    this.isActive = false,
  });

  Color get _playerColor {
    return player.color == PlayerColor.blue ? Colors.blue : Colors.red;
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? _playerColor.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? _playerColor : Colors.grey[300]!,
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? _playerColor.withValues(alpha: 0.2)
                : Colors.black12,
            blurRadius: isActive ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Name and Color indicator
          Row(
            children: [
              // Color indicator circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _playerColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: _playerColor.withValues(alpha: 0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Player name
              Expanded(
                child: Text(
                  player.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: isActive ? _playerColor : Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Active indicator
              if (isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _playerColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Turn',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            children: [
              // Chips remaining
              Expanded(
                child: _StatItem(
                  icon: Icons.circle,
                  iconColor: _playerColor,
                  label: 'Chips',
                  value: chipsRemaining.toString(),
                ),
              ),
              const SizedBox(width: 16),
              // Captured pieces
              Expanded(
                child: _StatItem(
                  icon: Icons.close,
                  iconColor: Colors.red,
                  label: 'Captured',
                  value: capturedCount.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Score display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  player.score.toString(),
                  style: TextStyle(
                    color: _playerColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
