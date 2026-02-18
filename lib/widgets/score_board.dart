import 'package:flutter/material.dart';

/// A widget that displays the current scores for both players
/// with animated updates and turn indicator.
class ScoreBoard extends StatelessWidget {
  /// Player 1 (blue) score
  final int player1Score;

  /// Player 2 (red) score
  final int player2Score;

  /// Current player turn (1 = blue, 2 = red)
  final int currentPlayer;

  /// Player 1 name (optional, defaults to "Player 1")
  final String player1Name;

  /// Player 2 name (optional, defaults to "Player 2")
  final String player2Name;

  const ScoreBoard({
    super.key,
    required this.player1Score,
    required this.player2Score,
    required this.currentPlayer,
    this.player1Name = 'Player 1',
    this.player2Name = 'Player 2',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Player 1 Score
          _PlayerScore(
            name: player1Name,
            score: player1Score,
            color: Colors.blue,
            isActive: currentPlayer == 1,
          ),
          // Divider
          Container(
            width: 1,
            height: 35,
            color: Colors.grey[300],
          ),
          // VS Indicator
          const _VsIndicator(),
          // Divider
          Container(
            width: 1,
            height: 35,
            color: Colors.grey[300],
          ),
          // Player 2 Score
          _PlayerScore(
            name: player2Name,
            score: player2Score,
            color: Colors.red,
            isActive: currentPlayer == 2,
          ),
        ],
      ),
    );
  }
}

class _PlayerScore extends StatelessWidget {
  final String name;
  final int score;
  final Color color;
  final bool isActive;

  const _PlayerScore({
    required this.name,
    required this.score,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive
            ? Border.all(color: color, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? color : Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Text(
              score.toString(),
              key: ValueKey<int>(score),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          if (isActive)
            Text(
              'Turn',
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class _VsIndicator extends StatelessWidget {
  const _VsIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      child: const Text(
        'VS',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
