# Phase 3 Implementation Notes: Game Mechanics

## Task ID: Phase 3 - Game Mechanics

## Implementation Date: 2026-02-18

## Overview
This document outlines the implementation plan for Phase 3: Game Mechanics, including Double Jump, Dama Promotion, Win/Lose Detection, and AI Opponent.

---

## Task 3.1: Double Jump Implementation

### Objective
Implement mandatory chain captures (double/triple jumps) after the first capture.

### Implementation Approach
1. **Add chain capture tracking**:
   - Add `mustContinueCapture` boolean flag to track if player must continue capturing
   - Add `currentChainChip` to track which chip is in the capture chain
   - Add `captureChainDepth` to track the number of captures in the current chain

2. **Capture detection logic**:
   - After executing a capture, check all possible capture directions
   - If opponent chip exists in capture range and landing spot is empty, another capture is available
   - Set `mustContinueCapture = true` and don't switch players

3. **Forced capture enforcement**:
   - Only allow selection of chips that can continue the capture chain
   - If `mustContinueCapture` is true, only the `currentChainChip` can be selected
   - Non-capture moves are blocked when chain is active

### Key Methods to Add/Modify
- `bool canCaptureFrom(int x, int y)` - Check if chip can capture from position
- `List<CaptureMove> getAvailableCaptures(int x, int y)` - Get all possible captures
- `void onTileTap(int x, int y)` - Modify to handle chain captures

---

## Task 3.2: Dama Promotion Implementation

### Objective
Implement Dama promotion when chips reach the opposite end of the board, granting enhanced movement capabilities.

### Implementation Approach
1. **Promotion detection**:
   - Player 1 (blue) promotes at row 0 (top)
   - Player 2 (red) promotes at row 7 (bottom)
   - Check after each move if chip reached promotion row

2. **Dama capabilities**:
   - Can move both forward and backward (+1 and -1 y directions)
   - Can slide multiple squares (not just 1) in any valid direction
   - Can capture in both forward and backward directions
   - Multi-square slide movement for captures

3. **Movement logic updates**:
   - Modify `getValidMoves()` to handle Dama capabilities
   - Check `chip.isDama` flag for movement direction allowance
   - Allow multi-square slides for Dama pieces

### Key Methods to Add/Modify
- `bool isPromotionRow(int y, int player)` - Check if row triggers promotion
- `List<Move> getValidMoves(ChipModel chip)` - Update to handle Dama movement
- `bool canMoveTo(int x, int y, ChipModel chip)` - Check if chip can move to position

---

## Task 3.3: Win/Lose Detection Implementation

### Objective
Implement comprehensive win/lose detection covering all game end scenarios.

### Implementation Approach
1. **Win condition 1 - Elimination**:
   - Check opponent's remaining chips count after each turn
   - If opponent has 0 chips, current player wins

2. **Win condition 2 - Blocked opponent**:
   - After each turn, check if opponent has any valid moves
   - Iterate through all opponent chips and check all directions
   - If no valid moves available, current player wins

3. **Draw condition**:
   - Track repeated positions (optional - 3 times)
   - Track move count for max moves draw

4. **Game state updates**:
   - Set `gameState.phase = GamePhase.won` or `GamePhase.draw`
   - Set `gameState.winner = currentPlayer`
   - Return game over status to UI

### Key Methods to Add/Modify
- `bool evaluateGameState()` - Comprehensive game state evaluation
- `bool hasValidMoves(int player)` - Check if player has any valid moves
- `bool isGameOver()` - Check if game has ended

---

## Task 3.4: AI Opponent Implementation

### Objective
Create AI opponent with three difficulty levels using Minimax algorithm with alpha-beta pruning.

### Implementation Approach

1. **AI Structure**:
   ```
   class AIOpponent {
     Difficulty difficulty; // easy, medium, hard
     minimaxMove(): Move - returns best move
     evaluatePosition(): int - scores current state
     getValidMoves(): List<Move> - all legal moves
   }
   ```

2. **Difficulty Levels**:
   - **Easy**: Random valid moves
   - **Medium**: Depth 2 lookahead with minimax
   - **Hard**: Depth 4 lookahead with alpha-beta pruning

3. **Evaluation Function**:
   - Piece count: +10 per chip, +20 per Dama
   - Position: chips closer to promotion row = higher score
   - Capture opportunity: +5 if can capture
   - Derivative potential: higher if can apply correct derivative

4. **Minimax Algorithm**:
   - Recursive evaluation of game states
   - Alpha-beta pruning for optimization
   - Max depth based on difficulty

### Key Classes/Files to Create
- `lib/utils/ai_opponent.dart` - Main AI implementation
- Helper methods in GameLogic for AI integration

---

## Integration Points

### GameLogic Integration
The Phase 3 features integrate with existing GameLogic class:
- Double jump modifies `onTileTap()` and adds new methods
- Dama promotion extends existing `_checkDamaPromotion()` logic
- Win/lose detection adds `evaluateGameState()` method

### Model Integration
- Uses existing `ChipModel.isDama` field
- Uses existing `GameStateModel` for game state
- Uses existing `GamePhase` enum

### ScoreCalculator Integration
- Uses existing ScoreCalculator for chain capture scoring
- Continues to track capture bonuses for double/triple jumps

---

## Testing Strategy

1. **Double Jump Tests**:
   - Test single capture ends turn
   - Test double jump executes correctly
   - Test triple jump executes correctly
   - Test forced capture rule enforced
   - Test non-capture moves blocked during chain

2. **Dama Promotion Tests**:
   - Test promotion at correct row
   - Test backward movement after promotion
   - Test multi-square slide movement
   - Test capture in both directions

3. **Win/Lose Detection Tests**:
   - Test win by elimination
   - Test win by blocking
   - Test draw by max moves
   - Test game over state correct

4. **AI Tests**:
   - Test easy difficulty makes legal moves
   - Test medium difficulty depth 2
   - Test hard difficulty depth 4
   - Test evaluation function returns reasonable scores

---

## Notes
- All features must integrate with existing Phase 1 and Phase 2 code
- Must follow existing code style and conventions
- Must maintain backward compatibility with existing game flow
- Dama promotion already has basic implementation in `_checkDamaPromotion()` - will extend
