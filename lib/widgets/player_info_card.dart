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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? _playerColor.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? _playerColor : Colors.grey[300]!,
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? _playerColor.withValues(alpha: 0.2)
                : Colors.black12,
            blurRadius: isActive ? 8 : 4,
            offset: const Offset(0, 2),
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
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _playerColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: _playerColor.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 6),
              // Player name
              Expanded(
                child: Text(
                  player.name,
                  style: TextStyle(
                    fontSize: 12,
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
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: _playerColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Turn',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
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
              const SizedBox(width: 4),
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
          const SizedBox(height: 4),
          // Score display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  player.score.toString(),
                  style: TextStyle(
                    color: _playerColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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
          size: 12,
        ),
        const SizedBox(width: 2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
