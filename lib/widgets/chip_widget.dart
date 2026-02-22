import 'package:flutter/material.dart';
import '../models/chip_model.dart';

class ChipWidget extends StatelessWidget {
  final ChipModel chip;

  const ChipWidget({super.key, required this.chip});

  @override
  Widget build(BuildContext context) {
    // Determine the size of the chip dynamically based on screen size
    double chipSize = 60.0; // Fixed size for simplicity, you can adjust this
    
    // Visual indicators for Dama (promoted) chips
    final bool isDama = chip.isDama;
    final Color borderColor = isDama ? Colors.amber : Colors.black;
    final double borderWidth = isDama ? 3.0 : 2.0;
    
    // Determine if this is player 2's chip (for upside-down label)
    final bool isPlayer2 = chip.owner == 2;
    
    // Build the chip content (polynomial expression and optional crown)
    Widget chipContent = Stack(
      alignment: Alignment.center,
      children: [
        // The polynomial expression
        FittedBox(
          fit: BoxFit.scaleDown, // Ensures text is scaled to fit the available space
          child: RotatedBox(
            quarterTurns: isPlayer2 ? 2 : 0, // Rotate 180 degrees for player 2
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // Base font size
                ),
                children: _formatPolynomial(chip.terms),
              ),
            ),
          ),
        ),
        // Crown/Star icon for Dama chips (positioned at top-right)
        if (isDama)
          Positioned(
            top: 2,
            right: 2,
            child: Icon(
              Icons.star,
              color: Colors.amber,
              size: 14,
            ),
          ),
      ],
    );
    
    return Container(
      width: chipSize,
      height: chipSize,
      decoration: BoxDecoration(
        color: chip.owner == 1 ? Colors.blue : Colors.red,
        shape: BoxShape.circle, // Make the chip circular
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      alignment: Alignment.center,
      child: chipContent,
    );
  }

  List<TextSpan> _formatPolynomial(Map<int, int> terms) {
    final sortedKeys = terms.keys.toList()..sort((a, b) => b.compareTo(a));
    final spans = <TextSpan>[];

    for (final exp in sortedKeys) {
      final coeff = terms[exp]!;

      if (coeff == 0) continue; // Skip zero coefficients

      final sign = spans.isEmpty
          ? (coeff < 0 ? "-" : "")
          : (coeff < 0 ? " - " : " + ");

      final absCoeff = coeff.abs();
      String coeffStr = "";
    
      // Only display the coefficient if it’s not 1 or -1, unless the exponent is 0
      if (absCoeff != 1 || exp == 0) {
        coeffStr = absCoeff.toString();
      }

      String variableStr = "";
      if (exp > 0) {
        variableStr = "x";
        if (exp > 1) variableStr += _superscript(exp);
      }

      spans.add(TextSpan(
        text: "$sign$coeffStr$variableStr",
        style: TextStyle(
          fontSize: 14, // Adjust as needed
          fontWeight: FontWeight.bold,
        ),
      ));
    }

    return spans;
  }

  String _superscript(int number) {
    const superscriptMap = {
      '0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴', '5': '⁵',
      '6': '⁶', '7': '⁷', '8': '⁸', '9': '⁹',
    };
    return number.toString().split('').map((d) => superscriptMap[d]!).join();
  }
}
