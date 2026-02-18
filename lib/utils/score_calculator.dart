/// Result of a move in the Derivative Damath game.
class MoveResult {
  /// Whether the move was successful (valid derivative)
  final bool isValid;

  /// Whether a capture was made
  final bool isCapture;

  /// Whether the chip was promoted to Dama
  final bool isDamaPromotion;

  /// Number of chips captured in this move (chain captures)
  final int captureCount;

  /// The polynomial result from the operation
  final Map<int, int>? resultPolynomial;

  const MoveResult({
    required this.isValid,
    this.isCapture = false,
    this.isDamaPromotion = false,
    this.captureCount = 0,
    this.resultPolynomial,
  });

  /// Creates a successful move result
  factory MoveResult.success({
    bool isCapture = false,
    bool isDamaPromotion = false,
    int captureCount = 0,
    Map<int, int>? resultPolynomial,
  }) {
    return MoveResult(
      isValid: true,
      isCapture: isCapture,
      isDamaPromotion: isDamaPromotion,
      captureCount: captureCount,
      resultPolynomial: resultPolynomial,
    );
  }

  /// Creates a failed move result (invalid derivative)
  factory MoveResult.failure() {
    return const MoveResult(isValid: false);
  }
}

/// Utility class for calculating scores in Derivative Damath.
///
/// Score Rules:
/// - Base score for correct derivative: 1 point
/// - Capture bonus: +2 points
/// - Dama promotion: +3 points
/// - Chain capture bonus: +1 per additional capture
/// - Wrong derivative: 0 points, turn doesn't end (player must retry)
class ScoreCalculator {
  /// Base score for computing a correct derivative
  static const int baseScore = 1;

  /// Bonus points for making a capture
  static const int captureBonus = 2;

  /// Bonus points for promoting to Dama
  static const int promotionBonus = 3;

  /// Bonus points per additional capture in a chain
  static const int chainCaptureBonus = 1;

  /// Calculates the score for a move.
  ///
  /// [moveResult] - The result of the move
  /// [capturesCount] - Number of chips captured (for chain bonus calculation)
  /// [isCorrectDerivative] - Whether the derivative was computed correctly
  /// [isDamaPromotion] - Whether the chip was promoted to Dama
  ///
  /// Returns the calculated score (0 if derivative was wrong)
  static int calculateScore({
    required MoveResult moveResult,
    int capturesCount = 0,
    required bool isCorrectDerivative,
    bool isDamaPromotion = false,
  }) {
    // Wrong derivative: 0 points, turn doesn't end
    if (!isCorrectDerivative) {
      return 0;
    }

    int score = baseScore;

    // Add capture bonus
    if (moveResult.isCapture) {
      score += captureBonus;

      // Add chain capture bonus for additional captures
      // capturesCount includes the first capture, so we add (capturesCount - 1) * chainBonus
      if (capturesCount > 1) {
        score += (capturesCount - 1) * chainCaptureBonus;
      }
    }

    // Add Dama promotion bonus
    if (isDamaPromotion) {
      score += promotionBonus;
    }

    return score;
  }

  /// Calculates the score with simplified parameters.
  ///
  /// This is a convenience method that takes all scoring factors directly.
  ///
  /// [isCorrectDerivative] - Whether the derivative was computed correctly
  /// [isCapture] - Whether a capture was made
  /// [captureCount] - Total number of captures in this move
  /// [isDamaPromotion] - Whether the chip was promoted to Dama
  ///
  /// Returns the calculated score
  static int calculate({
    required bool isCorrectDerivative,
    bool isCapture = false,
    int captureCount = 0,
    bool isDamaPromotion = false,
  }) {
    // Wrong derivative: 0 points
    if (!isCorrectDerivative) {
      return 0;
    }

    int score = baseScore;

    // Add capture bonus
    if (isCapture) {
      score += captureBonus;

      // Add chain capture bonus for additional captures
      if (captureCount > 1) {
        score += (captureCount - 1) * chainCaptureBonus;
      }
    }

    // Add Dama promotion bonus
    if (isDamaPromotion) {
      score += promotionBonus;
    }

    return score;
  }

  /// Returns a description of the score breakdown.
  ///
  /// Useful for displaying score details to the player.
  static ScoreBreakdown getScoreBreakdown({
    required bool isCorrectDerivative,
    bool isCapture = false,
    int captureCount = 0,
    bool isDamaPromotion = false,
  }) {
    if (!isCorrectDerivative) {
      return const ScoreBreakdown(
        totalScore: 0,
        basePoints: 0,
        capturePoints: 0,
        chainBonusPoints: 0,
        promotionPoints: 0,
        isCorrectDerivative: false,
      );
    }

    int basePoints = baseScore;
    int capturePoints = isCapture ? captureBonus : 0;
    int chainBonusPoints = (captureCount > 1) ? (captureCount - 1) * chainCaptureBonus : 0;
    int promotionPoints = isDamaPromotion ? promotionBonus : 0;

    int totalScore = basePoints + capturePoints + chainBonusPoints + promotionPoints;

    return ScoreBreakdown(
      totalScore: totalScore,
      basePoints: basePoints,
      capturePoints: capturePoints,
      chainBonusPoints: chainBonusPoints,
      promotionPoints: promotionPoints,
      isCorrectDerivative: true,
    );
  }
}

/// Breakdown of score components for display purposes.
class ScoreBreakdown {
  /// Total score for this move
  final int totalScore;

  /// Base points for correct derivative
  final int basePoints;

  /// Points from capture bonus
  final int capturePoints;

  /// Points from chain capture bonus
  final int chainBonusPoints;

  /// Points from Dama promotion
  final int promotionPoints;

  /// Whether the derivative was correct
  final bool isCorrectDerivative;

  const ScoreBreakdown({
    required this.totalScore,
    required this.basePoints,
    required this.capturePoints,
    required this.chainBonusPoints,
    required this.promotionPoints,
    required this.isCorrectDerivative,
  });

  /// Returns a human-readable description of the score.
  String get description {
    if (!isCorrectDerivative) {
      return 'Incorrect derivative - 0 points';
    }

    final parts = <String>[];
    parts.add('Base: +$basePoints');
    if (capturePoints > 0) parts.add('Capture: +$capturePoints');
    if (chainBonusPoints > 0) parts.add('Chain: +$chainBonusPoints');
    if (promotionPoints > 0) parts.add('Dama: +$promotionPoints');
    parts.add('Total: $totalScore');

    return parts.join(', ');
  }
}
