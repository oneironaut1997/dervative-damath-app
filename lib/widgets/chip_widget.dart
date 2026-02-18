import 'package:flutter/material.dart';
import '../models/chip_model.dart';

class ChipWidget extends StatelessWidget {
  final ChipModel chip;

  const ChipWidget({super.key, required this.chip});

  @override
  Widget build(BuildContext context) {
    // Determine the size of the chip dynamically based on screen size
    double chipSize = 60.0; // Fixed size for simplicity, you can adjust this
    
    return Container(
      width: chipSize,
      height: chipSize,
      decoration: BoxDecoration(
        color: chip.owner == 1 ? Colors.blue : Colors.red,
        shape: BoxShape.circle, // Make the chip circular
        border: Border.all(color: Colors.black, width: 2),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown, // Ensures text is scaled to fit the available space
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
