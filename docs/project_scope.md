# Project Scope Statement

## Project Name
Derivative Damath

## Project Type
Educational Mathematics Mobile/Desktop Application

## Project Goal
Create a fully functional educational board game that teaches calculus derivatives through an engaging Damath-style gameplay experience.

---

## Scope: Inclusions

### Core Features
1. **Derivative Calculation Engine**
   - Power rule implementation
   - Sum/difference rule
   - Constant multiple rule
   - Chain rule for composite functions
   - Support for polynomials up to degree 4

2. **Game Board System**
   - 8x8 grid with arithmetic operations (+, −, ×, ÷)
   - Polynomial chip representation with superscript notation
   - Valid move highlighting

3. **Game Mechanics**
   - Standard checkers-like movement (diagonal forward)
   - Mandatory capture enforcement
   - Double/triple jump support
   - Dama (queen) promotion when reaching opposite end

4. **Scoring System**
   - Points based on derivative computation correctness
   - Bonus points for captures
   - Score tracking per player

5. **Game Modes**
   - Player vs Player (local)
   - Player vs Computer (AI)

6. **AI Opponent**
   - Basic AI with move evaluation
   - Difficulty levels (Easy, Medium, Hard)

7. **Game State Management**
   - Turn tracking
   - Win/lose/draw detection
   - Game history/undo functionality

### UI/UX Features
1. **Home Screen**
   - Game mode selection
   - How to play section

2. **Game Screen**
   - Interactive game board
   - Player info cards
   - Score display
   - Turn indicator

3. **How to Play Screen**
   - Game rules
   - Derivative calculation examples

---

## Scope: Exclusions

1. **Multiplayer Online** - Not in current scope
2. **User Accounts/Profiles** - Not in current scope
3. **Leaderboards** - Not in current scope
4. **Sound Effects** - Nice to have, not required
5. **Animations** - Basic only, not complex

---

## Non-Functional Requirements (NFRs)

| Requirement | Priority | Description |
|-------------|----------|--------------|
| Performance | High | Game moves should respond within 100ms |
| Platform Support | High | Android, iOS, Windows, Linux, Web |
| Maintainability | High | Clean architecture with separation of concerns |
| Testability | Medium | Unit tests for core game logic |
| Accessibility | Medium | Basic screen reader support |

---

## Success Criteria

1. ✅ All four arithmetic operations work correctly with derivative computation
2. ✅ Players can complete a full game from start to finish
3. ✅ AI opponent provides reasonable challenge
4. ✅ Score is accurately calculated and displayed
5. ✅ Game detects win/lose conditions correctly
