// how_to_play_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';

/// A screen that explains how to play Derivative Damath.
/// Contains game objective, movement rules, capture rules,
/// must capture rule, timer system, derivative computation rules,
/// scoring system, and example scenarios.
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background layer matching home screen style
          const _BackgroundLayer(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                _CustomAppBar(
                  title: 'How to Play',
                  onBack: () => Navigator.of(context).pop(),
                ),
                
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    child: Column(
                      children: const [
                        // Game Objective
                        _SectionCard(
                          title: '🎯 Game Objective',
                          icon: Icons.flag,
                          color: Color(0xFF1D5BFF),
                          content: _ObjectiveContent(),
                        ),
                        SizedBox(height: 14),

                        // Movement Rules
                        _SectionCard(
                          title: '🏃 Movement Rules',
                          icon: Icons.directions_walk,
                          color: Color(0xFF2E7BFF),
                          content: _MovementContent(),
                        ),
                        SizedBox(height: 14),

                        // Capture Rules
                        _SectionCard(
                          title: '⚔️ Capture Rules',
                          icon: Icons.gps_fixed,
                          color: Color(0xFFE94B4B),
                          content: _CaptureContent(),
                        ),
                        SizedBox(height: 14),

                        // Must Capture Rule
                        _SectionCard(
                          title: '🔒 Must Capture Rule',
                          icon: Icons.lock,
                          color: Color(0xFFFF6B35),
                          content: _MustCaptureContent(),
                        ),
                        SizedBox(height: 14),

                        // Timer System
                        _SectionCard(
                          title: '⏱️ Timer System',
                          icon: Icons.timer,
                          color: Color(0xFF00BFA5),
                          content: _TimerContent(),
                        ),
                        SizedBox(height: 14),

                        // Derivative Computation Rules
                        _SectionCard(
                          title: '∫ Derivative Computation',
                          icon: Icons.calculate,
                          color: Color(0xFF8B5CF6),
                          content: _DerivativeContent(),
                        ),
                        SizedBox(height: 14),

                        // Scoring System
                        _SectionCard(
                          title: '🏆 Scoring System',
                          icon: Icons.emoji_events,
                          color: Color(0xFFF6A000),
                          content: _ScoringContent(),
                        ),
                        SizedBox(height: 14),

                        // Example Scenarios
                        _SectionCard(
                          title: '📖 Example Scenarios',
                          icon: Icons.lightbulb,
                          color: Color(0xFF17A85E),
                          content: _ExampleContent(),
                        ),
                        SizedBox(height: 20),

                        // Back to Menu Button
                        _BackButton(),
                        SizedBox(height: 16),
                      ],
                    ),
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

class _BackgroundLayer extends StatelessWidget {
  const _BackgroundLayer();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF3F7FF),
            Color(0xFFEAF2FF),
            Color(0xFFEFEFFF),
            Color(0xFFEBE8FF),
          ],
          stops: [0.0, 0.45, 0.78, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Soft blobs
          const _Blob(
            alignment: Alignment.topRight,
            size: 300,
            colors: [Color(0x3300B2FF), Color(0x0000B2FF)],
            offset: Offset(100, -60),
          ),
          const _Blob(
            alignment: Alignment.bottomLeft,
            size: 350,
            colors: [Color(0x332C63FF), Color(0x002C63FF)],
            offset: Offset(-120, 100),
          ),
          const _Blob(
            alignment: Alignment.bottomRight,
            size: 320,
            colors: [Color(0x332A8CFF), Color(0x002A8CFF)],
            offset: Offset(140, 180),
          ),

          // Faint symbols
          Positioned(
            left: 18,
            top: 100,
            child: Opacity(
              opacity: 0.10,
              child: Text(
                'dy\ndx',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.blueGrey.shade700,
                  height: 1.0,
                ),
              ),
            ),
          ),
          Positioned(
            right: 26,
            top: 180,
            child: Opacity(
              opacity: 0.08,
              child: Text(
                '∫',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Alignment alignment;
  final double size;
  final List<Color> colors;
  final Offset offset;

  const _Blob({
    required this.alignment,
    required this.size,
    required this.colors,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: colors,
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _CustomAppBar({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          // Back button
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onBack,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x142E5AAC),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF1D5BFF),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0D2045),
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget content;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F2E5AAC),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x0F2E5AAC),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D2045),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Content
            content,
          ],
        ),
      ),
    );
  }
}

class _ObjectiveContent extends StatelessWidget {
  const _ObjectiveContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Derivative Damath combines the traditional Filipino board game "Damath" with calculus derivatives. The goal is to:',
          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14),
        ),
        const SizedBox(height: 12),
        const _BulletPoint(text: "Capture opponent's chips by landing on their tile"),
        const _BulletPoint(text: 'Compute derivatives of your polynomial chip'),
        const _BulletPoint(text: 'Apply the operation on the tile you land on'),
        const _BulletPoint(text: 'Score points based on correct computation'),
        const _BulletPoint(text: 'Win by capturing all opponent chips or having the highest score'),
      ],
    );
  }
}

class _MovementContent extends StatelessWidget {
  const _MovementContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SubHeader(text: 'Regular Chips (Pawn)'),
        const SizedBox(height: 8),
        Text(
          '• Move diagonally forward only (one step)\n• Can only move to empty tiles\n• Cannot move backward until promoted to Dama',
          style: TextStyle(color: Colors.grey[700], height: 1.6, fontSize: 14),
        ),
        const SizedBox(height: 16),
        const _SubHeader(text: 'Dama (King) Chips'),
        const SizedBox(height: 8),
        Text(
          '• Can move diagonally in ANY direction (forward & backward)\n• Can move multiple tiles in a straight line\n• Promoted when reaching the opposite end of the board',
          style: TextStyle(color: Colors.grey[700], height: 1.6, fontSize: 14),
        ),
      ],
    );
  }
}

class _CaptureContent extends StatelessWidget {
  const _CaptureContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'To capture an opponent\'s chip:',
          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14),
        ),
        const SizedBox(height: 12),
        const _BulletPoint(text: 'Jump diagonally over the opponent\'s chip'),
        const _BulletPoint(text: 'Land on the empty tile directly behind the opponent'),
        const _BulletPoint(text: 'The captured chip is removed from the board'),
        const _BulletPoint(text: 'Chain captures are allowed (capture multiple in one turn)'),
        const _BulletPoint(text: 'Regular chips can capture BOTH forward AND backward'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE9F2FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD4E6FF)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D5BFF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline, color: Color(0xFF1D5BFF), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Example: Your chip at (2,2) can capture opponent at (3,3) by landing at (4,4)',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MustCaptureContent extends StatelessWidget {
  const _MustCaptureContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The "Must Capture" rule is enforced in Derivative Damath:',
          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14),
        ),
        const SizedBox(height: 12),
        const _BulletPoint(text: 'If any of your chips can capture, you MUST capture'),
        const _BulletPoint(text: 'You cannot make regular moves when capture is available'),
        const _BulletPoint(text: 'Only chips that can capture are selectable'),
        const _BulletPoint(text: 'Chain captures must be completed if possible'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFE0B2)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock, color: Color(0xFFFF6B35), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Chips that can capture will glow green to indicate you must capture!',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimerContent extends StatelessWidget {
  const _TimerContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Each player has a limited time to make their move:',
          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14),
        ),
        const SizedBox(height: 12),
        const _BulletPoint(text: '2 minutes (120 seconds) per turn'),
        const _BulletPoint(text: 'Timer counts down during your turn'),
        const _BulletPoint(text: 'Timer resets when turn switches to opponent'),
        const SizedBox(height: 12),
        const _SubHeader(text: 'Timeout Penalty:'),
        const SizedBox(height: 8),
        Text(
          'If time runs out:\n• 10,000 points are deducted from your score\n• Turn automatically switches to opponent',
          style: TextStyle(color: Colors.grey[700], height: 1.6, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F7F6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFB2DFDB)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA5).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.timer, color: Color(0xFF00BFA5), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tip: Make your moves quickly to avoid timeout penalties!',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DerivativeContent extends StatelessWidget {
  const _DerivativeContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Each chip contains a polynomial. After moving:',
          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14),
        ),
        const SizedBox(height: 12),
        const _BulletPoint(text: 'Compute the derivative of your chip\'s polynomial'),
        const _BulletPoint(text: 'Apply the operation on the tile you landed on'),
        const _BulletPoint(text: 'If your derivative matches the operation result → Points!'),
        const SizedBox(height: 14),
        const _SubHeader(text: 'Basic Derivative Rules:'),
        const SizedBox(height: 10),
        _RuleExample(
          formula: 'd/dx(xⁿ) = n·xⁿ⁻¹',
          example: 'd/dx(x³) = 3x²',
        ),
        _RuleExample(
          formula: 'd/dx(c) = 0',
          example: 'd/dx(5) = 0',
        ),
        _RuleExample(
          formula: 'd/dx(cx) = c',
          example: 'd/dx(4x) = 4',
        ),
        const SizedBox(height: 14),
        const _SubHeader(text: 'Scoring Formula:'),
        const SizedBox(height: 8),
        Text(
          '1. Combine taker chip with taken chip using operation (+, −, ×, ÷)\n'
          '2. Take derivative of the resulting combination\n'
          '3. Evaluate at x = |x_coord - y_coord| (1, 3, 5, or 7)\n'
          '4. Apply Dama multipliers: 2x for one Dama, 4x for both',
          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 13),
        ),
      ],
    );
  }
}

class _ScoringContent extends StatelessWidget {
  const _ScoringContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Points are earned based on your move:',
          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14),
        ),
        const SizedBox(height: 12),
        const _ScoreItem(points: 'Variable', description: 'Based on operation + derivative evaluation'),
        const _ScoreItem(points: '2x', description: 'Dama multiplier (if taker is Dama)'),
        const _ScoreItem(points: '4x', description: 'Dama multiplier (if both chips are Dama)'),
        const _ScoreItem(points: '+1', description: 'Each additional chain capture bonus'),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFE4B3)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6A000).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.star, color: Color(0xFFF6A000), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'End Game: Remaining chips add their absolute coefficients to score (doubled if Dama)',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExampleContent extends StatelessWidget {
  const _ExampleContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ExampleScenario(
          number: 1,
          title: 'Simple Capture',
          description:
              'You capture opponent\'s "x²" chip and land on a "+" tile. '
              'Derivative is evaluated at x = |x-y| to calculate score.',
          chip: '2x³',
          operation: '+',
          derivative: '6x²+x²',
          points: 'Score',
          isCapture: true,
        ),
        const SizedBox(height: 14),
        _ExampleScenario(
          number: 2,
          title: 'Chain Capture',
          description:
              'With a capturing chip, you can make multiple captures in one turn. '
              'Each additional capture adds +1 bonus point!',
          chip: '4x²',
          operation: '+',
          derivative: '8x',
          points: '+1',
          isCapture: true,
          isDama: true,
        ),
        const SizedBox(height: 14),
        _ExampleScenario(
          number: 3,
          title: 'Must Capture',
          description:
              'When capture is available (glowing chip), you MUST capture. '
              'Regular moves are not allowed until all captures are made.',
          chip: 'x³',
          operation: '×',
          derivative: '3x²',
          points: '🔒',
          isCapture: true,
        ),
      ],
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7, right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1D5BFF),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[700], height: 1.4, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubHeader extends StatelessWidget {
  final String text;

  const _SubHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 15,
        color: Color(0xFF0D2045),
      ),
    );
  }
}

class _RuleExample extends StatelessWidget {
  final String formula;
  final String example;

  const _RuleExample({required this.formula, required this.example});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.functions, color: Color(0xFF8B5CF6), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                children: [
                  TextSpan(
                    text: formula,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                      color: Color(0xFF0D2045),
                    ),
                  ),
                  const TextSpan(text: '  →  '),
                  TextSpan(text: example),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final String points;
  final String description;

  const _ScoreItem({required this.points, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF6A000), Color(0xFFE69500)],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF6A000).withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              points,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              description,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleScenario extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final String chip;
  final String operation;
  final String derivative;
  final String points;
  final bool isCapture;
  final bool isDama;

  const _ExampleScenario({
    required this.number,
    required this.title,
    required this.description,
    required this.chip,
    required this.operation,
    required this.derivative,
    required this.points,
    this.isCapture = false,
    this.isDama = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF17A85E), Color(0xFF148F4D)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF0D2045),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF17A85E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  points,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF17A85E),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 14),
          // Visual representation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ChipDisplay(chip: chip, isDama: isDama),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_rounded, color: Color(0xFF6B778C), size: 20),
              const SizedBox(width: 10),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFC24A), Color(0xFFFF8C2A)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  operation,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_rounded, color: Color(0xFF6B778C), size: 20),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  derivative,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                    color: Color(0xFF8B5CF6),
                    fontSize: 13,
                  ),
                ),
              ),
              if (isCapture) ...[
                const SizedBox(width: 12),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE94B4B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.gps_fixed, color: Color(0xFFE94B4B), size: 18),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipDisplay extends StatelessWidget {
  final String chip;
  final bool isDama;

  const _ChipDisplay({required this.chip, this.isDama = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7BFF), Color(0xFF0D49E9)],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDama ? const Color(0xFFFFC24A) : Colors.white,
          width: isDama ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7BFF).withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            chip,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (isDama)
            const Icon(
              Icons.star,
              color: Color(0xFFFFC24A),
              size: 10,
            ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E7BFF), Color(0xFF0D49E9)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7BFF).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              'Back to Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
