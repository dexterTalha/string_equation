import 'dart:math';

import 'math_utils.dart';

/// A class to handle condition equations and their evaluation.
///
/// This class provides methods to evaluate logical expressions, split equations into components,
/// and handle various logical operators.
class ConditionEquation {
  /// Represents the greater than operator.
  static const String GREATER_THAN = ">";

  /// Represents the greater than or equal to operator.
  static const String GREATER_THAN_EQUAL_TO = ">=";

  /// Represents the less than operator.
  static const String LESS_THAN = "<";

  /// Represents the less than or equal to operator.
  static const String LESS_THAN_EQUAL_TO = "<=";

  /// Represents the equal to operator.
  static const String EQUAL_TO = "==";

  /// Represents the not equal to operator.
  static const String NOT_EQUAL_TO = "!=";

  /// Represents the original not operator.
  static const String ORIGINAL_NOT = "!";

  /// Represents the reverse not operator.
  static const String REVERSE_NOT = "n";

  /// Represents the start parenthesis.
  static const String START = '(';

  /// Represents the double start parenthesis.
  static const String DOUBLE_START = "((";

  /// Represents the double end parenthesis.
  static const String DOUBLE_END = "))";

  /// Represents the end parenthesis.
  static const String END = ')';

  /// Represents the AND operator.
  static const String AND = 'A';

  /// Represents the NOT operator.
  static const String NOT = '!';

  /// Represents the original single AND operator.
  static const String ORIGINAL_SINGLE_AND = "&";

  /// Represents the original AND operator.
  static const String ORIGINAL_AND = "&&";

  /// Represents the OR operator.
  static const String OR = 'O';

  /// Represents the original single OR operator.
  static const String ORIGINAL_SINGLE_OR = "|";

  /// Represents the original OR operator.
  static const String ORIGINAL_OR = "||";

  /// A map containing answers for variables in the conditions.
  final Map<String, dynamic>? answerMap;

  /// An optional parent ID for context.
  final String? parentId;

  /// Constructor for ConditionEquation.
  ///
  /// \param answerMap A map containing answers for variables in the conditions.
  /// \param parentId An optional parent ID for context.
  ConditionEquation({this.answerMap, this.parentId});

  /// Indicates if the current condition has a NOT operator.
  bool isHavingNot = false;

  /// Indicates if the global condition has a NOT operator.
  bool isGlobalHavingNot = false;

  /// Splits a date equation pattern into its components.
  ///
  /// This function splits a date equation pattern into its individual components. The pattern must
  /// start and end with parentheses and contain three comma-separated values.
  ///
  /// \param pattern The date equation pattern to be split.
  /// \return A DateEquationResult containing the three components of the date equation pattern.
  DateEquationResult? splitDateEquation(String pattern) {
    if (!pattern.startsWith('(') || !pattern.endsWith(')')) {
      throw Exception("Invalid exp");
    } else {
      final newPattern = pattern.trim().substring(1, pattern.length - 1);
      final split = newPattern.split(",");
      if (split.length == 3 &&
          split[0].isNotEmpty &&
          split[1].isNotEmpty &&
          split[2].isNotEmpty) {
        return DateEquationResult(split[0], split[1], split[2]);
      } else {
        throw Exception("Invalid exp");
      }
    }
  }

  /// Splits an equation string into its components and logical operators.
  ///
  /// This function splits an equation string into its individual components and identifies the logical
  /// operators (AND, OR) within the equation.
  ///
  /// \param equations The equation string to be split.
  /// \return A map containing the split equations and their corresponding logical operators.
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

  /// Evaluates a given expression by checking for logical operators and solving it accordingly.
  ///
  /// This function first checks if the expression contains any logical operators. If not, it uses
  /// `MathUtils` to solve the expression. If logical operators are present, it processes the expression
  /// to handle nested conditions and logical operations.
  ///
  /// \param expression The expression to be evaluated.
  /// \return The result of the evaluated expression.
  dynamic evaluateExpression(String expression) {
    var logicalOperators = [
      GREATER_THAN,
      EQUAL_TO,
      LESS_THAN,
      NOT,
      ORIGINAL_SINGLE_OR,
      ORIGINAL_SINGLE_AND
    ];
    if (!logicalOperators.any((e) => expression.contains(e))) {
      return MathUtils().putValueAndSolveExpression(expression, answerMap,
          parentId: parentId);
    }
    Map exp = {};
    String replacement = "";
    Random random = Random();
    String newExpression = expression;
    String subChar = "@";
    bool insideAtBlock = false;
    for (int i = 0; i < expression.length; i++) {
      String st = expression[i];

      if (st == subChar) {
        if (insideAtBlock) {
          String key = random.nextIntOfDigits(5).toString();
          exp[key] = replacement;

          newExpression =
              newExpression.replaceFirst("@$replacement@", "@$key@");

          insideAtBlock = false;
          replacement = "";
        } else {
          insideAtBlock = true;
        }
      } else if (insideAtBlock) {
        replacement += st;
      }
    }
    String eq =
        newExpression.removeSurrounding(START.toString(), END.toString());
    isGlobalHavingNot = eq.startsWith(NOT) &&
        eq.startsWith(DOUBLE_START, 1) &&
        eq.endsWith(DOUBLE_END);
    if (isGlobalHavingNot) {
      newExpression = eq.replaceAll(NOT, "");
    }
    bool result = solveExpression(newExpression, map: exp);
    return isGlobalHavingNot ? !result : result;
  }

  /// Solves a given logical expression by breaking it down into smaller sub-expressions and evaluating them.
  ///
  /// This function handles logical operators such as AND and OR, and recursively solves sub-expressions.
  ///
  /// \param expression The logical expression to be solved.
  /// \param map A map containing sub-expressions and their corresponding values.
  /// \return The result of the solved expression.
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

    if (splitEquation(equations)['equations'].length == 1 &&
        equations.startsWith(DOUBLE_START) &&
        equations.endsWith(DOUBLE_END)) {
      equations =
          equations.trim().removeSurrounding(START.toString(), END.toString());
    }

    if (equations.contains(AND) || equations.contains(OR)) {
      Map splitEq = splitEquation(equations);
      var hashMap = splitEq['map'];

      for (var mutableEntryKey in hashMap.keys) {
        var operatorIndex = mutableEntryKey;
        var eq1Index = 0;
        var eq2Index = operatorIndex + 1;
        var eq1 = equations.substring(eq1Index, operatorIndex).toString();
        var eq2 = equations.substring(eq2Index, equations.length).toString();

        if (eq1.isValidEquation && eq2.isValidEquation) {
          if (hashMap[mutableEntryKey] == OR) {
            return solveExpression(eq1, map: map) ||
                solveExpression(eq2, map: map);
          } else if (hashMap[mutableEntryKey] == AND) {
            return solveExpression(eq1, map: map) &&
                solveExpression(eq2, map: map);
          }
          break;
        }
      }
    } else {
      return checkExpression(equations, map: map);
    }
    throw Exception("Invalid Condition Solve Expression $equations");
  }

  /// Checks the given expression by evaluating various logical conditions.
  ///
  /// This function evaluates the given expression by checking for various logical conditions such as
  /// greater than, less than, equal to, and not equal to. It also handles nested conditions and logical
  /// operators.
  ///
  /// \param conditions The expression to be evaluated.
  /// \param map A map containing sub-expressions and their corresponding values.
  /// \return The result of the evaluated expression.
  bool checkExpression(String conditions, {Map map = const {}}) {
    // print(conditions);
    String newCondition = conditions;

    if (newCondition.startsWith(START) && newCondition.endsWith(END)) {
      newCondition =
          conditions.trim().removeSurrounding(START.toString(), END.toString());
      return checkExpression(newCondition, map: map);
    }
    isHavingNot = newCondition.startsWith(NOT);
    if (isHavingNot) {
      newCondition = newCondition.substring(1, conditions.length);
      newCondition = newCondition
          .trim()
          .removeSurrounding(START.toString(), END.toString());
    }

    if (newCondition.contains(GREATER_THAN_EQUAL_TO)) {
      List<dynamic> split = newCondition.split(GREATER_THAN_EQUAL_TO);
      try {
        split = GREATER_THAN_EQUAL_TO.getValues(newCondition, answerMap,
                parentId: parentId) ??
            [];
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
        split = LESS_THAN_EQUAL_TO.getValues(newCondition, answerMap,
                parentId: parentId) ??
            [];
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
      var split =
          NOT_EQUAL_TO.getValues(newCondition, answerMap, parentId: parentId);
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
        return isHavingNot
            ? !(!(split[0] == split[1]))
            : !(split[0] == split[1]);
      } else {
        throw Exception("Invalid value $newCondition");
      }
    } else if (newCondition.contains(GREATER_THAN)) {
      var split =
          GREATER_THAN.getValues(newCondition, answerMap, parentId: parentId);

      if (split != null) {
        // return split[0]! > split[1]!;
        return isHavingNot ? !(split[0]! > split[1]!) : split[0]! > split[1]!;
      } else {
        throw Exception("Invalid value $newCondition");
      }
    } else if (newCondition.contains(LESS_THAN)) {
      var split =
          LESS_THAN.getValues(newCondition, answerMap, parentId: parentId);
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
            bool isList = answerMap![split[0]] == null
                ? false
                : answerMap![split[0]] is List;
            if (!isList) {
              String? val = answerMap?[split[0]]?.toString();
              if (val == null) return false;
              matchValue = val;
            } else {
              List<dynamic> val = answerMap?[split[0]];
              if (val.isEmpty) return false;
              return val
                  .any((element) => regExp.hasMatch(element?.toString() ?? ""));
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
        split =
            EQUAL_TO.getValues(newCondition, answerMap, parentId: parentId) ??
                [];
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

        if (answerMap != null && answerMap![split[0]] is List) {
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

  /// Splits a date equation pattern into its components.
  ///
  /// This function splits a date equation pattern into its individual components. The pattern must
  /// start and end with parentheses and contain three comma-separated values.
  ///
  /// \param pattern The date equation pattern to be split.
  /// \return A list containing the three components of the date equation pattern.
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

  /// Checks if the given formula is a valid regular expression.
  ///
  /// This function processes the given formula by removing surrounding parentheses if present.
  /// Currently, it always returns false.
  ///
  /// \param formula The formula to be checked.
  /// \return Always returns false.
  bool checkRegularExpression(String formula) {
    String newFormula = formula;
    if (newFormula.startsWith(START) && newFormula.endsWith(END)) {
      newFormula = newFormula.removeSurrounding(START, END);
    }

    return false;
  }
}

/// Extension on String to provide utility methods for condition evaluation and regex operations.
extension GetValue on String {
  /// Splits the string based on the current instance and evaluates each part as a mathematical expression.
  ///
  /// \param conditions The conditions to be split and evaluated.
  /// \param answer A map containing answers for variables in the conditions.
  /// \param parentId An optional parent ID for context.
  /// \return A list of evaluated double values or null if the evaluation fails.
  List<double?>? getValues(String conditions, Map<String, dynamic>? answer,
      {String? parentId}) {
    var map = conditions
        .split(this)
        .map((e) => MathUtils()
            .putValueAndSolveExpression(e, answer, parentId: parentId)
            .toString())
        .map((e) => double.parse(e));
    if (map.length == 2 && !map.contains(null)) {
      return map.toList();
    }
    return null;
  }
}

/// Extension on String to convert a string to a regular expression.
extension StringToRegex on String {
  /// Converts the string to a regular expression.
  ///
  /// \return A RegExp object created from the string.
  RegExp get toRegex => RegExp(this);
}

/// Extension on String to check if a string is a valid regular expression.
extension CheckValidRegex on String {
  /// Checks if the string contains valid regex characters.
  ///
  /// \return True if the string contains valid regex characters, false otherwise.
  bool get isValidRegex =>
      contains("*") ||
      contains("\$") ||
      contains("^") ||
      contains("\\") ||
      (contains("]") && contains("[")) ||
      (contains("(") && contains(")")) ||
      ((contains("{") && contains("}")) ||
          contains("?") ||
          contains("+") ||
          contains("|") ||
          contains("&"));
}

/// Extension on String to check if a string is a valid equation.
extension StringEquation on String {
  /// Checks if the string has balanced parentheses.
  ///
  /// \return True if the string has balanced parentheses, false otherwise.
  bool get isValidEquation =>
      ConditionEquation.START.allMatches(this).length ==
      ConditionEquation.END.allMatches(this).length;
}

/// Extension on String to provide casing utility methods.
extension StringCasingExtension on String {
  /// Converts the string to capitalized form.
  ///
  /// \return The string with the first letter capitalized and the rest in lowercase.
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  /// Converts the string to title case.
  ///
  /// \return The string with each word capitalized.
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

/// Extension on String to remove surrounding characters.
extension RemoveSurrounding on String {
  /// Removes the specified prefix and suffix from the string if they are present.
  ///
  /// \param prefix The prefix to be removed.
  /// \param suffix The suffix to be removed.
  /// \return The string without the specified prefix and suffix.
  String removeSurrounding(String prefix, String suffix) {
    if ((length >= prefix.length + suffix.length) &&
        startsWith(prefix) &&
        endsWith(suffix)) {
      return substring(prefix.length, length - suffix.length);
    }
    return this;
  }
}

/// Extension on String to remove the first and last characters.
extension RemoveFirstAndLast on String {
  /// Removes the first and last characters from the string.
  ///
  /// \return The string without the first and last characters.
  String get removeStartEnd {
    String data = this;
    return data.substring(1, data.length - 1);
  }
}

/// Extension on Random to generate random integers with a specified number of digits.
extension RandomOfDigits on Random {
  /// Generates a non-negative random integer with a specified number of digits.
  ///
  /// Supports [digitCount] values between 1 and 9 inclusive.
  ///
  /// \param digitCount The number of digits for the random integer.
  /// \return A random integer with the specified number of digits.
  int nextIntOfDigits(int digitCount) {
    assert(1 <= digitCount && digitCount <= 9);
    int min =
        digitCount == 1 ? 0 : int.parse(pow(10, digitCount - 1).toString());
    int max = int.parse(pow(10, digitCount).toString());
    return min + nextInt(max - min);
  }
}

/// Class to hold the result of a date equation split.
class DateEquationResult {
  final String item1;
  final String item2;
  final String item3;

  /// Constructor for DateEquationResult.
  ///
  /// \param item1 The first item of the date equation.
  /// \param item2 The second item of the date equation.
  /// \param item3 The third item of the date equation.
  DateEquationResult(this.item1, this.item2, this.item3);
}
