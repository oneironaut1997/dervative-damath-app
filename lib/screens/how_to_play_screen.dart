import 'package:flutter/material.dart';

/// A screen that explains how to play Derivative Damath.
/// Contains game objective, movement rules, capture rules,
/// derivative computation rules, scoring system, and example scenarios.
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Play'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // Game Objective
              _SectionCard(
                title: '🎯 Game Objective',
                icon: Icons.flag,
                color: Colors.indigo,
                content: _ObjectiveContent(),
              ),
              SizedBox(height: 16),

              // Movement Rules
              _SectionCard(
                title: '🏃 Movement Rules',
                icon: Icons.directions_walk,
                color: Colors.blue,
                content: _MovementContent(),
              ),
              SizedBox(height: 16),

              // Capture Rules
              _SectionCard(
                title: '⚔️ Capture Rules',
                icon: Icons.gps_fixed,
                color: Colors.red,
                content: _CaptureContent(),
              ),
              SizedBox(height: 16),

              // Derivative Computation Rules
              _SectionCard(
                title: '∫ Derivative Computation',
                icon: Icons.calculate,
                color: Colors.purple,
                content: _DerivativeContent(),
              ),
              SizedBox(height: 16),

              // Scoring System
              _SectionCard(
                title: '🏆 Scoring System',
                icon: Icons.emoji_events,
                color: Colors.amber,
                content: _ScoringContent(),
              ),
              SizedBox(height: 16),

              // Example Scenarios
              _SectionCard(
                title: '📖 Example Scenarios',
                icon: Icons.lightbulb,
                color: Colors.green,
                content: _ExampleContent(),
              ),
              SizedBox(height: 24),

              // Back to Menu Button
              _BackButton(),
              SizedBox(height: 16),
            ],
          ),
        ),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
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
          style: TextStyle(color: Colors.grey[700], height: 1.5),
        ),
        const SizedBox(height: 12),
        _BulletPoint(
          text: 'Capture opponent\'s chips by landing on their tile',
        ),
        _BulletPoint(
          text: 'Compute derivatives of your polynomial chip',
        ),
        _BulletPoint(
          text: 'Compare your derivative result with the operation tile',
        ),
        _BulletPoint(
          text: 'Score points based on correct computation',
        ),
        _BulletPoint(
          text: 'Win by capturing all opponent chips or having the highest score',
        ),
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
        _SubHeader(text: 'Regular Chips (Pawn)'),
        const SizedBox(height: 8),
        Text(
          '• Move diagonally forward only (one step)\n• Can only move to empty tiles\n• Cannot move backward until promoted to Dama',
          style: TextStyle(color: Colors.grey[700], height: 1.6),
        ),
        const SizedBox(height: 16),
        _SubHeader(text: 'Dama (King) Chips'),
        const SizedBox(height: 8),
        Text(
          '• Can move diagonally in ANY direction (forward & backward)\n• Can move multiple tiles in a straight line\n• Promoted when reaching the opposite end of the board',
          style: TextStyle(color: Colors.grey[700], height: 1.6),
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
          style: TextStyle(color: Colors.grey[700], height: 1.5),
        ),
        const SizedBox(height: 12),
        _BulletPoint(
          text: 'Jump diagonally over the opponent\'s chip',
        ),
        _BulletPoint(
          text: 'Land on the empty tile directly behind the opponent',
        ),
        _BulletPoint(
          text: 'The captured chip is removed from the board',
        ),
        _BulletPoint(
          text: 'Chain captures are allowed (capture multiple in one turn)',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Example: Your chip at (2,2) can capture opponent at (3,3) by landing at (4,4)',
                  style: TextStyle(color: Colors.blue[700], fontSize: 13),
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
          style: TextStyle(color: Colors.grey[700], height: 1.5),
        ),
        const SizedBox(height: 12),
        _BulletPoint(
          text: 'Compute the derivative of your chip\'s polynomial',
        ),
        _BulletPoint(
          text: 'Apply the operation on the tile you landed on',
        ),
        _BulletPoint(
          text: 'If your derivative matches the operation result → Points!',
        ),
        const SizedBox(height: 12),
        _SubHeader(text: 'Basic Derivative Rules:'),
        const SizedBox(height: 8),
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
          style: TextStyle(color: Colors.grey[700], height: 1.5),
        ),
        const SizedBox(height: 12),
        _ScoreItem(points: '+1', description: 'Base points for any valid move'),
        _ScoreItem(points: '+2', description: 'Capturing an opponent\'s chip'),
        _ScoreItem(points: '+3', description: 'Moving a Dama (promoted chip)'),
        _ScoreItem(points: '+1', description: 'Each additional chain capture'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.star, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bonus: +5 points for a perfect derivative computation!',
                  style: TextStyle(
                    color: Colors.amber[700],
                    fontWeight: FontWeight.bold,
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
          title: 'Simple Move',
          description:
              'You have a chip with "2x³" and move to a tile with "+" operation. '
              'Your derivative is 6x². If you compute correctly, you earn +1 base point.',
          chip: '2x³',
          operation: '+',
          derivative: '6x²',
          points: '+1',
        ),
        const SizedBox(height: 16),
        _ExampleScenario(
          number: 2,
          title: 'Capture Move',
          description:
              'You jump over an opponent\'s chip "x²" and land on a "-" tile. '
              'You earn +2 for the capture plus derivative points!',
          chip: 'x²',
          operation: '-',
          derivative: '2x',
          points: '+2',
          isCapture: true,
        ),
        const SizedBox(height: 16),
        _ExampleScenario(
          number: 3,
          title: 'Chain Capture',
          description:
              'With a Dama chip, you can make multiple captures in one turn. '
              'Each additional capture adds +1 bonus point!',
          chip: '4x² (Dama)',
          operation: '+/−',
          derivative: '8x',
          points: '+3+',
          isDama: true,
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
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[700], height: 1.4),
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
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: Colors.black87,
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 8, top: 6),
            decoration: const BoxDecoration(
              color: Colors.purple,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                children: [
                  TextSpan(
                    text: formula,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              points,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.amber[800],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(color: Colors.grey[700]),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.green,
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  points,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 12),
          // Visual representation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ChipDisplay(chip: chip, isDama: isDama),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.grey),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  operation,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.orange[800],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.grey),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  derivative,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Colors.purple[800],
                  ),
                ),
              ),
              if (isCapture) ...[
                const SizedBox(width: 12),
                const Icon(Icons.gps_fixed, color: Colors.red, size: 20),
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
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDama ? Colors.amber : Colors.black,
          width: isDama ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
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
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isDama)
            const Icon(
              Icons.star,
              color: Colors.amber,
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back),
        label: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text('Back to Menu'),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
