// home_screen.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/sound_service.dart';
import 'game_screen.dart';
import 'how_to_play_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          const _BackgroundLayer(),

          // Main card
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: _MainCard(
                    screenHeight: size.height,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the game start modal with timer options
void _showGameStartModal(BuildContext context, String mode) {
  SoundService().playClick();
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header icon
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D5BFF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  size: 36,
                  color: Color(0xFF1D5BFF),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Start Game',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0D2045),
                ),
              ),
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                mode == 'PvC' ? 'Player vs Computer' : 'Player vs Player',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B778C),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              
              // Question
              const Text(
                'Do you want to play with a timer?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF0D2045),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              
              // Timer info
              const Text(
                'Each player has 2 minutes per turn.\nTimeout deducts 10,000 points!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B778C),
                ),
              ),
              const SizedBox(height: 28),
              
              // With Timer Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    SoundService().playClick();
                    Navigator.of(dialogContext).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GameScreen(mode: mode, useTimer: true),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D5BFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'With Timer',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Without Timer Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    SoundService().playClick();
                    Navigator.of(dialogContext).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GameScreen(mode: mode, useTimer: false),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0D2045),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(
                      color: Color(0xFFD4E6FF),
                      width: 2,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer_off_outlined, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Without Timer',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Cancel Button
              TextButton(
                onPressed: () {
                  SoundService().playClick();
                  Navigator.of(dialogContext).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B778C),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _MainCard extends StatelessWidget {
  final double screenHeight;
  const _MainCard({required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.93),
        borderRadius: BorderRadius.circular(34),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F2E5AAC),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
          BoxShadow(
            color: Color(0x0F2E5AAC),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top illustration strip
          const _TopIllustration(),

          const SizedBox(height: 10),

          // Title
          const _TitleBlock(),

          const SizedBox(height: 18),

          // Buttons
          _MenuButton(
            height: 76,
            style: MenuButtonStyle.primaryBlue,
            leading: const _IconChip(
              bg: Color(0x1AFFFFFF),
              icon: Icons.sports_esports_rounded,
              iconColor: Colors.white,
            ),
            title: 'Player vs Computer',
            onTap: () => _showGameStartModal(context, 'PvC'),
          ),
          const SizedBox(height: 14),
          _MenuButton(
            height: 76,
            style: MenuButtonStyle.whiteBlue,
            leading: const _IconChip(
              bg: Color(0xFFE9F2FF),
              icon: Icons.group_rounded,
              iconColor: Color(0xFF1D5BFF),
            ),
            title: 'Player vs Player',
            onTap: () => _showGameStartModal(context, 'PvP'),
          ),
          const SizedBox(height: 14),
          _MenuButton(
            height: 76,
            style: MenuButtonStyle.whiteGreen,
            leading: const _IconChip(
              bg: Color(0xFFE8FFF1),
              icon: Icons.help_rounded,
              iconColor: Color(0xFF17A85E),
            ),
            title: 'How to Play',
            onTap: () {
              SoundService().playClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HowToPlayScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          const SizedBox(height: 18),

          // Quit
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              SoundService().playClick();
              exit(0);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.logout_rounded, color: Color(0xFFE94B4B)),
                  SizedBox(width: 10),
                  Text(
                    'Quit',
                    style: TextStyle(
                      color: Color(0xFFE94B4B),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 2),
        ],
      ),
    );
  }
}

/// Background layer using the home-screen-bg.png image.
class _BackgroundLayer extends StatelessWidget {
  const _BackgroundLayer();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/home-screen-bg.png'),
          fit: BoxFit.cover,
        ),
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
          imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
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

class _DotGrid extends StatelessWidget {
  final double opacity;
  const _DotGrid({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(
        size: const Size(90, 60),
        painter: _DotGridPainter(),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF7AA7FF);
    const dot = 2.2;
    const gapX = 12.0;
    const gapY = 12.0;

    for (double y = 0; y <= size.height; y += gapY) {
      for (double x = 0; x <= size.width; x += gapX) {
        canvas.drawCircle(Offset(x, y), dot, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopIllustration extends StatelessWidget {
  const _TopIllustration();

  @override
  Widget build(BuildContext context) {
    // Using the logo.png asset for the app icon.
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF6FBFF),
            Color(0xFFEFF6FF),
            Color(0xFFFDFDFF),
          ],
        ),
      ),
      child: Stack(
        children: [
          // faint curve decor
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: CustomPaint(
                painter: _WavePainter(),
              ),
            ),
          ),

          // Center app icon using logo.png
          const Align(
            alignment: Alignment.center,
            child: Image(
              image: AssetImage('assets/images/logo.png'),
              width: 150,
              height: 150,
            ),
          ),

          // small doodles (left/right)
          Positioned(
            left: 18,
            top: 16,
            child: Opacity(
              opacity: 0.85,
              child: _DoodleCard(
                text: 'f(x)',
                lineColor: const Color(0xFF1D5BFF),
              ),
            ),
          ),
          Positioned(
            right: 18,
            top: 16,
            child: Opacity(
              opacity: 0.85,
              child: _DoodleCard(
                text: '2x',
                lineColor: const Color(0xFFE45B5B),
              ),
            ),
          ),  
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFB9D3FF).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(-10, size.height * 0.65);
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.30,
      size.width * 0.45,
      size.height * 0.95,
      size.width * 1.05,
      size.height * 0.58,
    );

    canvas.drawPath(path, p);

    final p2 = Paint()
      ..color = const Color(0xFFB9D3FF).withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path2 = Path();
    path2.moveTo(-10, size.height * 0.35);
    path2.cubicTo(
      size.width * 0.35,
      size.height * 0.12,
      size.width * 0.65,
      size.height * 0.70,
      size.width * 1.05,
      size.height * 0.28,
    );
    canvas.drawPath(path2, p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DoodleCard extends StatelessWidget {
  final String text;
  final Color lineColor;

  const _DoodleCard({required this.text, required this.lineColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 54,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF4C6DB5),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            width: 28,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: lineColor.withOpacity(.25),
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: -0.6,
            ),
            children: [
              TextSpan(text: 'Derivative ', style: TextStyle(color: Color(0xFF0D2045))),
              TextSpan(text: 'Damath', style: TextStyle(color: Color(0xFF1D5BFF))),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Learn derivatives while you play!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF6B778C),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        // little underline accent (like the screenshot)
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 92,
            height: 5,
            margin: const EdgeInsets.only(right: 64),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC24A),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      ],
    );
  }
}

enum MenuButtonStyle { primaryBlue, whiteBlue, whiteGreen }

class _MenuButton extends StatelessWidget {
  final double height;
  final MenuButtonStyle style;
  final Widget leading;
  final String title;
  final VoidCallback onTap;

  const _MenuButton({
    required this.height,
    required this.style,
    required this.leading,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = style == MenuButtonStyle.primaryBlue;

    final bg = switch (style) {
      MenuButtonStyle.primaryBlue => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7BFF), Color(0xFF0D49E9)],
        ),
      MenuButtonStyle.whiteBlue => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF3F8FF)],
        ),
      MenuButtonStyle.whiteGreen => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF1FFF7)],
        ),
    };

    final borderColor = switch (style) {
      MenuButtonStyle.primaryBlue => Colors.transparent,
      MenuButtonStyle.whiteBlue => const Color(0xFFD4E6FF),
      MenuButtonStyle.whiteGreen => const Color(0xFFC6F0D7),
    };

    final textColor = isPrimary ? Colors.white : const Color(0xFF0D2045);

    final arrowBg = switch (style) {
      MenuButtonStyle.primaryBlue => const Color(0x1AFFFFFF),
      MenuButtonStyle.whiteBlue => const Color(0xFFEEF5FF),
      MenuButtonStyle.whiteGreen => const Color(0xFFE9FFF2),
    };

    final arrowColor = switch (style) {
      MenuButtonStyle.primaryBlue => Colors.white,
      MenuButtonStyle.whiteBlue => const Color(0xFF1D5BFF),
      MenuButtonStyle.whiteGreen => const Color(0xFF17A85E),
    };

    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          gradient: bg,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: (style == MenuButtonStyle.primaryBlue
                      ? const Color(0x332E7BFF)
                      : const Color(0x242E5AAC))
                  .withOpacity(0.20),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
            const BoxShadow(
              color: Color(0x0F2E5AAC),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: arrowBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chevron_right_rounded, color: arrowColor, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  final Color bg;
  final IconData icon;
  final Color iconColor;

  const _IconChip({
    required this.bg,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: iconColor, size: 26),
    );
  }
}

class _FeatureTabItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final bool active;

  const _FeatureTabItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.75),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x122E5AAC),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                )
              ],
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0D2045).withOpacity(active ? 1.0 : 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
