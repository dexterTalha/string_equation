import 'package:vector_math/vector_math.dart';
import 'condition_equation.dart';
import 'dart:math';

/// A utility class for mathematical operations and expression evaluation.
class MathUtils {
  /// The current character being processed in the formula.
  int ch = 0;

  /// The current position in the formula string.
  int pos = -1;

  /// The formula string being evaluated.
  late String formulae;

  /// The Unicode code unit for the addition operator.
  final int addCode = '+'.codeUnitAt(0);

  /// The Unicode code unit for the subtraction operator.
  final int subCode = '-'.codeUnitAt(0);

  /// The Unicode code unit for the letter 'a'.
  final int aCode = 'a'.codeUnitAt(0);

  /// The Unicode code unit for a space character.
  final int emptyCode = ' '.codeUnitAt(0);

  /// The Unicode code unit for the start parenthesis.
  final int startCode = '('.codeUnitAt(0);

  /// The Unicode code unit for the end parenthesis.
  final int endCode = ')'.codeUnitAt(0);

  /// The Unicode code unit for the dot character.
  final int dotCode = '.'.codeUnitAt(0);

  /// Indicates whether the formula is a date formula.
  /// COMING SOON: This feature is not yet implemented.
  bool isDateFormula = false;

  /// Replaces variables in the formula with their values from the answer map and evaluates the expression.
  ///
  /// \param formula The formula to be evaluated.
  /// \param ansObject A map containing variable values.
  /// \param parentId An optional parent ID for context.
  /// \return The result of the evaluated expression.
  double putValueAndSolveExpression(String formula, Map<String, dynamic>? ansObject, {String? parentId}) {
    formulae = formula;

    if (ansObject == null) {
      return eval(formulae);
    }

    try {
      var iter = formula.replaceAll("(", "").replaceAll(")", "").split(RegExp(r'[+\-*/^]'));

      for (var key in iter) {
        double? val = double.tryParse(key.toString());
        if (val != null) {
          continue;
        }
        String shortKey = key.trim().toString();
        if (parentId != null) {
          shortKey = "$parentId.$shortKey";
        }
        var value = (ansObject[shortKey]?.toString().isEmpty ?? true) ? '0' : ansObject[shortKey];
        formulae = formulae.replaceAll("\\b${key.trim()}\\b".toRegex, value.toString());
      }
    } catch (e) {
      return 0.0;
    }
    double result = eval(formulae);
    if (isDateFormula) {
      result = result / (1000 * 60 * 60 * 24);
      result = result < 0 ? 0 : result;
    }
    return result;
  }

  /// Evaluates the given mathematical expression.
  ///
  /// \param condition The expression to be evaluated.
  /// \return The result of the evaluated expression.
  double eval(String condition) {
    ch = 0;
    pos = -1;
    formulae = condition;
    return parse(condition);
  }

  /// Advances to the next character in the formula.
  ///
  /// \param formulae The formula being parsed.
  /// \return The Unicode code unit of the next character, or -1 if the end of the formula is reached.
  int nextChar({String? formulae}) {
    if (++pos < (formulae ?? this.formulae).length) {
      return (formulae ?? this.formulae)[pos].codeUnitAt(0);
    } else {
      return -1;
    }
  }

  /// Consumes the current character if it matches the specified character.
  ///
  /// \param charToEat The character to be consumed.
  /// \return True if the character was consumed, false otherwise.
  bool eat(int charToEat) {
    while (ch == emptyCode) {
      ch = nextChar();
    }
    if (ch == charToEat) {
      ch = nextChar();
      return true;
    }
    return false;
  }

  /// Parses the given formula and evaluates it.
  ///
  /// \param formulae The formula to be parsed.
  /// \return The result of the evaluated formula.
  double parse(String formulae) {
    ch = nextChar();
    var x = parseExpression();

    if (pos < formulae.length) throw Exception("Unexpected: $ch");
    return x;
  }

  /// Parses a factor in the expression.
  ///
  /// \return The result of the parsed factor.
  double parseFactor() {
    if (eat(addCode)) return parseFactor(); // unary plus
    if (eat(subCode)) return -parseFactor(); // unary minus
    double x = 0.0;
    var startPos = pos;
    if (eat(startCode)) {
      // parentheses
      x = parseExpression();
      eat(endCode);
    } else if (ch >= '0'.codeUnitAt(0) && ch <= '9'.codeUnitAt(0) || ch == dotCode) {
      // numbers
      while (ch >= '0'.codeUnitAt(0) && ch <= '9'.codeUnitAt(0) || ch == dotCode) {
        ch = nextChar();
      }
      x = double.parse(formulae.substring(startPos, pos));
    } else if (ch >= 'a'.codeUnitAt(0) && ch <= 'z'.codeUnitAt(0)) {
      // functions
      while (ch >= 'a'.codeUnitAt(0) && ch <= 'z'.codeUnitAt(0)) {
        ch = nextChar();
      }
      String func = formulae.substring(startPos, pos);
      x = parseFactor();
      if (func == "sqrt") {
        x = sqrt(x);
      } else if (func == "sin") {
        x = sin(radians(x));
      } else if (func == "cos") {
        x = cos(radians(x));
      } else if (func == "tan") {
        x = tan(radians(x));
      } else {
        throw Exception("Unknown function: $func");
      }
    } else {
      throw Exception("Unexpected: $ch");
    }
    if (eat('^'.codeUnitAt(0))) {
      x = pow(x, parseFactor()).toDouble(); // exponentiation
    }
    return x;
  }

  /// Parses a term in the expression.
  ///
  /// \return The result of the parsed term.
  double parseTerm() {
    var x = parseFactor();
    while (true) {
      if (eat('*'.codeUnitAt(0))) {
        x *= parseFactor();
      } else if (eat('/'.codeUnitAt(0))) {
        x /= parseFactor();
      } else {
        return x;
      }
    }
  }

  /// Parses an expression.
  ///
  /// \return The result of the parsed expression.
  double parseExpression() {
    var x = parseTerm();
    while (true) {
      if (eat(addCode)) {
        x += parseTerm();
      } else if (eat(subCode)) {
        x -= parseTerm();
      } else {
        return x;
      }
    }
  }
}
