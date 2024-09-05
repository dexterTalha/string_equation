import 'package:string_equation/string_equation.dart';

void main() {
  var value = ConditionEquation().evaluateExpression("(2+3)");
  var value2 = ConditionEquation().evaluateExpression("(2<3)");
  var value3 = ConditionEquation().evaluateExpression("(2<3) && (4>5) || (4==4) && (3<2)");
  print(value);
  print(value2);
  print(value3);
}
