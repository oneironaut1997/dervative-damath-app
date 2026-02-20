import 'package:derivative_damath/utils/derivative_rules.dart';
import 'package:derivative_damath/models/move_history_model.dart';

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

  /// The computed score for this move (per PDF spec)
  final double score;

  const MoveResult({
    required this.isValid,
    this.isCapture = false,
    this.isDamaPromotion = false,
    this.captureCount = 0,
    this.resultPolynomial,
    this.score = 0,
  });

  /// Creates a successful move result
  factory MoveResult.success({
    bool isCapture = false,
    bool isDamaPromotion = false,
    int captureCount = 0,
    Map<int, int>? resultPolynomial,
    double score = 0,
  }) {
    return MoveResult(
      isValid: true,
      isCapture: isCapture,
      isDamaPromotion: isDamaPromotion,
      captureCount: captureCount,
      resultPolynomial: resultPolynomial,
      score: score,
    );
  }

  /// Creates a failed move result (invalid derivative)
  factory MoveResult.failure() {
    return const MoveResult(isValid: false);
  }
}

/// Utility class for calculating scores in Derivative Damath.
///
/// Per PDF Specification (TUGADE-QUINTO-MANUEL):
/// Scoring Process:
/// 1. Combine taker chip with taken chip using operation (+, −, ×, ÷)
/// 2. Take derivative of the resulting combination
/// 3. Evaluate at x = |x_coord - y_coord| (where x can be 1, 3, 5, or 7)
/// 4. Apply Dama multipliers: 2x for one Dama, 4x for both Dama
///
/// End of Game:
/// - Add remaining chips' absolute coefficients to score
/// - Dama chips doubled
class ScoreCalculator {
  /// Calculates the score for a move using PDF specification.
  ///
  /// [movingChip] - The chip making the move
  /// [targetChip] - The target chip (for captures), can be null for regular moves
  /// [operationSymbol] - The operation at the landing position (+, −, ×, ÷)
  /// [targetX] - X coordinate of landing position
  /// [targetY] - Y coordinate of landing position
  /// [isCapture] - Whether this is a capture move
  /// [isDamaPromotion] - Whether chip was promoted to Dama
  ///
  /// Returns the calculated score per PDF spec
  static double calculateScorePDF({
    required Map<int, int> movingChipTerms,
    Map<int, int>? targetChipTerms,
    required String operationSymbol,
    required int targetX,
    required int targetY,
    bool isCapture = false,
    bool isDamaPromotion = false,
  }) {
    if (!isCapture || targetChipTerms == null) {
      // Non-capture moves don't earn score from PDF spec
      return 0;
    }

    // Step 1: Combine the taker chip with the taken chip using the operation
    final combined = _applyOperation(movingChipTerms, targetChipTerms, operationSymbol);
    if (combined.isEmpty) return 0;

    // Step 2: Take the derivative of the resulting combination
    final derivative = DerivativeRules.powerRule(combined);

    // Check if derivative has no x variable (constant)
    final hasXVariable = derivative.keys.any((exp) => exp > 0);

    // Step 3: Evaluate the derivative at x = |x - y| (possible values: 1, 3, 5, 7)
    final xValue = (targetX - targetY).abs();
    
    // If derivative has no x variable, skip evaluation
    double score;
    if (!hasXVariable) {
      // Derivative is a constant, use coefficient
      score = derivative[0]?.toDouble() ?? 0;
    } else {
      // Evaluate derivative at x = |x - y|
      score = DerivativeRules.evaluatePolynomial(derivative, xValue).toDouble();
    }

    // Step 4: Apply Dama multipliers
    // Note: We check both chips - in a capture, both could potentially be Dama
    // But per PDF, we check if the taker OR taken is Dama
    // Since we don't have the Dama status here, we'll handle that in game_logic

    return score;
  }

  /// Generates a detailed step-by-step breakdown of the derivative calculation.
  /// 
  /// This method provides educational explanations for each step of the
  /// derivative computation process, helping players understand how scoring works.
  ///
  /// [movingChipTerms] - The polynomial terms of the moving chip
  /// [targetChipTerms] - The polynomial terms of the captured chip (for captures)
  /// [operationSymbol] - The operation at the landing position (+, −, ×, ÷)
  /// [targetX] - X coordinate of landing position
  /// [targetY] - Y coordinate of landing position
  /// [isTakerDama] - Whether the moving chip is a Dama
  /// [isTakenDama] - Whether the captured chip is a Dama
  /// [captureCount] - Number of chips captured (for chain bonus)
  ///
  /// Returns a [CalculationBreakdown] with detailed explanations for each step
  static CalculationBreakdown? generateCalculationBreakdown({
    required Map<int, int> movingChipTerms,
    Map<int, int>? targetChipTerms,
    required String operationSymbol,
    required int targetX,
    required int targetY,
    bool isTakerDama = false,
    bool isTakenDama = false,
    int captureCount = 1,
  }) {
    // Only generate breakdown for captures
    if (targetChipTerms == null || targetChipTerms.isEmpty) {
      return null;
    }

    // Format the input terms
    final movingFormatted = _formatTerms(movingChipTerms);
    final targetFormatted = _formatTerms(targetChipTerms);

    // Step 1: Combine the chips using the operation
    final combined = _applyOperation(movingChipTerms, targetChipTerms, operationSymbol);
    if (combined.isEmpty) return null;
    final combinedFormatted = _formatTerms(combined);

    // Step 2: Take the derivative
    final derivative = DerivativeRules.powerRule(combined);
    final derivativeFormatted = _formatDerivative(derivative);
    final hasXVariable = derivative.keys.any((exp) => exp > 0);

    // Step 3: Evaluate at x = |x - y|
    final xValue = (targetX - targetY).abs();
    double resultBeforeMultiplier;

    if (!hasXVariable) {
      // Derivative is a constant
      resultBeforeMultiplier = derivative[0]?.toDouble() ?? 0;
    } else {
      // Evaluate at x = xValue
      final evaluatedValue = DerivativeRules.evaluatePolynomial(derivative, xValue);
      resultBeforeMultiplier = evaluatedValue.toDouble();
    }

    // Step 4: Apply Dama multipliers
    int dameMultiplier = 1;
    String dameDescription = '';
    if (isTakerDama && isTakenDama) {
      dameMultiplier = 4;
      dameDescription = 'Both chips are DAMA (4x multiplier)';
    } else if (isTakerDama || isTakenDama) {
      dameMultiplier = 2;
      dameDescription = 'One chip is DAMA (2x multiplier)';
    }

    // Apply multiplier
    final multipliedResult = resultBeforeMultiplier * dameMultiplier;

    // Step 5: Chain bonus
    final chainBonus = (captureCount > 1) ? (captureCount - 1) * 1 : 0;
    final finalScore = multipliedResult + chainBonus;

    // Build the detailed steps
    final steps = <CalculationStep>[];

    // Step 1: Combine chips
    final operationName = _getOperationName(operationSymbol);
    steps.add(CalculationStep(
      stepNumber: 1,
      title: 'Combine Chips',
      description: 'Apply $operationName operation to combine the polynomials',
      expression: '$movingFormatted $operationSymbol $targetFormatted = $combinedFormatted',
      result: combinedFormatted,
      iconName: 'combine',
    ));

    // Step 2: Take derivative
    steps.add(CalculationStep(
      stepNumber: 2,
      title: 'Take Derivative',
      description: 'Apply power rule: d/dx(xⁿ) = n×xⁿ⁻¹',
      expression: 'd/dx($combinedFormatted) = $derivativeFormatted',
      result: derivativeFormatted,
      iconName: 'derivative',
    ));

    // Step 3: Evaluate
    if (hasXVariable) {
      steps.add(CalculationStep(
        stepNumber: 3,
        title: 'Evaluate',
        description: 'Substitute x = |$targetX - $targetY| = $xValue into the derivative',
        expression: derivativeFormatted,
        result: resultBeforeMultiplier.toStringAsFixed(1),
        iconName: 'calculate',
      ));
    } else {
      steps.add(CalculationStep(
        stepNumber: 3,
        title: 'Constant Result',
        description: 'Derivative is constant (no x variable), use coefficient directly',
        expression: derivativeFormatted,
        result: resultBeforeMultiplier.toStringAsFixed(1),
        iconName: 'calculate',
      ));
    }

    // Step 4: Dama multiplier
    if (dameMultiplier > 1) {
      steps.add(CalculationStep(
        stepNumber: steps.length + 1,
        title: 'Apply Dama Multiplier',
        description: dameDescription,
        expression: '${resultBeforeMultiplier.toStringAsFixed(1)} × $dameMultiplier',
        result: multipliedResult.toStringAsFixed(1),
        iconName: 'star',
      ));
    }

    // Step 5: Chain bonus
    if (chainBonus > 0) {
      steps.add(CalculationStep(
        stepNumber: steps.length + 1,
        title: 'Chain Capture Bonus',
        description: '+$chainBonus point${chainBonus > 1 ? 's' : ''} for capturing $captureCount chips',
        expression: '${multipliedResult.toStringAsFixed(1)} + $chainBonus',
        result: finalScore.toStringAsFixed(1),
        iconName: 'bolt',
      ));
    }

    // Get operation symbol for display
    final opSymbol = _getOperationSymbol(operationSymbol);

    return CalculationBreakdown(
      movingChipTerms: movingFormatted,
      targetChipTerms: targetFormatted,
      operation: opSymbol,
      combinedTerms: combinedFormatted,
      derivativeFormula: derivativeFormatted,
      evaluationPoint: xValue,
      resultBeforeMultiplier: resultBeforeMultiplier,
      dameMultiplier: dameMultiplier,
      chainBonus: chainBonus,
      finalScore: finalScore,
      isConstantDerivative: !hasXVariable,
      steps: steps,
    );
  }

  /// Formats polynomial terms into a readable string.
  /// Example: {2: 1, 1: 3} → "x² + 3x"
  static String _formatTerms(Map<int, int> terms) {
    if (terms.isEmpty) return '0';

    // Sort by exponent in descending order
    final sortedKeys = terms.keys.toList()..sort((a, b) => b.compareTo(a));
    final parts = <String>[];

    for (int i = 0; i < sortedKeys.length; i++) {
      final exp = sortedKeys[i];
      final coeff = terms[exp]!;

      if (coeff == 0) continue;

      String termStr;
      if (exp == 0) {
        // Constant term
        termStr = coeff.abs().toString();
      } else if (exp == 1) {
        // Linear term
        if (coeff.abs() == 1) {
          termStr = 'x';
        } else {
          termStr = '${coeff.abs()}x';
        }
      } else {
        // Higher degree terms
        if (coeff.abs() == 1) {
          termStr = 'x${_toSuperscript(exp)}';
        } else {
          termStr = '${coeff.abs()}x${_toSuperscript(exp)}';
        }
      }

      // Add sign
      if (i == 0) {
        // First term - no sign for positive
        parts.add(coeff < 0 ? '−$termStr' : termStr);
      } else {
        // Subsequent terms
        parts.add(coeff < 0 ? '− $termStr' : '+ $termStr');
      }
    }

    if (parts.isEmpty) return '0';
    return parts.join(' ');
  }

  /// Formats derivative result for display.
  static String _formatDerivative(Map<int, int> derivative) {
    if (derivative.isEmpty) return '0';
    return _formatTerms(derivative);
  }

  /// Converts a number to superscript unicode characters.
  static String _toSuperscript(int number) {
    const superscripts = {
      0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴',
      5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹',
    };
    return number.toString().split('').map((c) => superscripts[int.parse(c)] ?? c).join('');
  }

  /// Gets the display name for an operation symbol.
  static String _getOperationName(String symbol) {
    switch (symbol) {
      case '+':
      case '−':
      case '-':
        return 'Addition/Subtraction';
      case '×':
      case 'x':
      case '*':
        return 'Multiplication';
      case '÷':
      case '/':
        return 'Division';
      default:
        return 'Unknown';
    }
  }

  /// Gets the standardized operation symbol for display.
  static String _getOperationSymbol(String symbol) {
    switch (symbol) {
      case '−':
      case '-':
        return '−';
      case '×':
      case 'x':
      case '*':
        return '×';
      case '÷':
      case '/':
        return '÷';
      default:
        return symbol;
    }
  }

  /// Applies a mathematical operation between two polynomials.
  static Map<int, int> _applyOperation(
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
      case '-':
        for (final entry in left.entries) {
          result[entry.key] = entry.value;
        }
        for (final entry in right.entries) {
          result[entry.key] = (result[entry.key] ?? 0) - entry.value;
        }
        break;

      case '×':
      case 'x':
      case '*':
        for (final entry1 in left.entries) {
          for (final entry2 in right.entries) {
            final newExp = entry1.key + entry2.key;
            final newCoeff = entry1.value * entry2.value;
            result[newExp] = (result[newExp] ?? 0) + newCoeff;
          }
        }
        break;

      case '÷':
      case '/':
        // Division: only keep left operand's terms (simplified)
        for (final entry in left.entries) {
          result[entry.key] = entry.value;
        }
        break;
    }

    result.removeWhere((key, value) => value == 0);
    return result;
  }

  /// Calculates the end-of-game score from remaining chips.
  /// Per PDF: Add absolute value of coefficients, Dama chips doubled.
  ///
  /// [chips] - List of remaining chips
  /// Returns the total score from remaining chips
  static double calculateRemainingChipsScore(List<Map<String, dynamic>> chips) {
    double total = 0;
    for (final chip in chips) {
      final terms = chip['terms'] as Map<int, int>;
      final isDama = chip['isDama'] as bool? ?? false;
      
      double chipValue = 0;
      for (final entry in terms.entries) {
        chipValue += entry.value.abs();
      }
      
      // Double if Dama
      if (isDama) {
        chipValue *= 2;
      }
      
      total += chipValue;
    }
    return total;
  }

  /// Base score for computing a correct derivative (legacy)
  static const int baseScore = 1;

  /// Bonus points for making a capture (legacy)
  static const int captureBonus = 2;

  /// Bonus points for promoting to Dama (legacy)
  static const int promotionBonus = 3;

  /// Bonus points per additional capture in a chain (legacy)
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
