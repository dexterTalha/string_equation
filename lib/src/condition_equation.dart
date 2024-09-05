import 'dart:math';

import 'math_utils.dart';

class ConditionEquation {
  static const String GREATER_THAN = ">";
  static const String GREATER_THAN_EQUAL_TO = ">=";
  static const String LESS_THAN = "<";
  static const String LESS_THAN_EQUAL_TO = "<=";
  static const String EQUAL_TO = "==";
  static const String NOT_EQUAL_TO = "!=";
  static const String ORIGINAL_NOT = "!";
  static const String REVERSE_NOT = "n";
  static const String START = '(';
  static const String DOUBLE_START = "((";
  static const String DOUBLE_END = "))";
  static const String END = ')';
  static const String AND = 'A';
  static const String NOT = '!';
  static const String ORIGINAL_SINGLE_AND = "&";
  static const String ORIGINAL_AND = "&&";
  static const String OR = 'O';
  static const String ORIGINAL_SINGLE_OR = "|";
  static const String ORIGINAL_OR = "||";

  final Map<String, dynamic>? answerMap;
  final String? parentId;

  ConditionEquation({this.answerMap, this.parentId});

  bool isHavingNot = false;
  bool isGlobalHavingNot = false;

  DateEquationResult? splitDateEquation(String pattern) {
    if (!pattern.startsWith('(') || !pattern.endsWith(')')) {
      throw Exception("Invalid exp");
    } else {
      final newPattern = pattern.trim().substring(1, pattern.length - 1);
      final split = newPattern.split(",");
      if (split.length == 3 && split[0].isNotEmpty && split[1].isNotEmpty && split[2].isNotEmpty) {
        return DateEquationResult(split[0], split[1], split[2]);
      } else {
        throw Exception("Invalid exp");
      }
    }
  }

  Map splitEquation(String equations) {
    var equationList = <String>[];
    var initialIndex = 0;
    var startCounter = 0;
    var endCounter = 0;
    var map = {};
    for (int i = 0; i < equations.length; i++) {
      String char = equations[i];
      //1
      if (char == START) {
        startCounter++;
      } else if (char == END) {
        endCounter++;
      }
      if (startCounter == endCounter) {
        if (char == AND) {
          map[i] = AND;
        } else if (char == OR) {
          map[i] = OR;
        } else {
          //intial 2, i= 1+1 = 2
          //eq = "1
          equationList.add(equations.substring(initialIndex, i + 1));

          startCounter = 0;
          endCounter = 0;
          initialIndex = initialIndex + 2;
        }
      }
    }
    return {'map': map, 'equations': equationList};
  }

  dynamic evaluateExpression(String expression) {
    var logicalOperators = [GREATER_THAN, EQUAL_TO, LESS_THAN, NOT, ORIGINAL_SINGLE_OR, ORIGINAL_SINGLE_AND];
    if (!logicalOperators.any((e) => expression.contains(e))) {
      return MathUtils().putValueAndSolveExpression(expression, answerMap, parentId: parentId);
    }
    Map exp = {};
    int specialCounter = 0;
    String replacement = "";
    Random random = Random();
    String newExpression = expression;
    String subChar = "@";
    for (String st in expression.split("")) {
      if (specialCounter > 1) {
        String key = "${random.nextIntOfDigits(5)}";

        exp.addAll({key: replacement.replaceAll("@", "")});
        newExpression = newExpression.replaceAll(replacement, "$key@");

        specialCounter = 0;
        replacement = "";
      }

      if (specialCounter == 1) {
        replacement += st;
      }
      if (st == subChar) {
        specialCounter++;
        continue;
      }
    }
    String eq = newExpression.removeSurrounding(START.toString(), END.toString());
    isGlobalHavingNot = eq.startsWith(NOT) && eq.startsWith(DOUBLE_START, 1) && eq.endsWith(DOUBLE_END);
    if (isGlobalHavingNot) {
      newExpression = eq.replaceAll(NOT, "");
    }
    bool result = solveExpression(newExpression, map: exp);
    return isGlobalHavingNot ? !result : result;
  }

  bool solveExpression(String expression, {Map map = const {}}) {
    String equations = expression;
    equations = expression
        .trim()
        .replaceAll(ORIGINAL_AND, AND.toString())
        .replaceAll(ORIGINAL_OR, OR.toString())
        .replaceAll(ORIGINAL_SINGLE_AND, AND.toString())
        .replaceAll(ORIGINAL_SINGLE_OR, OR.toString())
        .replaceAll(" ", "");

    if (!equations.isValidEquation) {
      throw Exception("Invalid exp");
    }

    if (splitEquation(equations)['equations'].length == 1 && equations.startsWith(DOUBLE_START) && equations.endsWith(DOUBLE_END)) {
      equations = equations.trim().removeSurrounding(START.toString(), END.toString());
    }

    if (equations.contains(AND) || equations.contains(OR)) {
      Map splitEq = splitEquation(equations);
      var hashMap = splitEq['map'];

      // print("EQ2 $eq2");
      for (var mutableEntryKey in hashMap.keys) {
        var operatorIndex = mutableEntryKey;
        var eq1Index = 0; // equations.startsWith(NOT) ? 0 : 1;
        var eq2Index = operatorIndex + 1; //(equations.startsWith(NOT) ? 1 : 2);
        // print("EXPRESSION", equations);
        var eq1 = equations.substring(eq1Index, operatorIndex).toString();
        var eq2 = equations.substring(eq2Index, equations.length).toString();

        if (eq1.isValidEquation && eq2.isValidEquation) {
          if (hashMap[mutableEntryKey] == OR) {
            return solveExpression(eq1, map: map) || solveExpression(eq2, map: map);
          } else if (hashMap[mutableEntryKey] == AND) {
            return solveExpression(eq1, map: map) && solveExpression(eq2, map: map);
          }
          break;
        }
      }
    } else {
      return checkExpression(equations, map: map);
    }
    // print(expression);
    throw Exception("Invalid Condition Solve Expression $equations");
  }

  bool checkExpression(String conditions, {Map map = const {}}) {
    // print(conditions);
    String newCondition = conditions;

    if (newCondition.startsWith(START) && newCondition.endsWith(END)) {
      newCondition = conditions.trim().removeSurrounding(START.toString(), END.toString());
      return checkExpression(newCondition, map: map);
    }
    isHavingNot = newCondition.startsWith(NOT);
    if (isHavingNot) {
      newCondition = newCondition.substring(1, conditions.length);
      newCondition = newCondition.trim().removeSurrounding(START.toString(), END.toString());
    }

    if (newCondition.contains(GREATER_THAN_EQUAL_TO)) {
      List<dynamic> split = newCondition.split(GREATER_THAN_EQUAL_TO);
      try {
        split = GREATER_THAN_EQUAL_TO.getValues(newCondition, answerMap, parentId: parentId) ?? [];
      } catch (e) {
        List<dynamic> s = [];
        dynamic val = [];
        String v;
        if (answerMap != null && split.isNotEmpty) {
          val = answerMap![split[0]] ?? "0";
          v = split[1] ?? "-1";
        } else {
          val = "0";
          v = "-1";
        }

        s.add(double.tryParse(val) ?? val);
        s.add(double.tryParse(v) ?? v);

        split = s;
      }
      // return ;
      return isHavingNot ? !(split[0]! >= split[1]!) : split[0]! >= split[1]!;
    } else if (newCondition.contains(LESS_THAN_EQUAL_TO)) {
      List<dynamic> split = newCondition.split(LESS_THAN_EQUAL_TO);
      try {
        split = LESS_THAN_EQUAL_TO.getValues(newCondition, answerMap, parentId: parentId) ?? [];
      } catch (e) {
        List<dynamic> s = [];
        dynamic val = [];
        String v;
        if (answerMap != null && split.isNotEmpty) {
          val = answerMap![split[0]] ?? "0";
          v = split[1] ?? "-1";
        } else {
          val = "0";
          v = "-1";
        }

        s.add(double.tryParse(val) ?? val);
        s.add(double.tryParse(v) ?? v);

        split = s;
      }
      // return split[0]! <= split[1]!;
      return isHavingNot ? !(split[0]! <= split[1]!) : split[0]! <= split[1]!;
    } else if (newCondition.contains(NOT_EQUAL_TO)) {
      var split = NOT_EQUAL_TO.getValues(newCondition, answerMap, parentId: parentId);
      if (split != null) {
        // return split[0] != split[1];
        return isHavingNot ? !(split[0] != split[1]) : split[0] != split[1];
      } else {
        throw Exception("Invalid value $newCondition");
      }
    } else if (newCondition.contains(NOT)) {
      var split = NOT.getValues(newCondition, answerMap, parentId: parentId);
      if (split != null) {
        // return !(split[0] == split[1]);
        return isHavingNot ? !(!(split[0] == split[1])) : !(split[0] == split[1]);
      } else {
        throw Exception("Invalid value $newCondition");
      }
    } else if (newCondition.contains(GREATER_THAN)) {
      var split = GREATER_THAN.getValues(newCondition, answerMap, parentId: parentId);

      if (split != null) {
        // return split[0]! > split[1]!;
        return isHavingNot ? !(split[0]! > split[1]!) : split[0]! > split[1]!;
      } else {
        throw Exception("Invalid value $newCondition");
      }
    } else if (newCondition.contains(LESS_THAN)) {
      var split = LESS_THAN.getValues(newCondition, answerMap, parentId: parentId);
      if (split != null) {
        return isHavingNot ? !(split[0]! < split[1]!) : split[0]! < split[1]!;
      } else {
        throw Exception("Invalid value $newCondition");
      }
    } else if (newCondition.contains(EQUAL_TO)) {
      if (newCondition.contains("@")) {
        List<String> split = newCondition.split(EQUAL_TO);
        if (split.isEmpty) {
          throw Exception("Invalid Condition checkExpression $newCondition");
        }
        if (split[1].toString().startsWith("@")) {
          String exp = split[1].toString().substring(1, split[1].length - 1);

          RegExp regExp = RegExp(map[exp]);
          // double d = ;
          String matchValue = "";
          if (answerMap == null) {
            matchValue = split[0];
          } else {
            bool isList = answerMap![split[0]] == null ? false : answerMap![split[0]] is List;
            if (!isList) {
              String? val = answerMap?[split[0]];
              if (val == null) return false;
              matchValue = val;
            } else {
              List<dynamic> val = answerMap?[split[0]];
              if (val.isEmpty) return false;
              return val.any((element) => regExp.hasMatch(element?.toString() ?? ""));
            }
          }
          return regExp.hasMatch(matchValue);
        } else {
          throw Exception("Invalid Condition checkExpression $newCondition");
        }
      }

      List<dynamic> split = newCondition.split(EQUAL_TO);
      try {
        double.parse(split[0]);
        split = EQUAL_TO.getValues(newCondition, answerMap, parentId: parentId) ?? [];
      } catch (e) {
        List<dynamic> s = [];
        dynamic val = [];
        String v;
        if (answerMap != null && split.isNotEmpty) {
          val = answerMap![split[0]] ?? "0";
          v = split[1] ?? "-1";
        } else {
          val = "0";
          v = "-1";
        }

        if (answerMap![split[0]] is List) {
          return answerMap![split[0]].contains(split[1]);
        }

        s.add(double.tryParse(val) ?? val);
        s.add(double.tryParse(v) ?? v);

        split = s;
      }

      if (split.isNotEmpty) {
        return isHavingNot ? !(split[0] == split[1]) : split[0] == split[1];
      } else {
        throw Exception("Invalid value $newCondition");
      }
    } else {
      throw Exception("Invalid Condition checkExpression $newCondition");
    }
  }

  List<String> spiteDateEquation(String pattern) {
    if (!pattern.startsWith(START) || !pattern.endsWith(END)) {
      throw Exception("Invalid exp");
    } else {
      var newPattern = pattern.trim().removeStartEnd;
      var split = newPattern.split(",");
      if (split.length == 3 && split[1].isNotEmpty && split[2].isNotEmpty) {
        return [split[0], split[1], split[2]];
      } else {
        throw Exception("Invalid exp");
      }
    }
  }

  bool checkRegularExpression(String formula) {
    String newFormula = formula;
    if (newFormula.startsWith(START) && newFormula.endsWith(END)) {
      newFormula = newFormula.removeSurrounding(START, END);
    }

    return false;
  }
}
//
// extension IsValidEquation on String {
//   bool get isValidExpression {
//     int countStart = allMatches(ConditionEquation.START).length;
//     int countEnd = allMatches(ConditionEquation.END).length;
//     return countStart == countEnd;
//   }
// }
//
// extension GetCount on String {
//   int countChars(String value) {
//     return value.allMatches(this).length;
//   }
// }
//
// extension GetRegex on String {
//   List<String> splitRegex() {
//     if (contains(ConditionEquation.EQUAL_TO)) {
//       return split(ConditionEquation.EQUAL_TO);
//     } else if (contains('=')) {
//       return split('');
//     }
//     return [];
//   }
// }

extension GetValue on String {
  List<double?>? getValues(String conditions, Map<String, dynamic>? answer, {String? parentId}) {
    var map = conditions
        .split(this)
        .map((e) => MathUtils().putValueAndSolveExpression(e, answer, parentId: parentId).toString())
        .map((e) => double.parse(e));
    if (map.length == 2 && !map.contains(null)) {
      return map.toList();
    }
    return null;
  }
}

extension StringToRegex on String {
  RegExp get toRegex => RegExp(this);
}

extension CheckValidRegex on String {
  bool get isValidRegex =>
      contains("*") ||
      contains("\$") ||
      contains("^") ||
      contains("\\") ||
      (contains("]") && contains("[")) ||
      (contains("(") && contains(")")) ||
      ((contains("{") && contains("}")) || contains("?") || contains("+") || contains("|") || contains("&"));
}

extension StringEquation on String {
  bool get isValidEquation => ConditionEquation.START.allMatches(this).length == ConditionEquation.END.allMatches(this).length;
}

extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}

extension RemoveSurrounding on String {
  String removeSurrounding(String prefix, String suffix) {
    if ((length >= prefix.length + suffix.length) && startsWith(prefix) && endsWith(suffix)) {
      return substring(prefix.length, length - suffix.length);
    }
    return this;
  }
}

extension RemoveFirstAndLast on String {
  String get removeStartEnd {
    String data = this;
    return data.substring(1, data.length - 1);
  }
}

extension RandomOfDigits on Random {
  /// Generates a non-negative random integer with a specified number of digits.
  ///
  /// Supports [digitCount] values between 1 and 9 inclusive.
  int nextIntOfDigits(int digitCount) {
    assert(1 <= digitCount && digitCount <= 9);
    int min = digitCount == 1 ? 0 : int.parse(pow(10, digitCount - 1).toString());
    int max = int.parse(pow(10, digitCount).toString());
    return min + nextInt(max - min);
  }
}

class DateEquationResult {
  final String item1;
  final String item2;
  final String item3;

  DateEquationResult(this.item1, this.item2, this.item3);
}
