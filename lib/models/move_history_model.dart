/// Represents a single move in the game's move history.
/// 
/// This model stores all information about a move including:
/// - The player who made the move
/// - The movement coordinates (from → to)
/// - Whether it was a capture
/// - The operation tile used (if any)
/// - The derivative calculation details
/// - Points earned from the move
class MoveHistoryEntry {
  /// Unique move number in the game (starts from 1)
  final int moveNumber;

  /// Player who made this move (1 = blue/Player 1, 2 = red/Player 2)
  final int player;

  /// Starting X coordinate
  final int fromX;

  /// Starting Y coordinate
  final int fromY;

  /// Target X coordinate
  final int toX;

  /// Target Y coordinate
  final int toY;

  /// Whether this was a capture move
  final bool isCapture;

  /// Terms of the captured chip (if capture), formatted as string
  final String? capturedChipTerms;

  /// The operation symbol on the target tile (+, −, ×, ÷)
  final String operation;

  /// Points earned from this move
  final double pointsEarned;

  /// Detailed calculation breakdown
  final String calculationDetails;

  /// Chip terms before the move (for display)
  final String chipTerms;

  /// Whether the chip was promoted to Dama after this move
  final bool isDamaPromotion;

  /// Number of chips captured in this move (chain captures)
  final int captureCount;

  const MoveHistoryEntry({
    required this.moveNumber,
    required this.player,
    required this.fromX,
    required this.fromY,
    required this.toX,
    required this.toY,
    this.isCapture = false,
    this.capturedChipTerms,
    this.operation = '',
    this.pointsEarned = 0,
    this.calculationDetails = '',
    this.chipTerms = '',
    this.isDamaPromotion = false,
    this.captureCount = 0,
  });

  /// Returns the player color name
  String get playerName => player == 1 ? 'Player 1' : (player == 2 ? 'Player 2' : 'Unknown');

  /// Returns formatted move string (e.g., "2,5 → 3,4")
  String get moveString => '($fromX,$fromY) → ($toX,$toY)';

  /// Returns formatted move notation (e.g., "e4e5")
  String get algebraicNotation {
    final files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    final fromFile = files[fromX];
    final toFile = files[toX];
    return '$fromFile${7 - fromY}$toFile${7 - toY}';
  }

  /// Returns a short description of the move type
  String get moveTypeDescription {
    if (isCapture) {
      if (captureCount > 1) {
        return 'Chain Capture ($captureCount pieces)';
      }
      return 'Capture';
    }
    if (isDamaPromotion) {
      return 'Move (Dama Promotion)';
    }
    return 'Move';
  }

  /// Returns formatted points string
  String get pointsString {
    if (pointsEarned == 0) return '';
    if (pointsEarned == pointsEarned.roundToDouble()) {
      return '+${pointsEarned.round()} pts';
    }
    return '+${pointsEarned.toStringAsFixed(1)} pts';
  }

  /// Creates a copy with optional parameter overrides
  MoveHistoryEntry copyWith({
    int? moveNumber,
    int? player,
    int? fromX,
    int? fromY,
    int? toX,
    int? toY,
    bool? isCapture,
    String? capturedChipTerms,
    String? operation,
    double? pointsEarned,
    String? calculationDetails,
    String? chipTerms,
    bool? isDamaPromotion,
    int? captureCount,
  }) {
    return MoveHistoryEntry(
      moveNumber: moveNumber ?? this.moveNumber,
      player: player ?? this.player,
      fromX: fromX ?? this.fromX,
      fromY: fromY ?? this.fromY,
      toX: toX ?? this.toX,
      toY: toY ?? this.toY,
      isCapture: isCapture ?? this.isCapture,
      capturedChipTerms: capturedChipTerms ?? this.capturedChipTerms,
      operation: operation ?? this.operation,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      calculationDetails: calculationDetails ?? this.calculationDetails,
      chipTerms: chipTerms ?? this.chipTerms,
      isDamaPromotion: isDamaPromotion ?? this.isDamaPromotion,
      captureCount: captureCount ?? this.captureCount,
    );
  }

  @override
  String toString() {
    return 'MoveHistoryEntry(#$moveNumber: $playerName $moveString, '
        'type=$moveTypeDescription, pts=$pointsString)';
  }
}
