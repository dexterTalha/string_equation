import 'package:string_equation/string_equation.dart';

/// Main function to evaluate and print various expressions.
void main() {
  /// Evaluates the expression "(2+3)" and stores the result in `value`.
  var value = ConditionEquation().evaluateExpression("(2+3)");

  /// Evaluates the expression "(2<3)" and stores the result in `value2`.
  var value2 = ConditionEquation().evaluateExpression("(2<3)");

  /// Evaluates the complex expression "(2<3) && (4>5) || (4==4) && (3<2)" and stores the result in `value3`.
  var value3 = ConditionEquation()
      .evaluateExpression("(2<3) && (4>5) || (4==4) && (3<2)");

  /// Prints the result of the first expression.
  print(value);

  /// Prints the result of the second expression.
  print(value2);

  /// Prints the result of the complex expression.
  print(value3);
}
