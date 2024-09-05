import 'package:vector_math/vector_math.dart';

import 'condition_equation.dart';
import 'dart:math';

class MathUtils {
  int ch = 0;
  int pos = -1;
  late String formulae;
  final int addCode = '+'.codeUnitAt(0);
  final int subCode = '-'.codeUnitAt(0);
  final int aCode = 'a'.codeUnitAt(0);
  final int emptyCode = ' '.codeUnitAt(0);
  final int startCode = '('.codeUnitAt(0);
  final int endCode = ')'.codeUnitAt(0);
  final int dotCode = '.'.codeUnitAt(0);
  bool isDateFormula = false;

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
        // try {
        //   value = RestrictionHelper.getDateInMilliSeconds(value);
        //   isDateFormula = true;
        // } catch (e) {
        //   isDateFormula = false;
        // }

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
    // return 0.0;
  }

  double eval(String condition) {
    ch = 0;
    pos = -1;
    formulae = condition;
    return parse(condition);
  }

  int nextChar({String? formulae}) {
    if (++pos < (formulae ?? this.formulae).length) {
      return (formulae ?? this.formulae)[pos].codeUnitAt(0);
    } else {
      return -1;
    }
  }

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

  double parse(String formulae) {
    ch = nextChar();
    var x = parseExpression();

    if (pos < formulae.length) throw Exception("Unexpected: $ch");
    return x;
  }

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
    if (eat('^'.codeUnitAt(0))) x = pow(x, parseFactor()).toDouble(); // exponentiation
    return x;
  }

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
