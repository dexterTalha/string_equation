import 'package:string_equation/string_equation.dart';

void main() {
  bool value =
      ConditionEquation().evaluateExpression("((0.00==1)||((180.00>=180)&&(180.00<=400)&&(1.00<=300))||((1.00>=110)&&(1.00<=300)&&(180.00<=400)))");
  print(value);
}
