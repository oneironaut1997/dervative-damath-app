# Phase 2: Core Logic (Derivative Engine) - Implementation Notes

## Overview
This document details the implementation of Phase 2: Core Logic for the Derivative Damath game. Phase 2 implements the derivative calculation engine, scoring system, and integration with the game logic.

---

## Task 2.1: Derivative Rules Implementation

### File: `lib/utils/derivative_rules.dart`

### Implementation Details

The derivative rules module implements mathematical differentiation for polynomials represented as `Map<int, int>` where:
- **key**: exponent (power of x)
- **value**: coefficient

Example: `3x² + 2x + 1` is represented as `{2: 3, 1: 2, 0: 1}`

### Rules Implemented

1. **Power Rule**: `d/dx(axⁿ) = anxⁿ⁻¹`
   - Example: `{2: 3}` (3x²) → `{1: 6}` (6x¹)
   - Constants (exponent 0) become 0
   - Linear terms (exponent 1) become constants

2. **Sum Rule**: `d/dx(f + g) = f' + g'`
   - Combines derivatives of each term in a polynomial

3. **Difference Rule**: `d/dx(f - g) = f' - g'`
   - Handles subtraction of polynomial terms

4. **Constant Multiple Rule**: `d/dx(cf) = c × f'`
   - Multiplies derivative by constant factor

5. **Chain Rule for Operations**:
   - Addition: derivative of sum is sum of derivatives
   - Subtraction: derivative of difference
   - Multiplication: product rule `(f×g)' = f'×g + f×g'`
   - Division: simplified quotient handling

### Key Methods

```dart
// Main entry point for derivative computation
static Map<int, int> computeDerivative(
  Map<int, int> polynomial, {
  OperationType? operation,
  Map<int, int>? operand,
})

// Power rule implementation
static Map<int, int> powerRule(Map<int, int> polynomial)

// Validation helper
static bool validateDerivative(
  Map<int, int> polynomial,
  Map<int, int> expectedDerivative,
)
```

### Edge Cases Handled
- Zero exponent (constants → 0)
- Exponent of 1 (x → constant)
- Negative coefficients
- Empty polynomials
- Zero coefficients (skipped)

---

## Task 2.2: Score System Implementation

### File: `lib/utils/score_calculator.dart`

### Score Rules

| Action | Points |
|--------|--------|
| Correct derivative (base) | +1 |
| Capture bonus | +2 |
| Dama promotion | +3 |
| Chain capture bonus | +1 per additional |
| Wrong derivative | 0 (turn doesn't end) |

### Classes Implemented

#### MoveResult
Encapsulates the result of a game move:
- `isValid`: Whether the move was successful
- `isCapture`: Whether a capture was made
- `isDamaPromotion`: Whether chip was promoted to Dama
- `captureCount`: Number of captures in chain
- `resultPolynomial`: Resulting polynomial after operation

#### ScoreCalculator
Static utility class for score calculation:

```dart
// Method 1: Using MoveResult
static int calculateScore({
  required MoveResult moveResult,
  int capturesCount = 0,
  required bool isCorrectDerivative,
  bool isDamaPromotion = false,
})

// Method 2: Simplified parameters
static int calculate({
  required bool isCorrectDerivative,
  bool isCapture = false,
  int captureCount = 0,
  bool isDamaPromotion = false,
})

// Method 3: Detailed breakdown
static ScoreBreakdown getScoreBreakdown({...})
```

#### ScoreBreakdown
Detailed score component breakdown for display:
- `totalScore`: Total points earned
- `basePoints`: Base derivative points
- `capturePoints`: Capture bonus
- `chainBonusPoints`: Chain capture bonus
- `promotionPoints`: Dama promotion bonus

### Score Examples

| Scenario | Calculation | Total |
|----------|-------------|-------|
| Correct derivative only | 1 | 1 |
| Correct + capture | 1 + 2 | 3 |
| Correct + capture + chain | 1 + 2 + 1 | 4 |
| Correct + Dama promotion | 1 + 3 | 4 |
| All bonuses | 1 + 2 + 2 + 3 | 8 |
| Wrong derivative | 0 | 0 |

---

## Task 2.3: Derivative Integration with Game Logic

### File: `lib/utils/game_logic.dart`

### Integration Flow

When a chip lands on an operation tile:

```
1. Check if tile has operation (+, −, ×, ÷)
       ↓
2. Get opponent's chip on same tile (if any)
       ↓
3. Compute derivative of moving chip's polynomial
       ↓
4. Compare with operation result from opponent's chip
       ↓
5. If correct:
   - Update score
   - Transform chip (apply operation)
   - Check for Dama promotion
   - Switch turn
   ↓
6. If incorrect:
   - Return failure result
   - Show error message
   - Player must retry
```

### New Methods Added

```dart
// Get operation at board position
String? getOperationAt(int x, int y)

// Check if tile is operation tile
bool isOperationTile(int x, int y)

// Compute derivative of chip
Map<int, int> computeDerivative(ChipModel chip)

// Validate derivative move
bool validateDerivativeMove(ChipModel movingChip, int targetX, int targetY)

// Process operation move with validation
MoveResult processOperationMove(int x, int y)

// Apply mathematical operation between polynomials
Map<int, int> _applyOperation(
  Map<int, int> left,
  Map<int, int> right,
  String operation,
)
```

### Operation Handling

| Operation | Symbol | Derivative Application |
|-----------|--------|------------------------|
| Addition | + | Sum of derivatives |
| Subtraction | − | Difference of derivatives |
| Multiplication | × | Product rule |
| Division | ÷ | Simplified handling |

### Score Tracking

- Added `player1Score` and `player2Score` fields
- Added `lastMoveResult` for feedback
- Added `lastErrorMessage` for error display
- Added `getScore(int playerNumber)` method
- Added `reset()` method for game restart

### Dama Promotion Logic

- Player 1 (blue) promotes at row 0 (top)
- Player 2 (red) promotes at row 7 (bottom)
- Automatic promotion after valid move to promotion row

---

## Dependencies

### Internal Dependencies
- `lib/models/chip_model.dart` - Chip representation
- `lib/models/operation_model.dart` - Operation types
- `lib/utils/derivative_rules.dart` - Derivative calculations
- `lib/utils/score_calculator.dart` - Score system
- `lib/utils/operations_layout.dart` - Operation tile positions

### External Dependencies
- `package:logging/logging.dart` - Logging functionality

---

## Testing Considerations

### Derivative Rules Tests
- Power rule: `{2: 3}` → `{1: 6}`
- Sum rule: `{2: 3, 1: 2}` → `{1: 6, 0: 2}`
- Constant: `{0: 5}` → `{}`
- Negative coefficients: `{-1: 3}` → `{0: -3}`

### Score Calculator Tests
- Base score: 1 point
- Capture: +2 points
- Chain capture: +1 per additional
- Dama: +3 points
- Wrong derivative: 0 points

### Game Logic Integration Tests
- Operation tile detection
- Derivative validation
- Score updates
- Chip transformation
- Dama promotion

---

## Files Modified/Created

| File | Action | Description |
|------|--------|-------------|
| `lib/utils/derivative_rules.dart` | Created | Derivative calculation engine |
| `lib/utils/score_calculator.dart` | Created | Score calculation system |
| `lib/utils/game_logic.dart` | Expanded | Derivative integration |

---

## Next Steps (Phase 3)

1. **Double Jump Implementation**: After capture, check for additional captures
2. **Dama Movement**: Allow backward and multi-square movement
3. **Win/Lose Detection**: Check for no chips or no valid moves
4. **AI Opponent**: Minimax algorithm with alpha-beta pruning

---

## Status: ✅ COMPLETE

Phase 2 Core Logic (Derivative Engine) implementation is complete and ready for Phase 3: Game Mechanics.
