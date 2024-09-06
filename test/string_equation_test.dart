import 'package:string_equation/string_equation.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    test("Solve Expression0", () async {
      bool value = ConditionEquation().evaluateExpression(
          "((0.00==1)||((180.00>=180)&&(180.00<=400)&&(1.00<=300))||((1.00>=110)&&(1.00<=300)&&(180.00<=400)))");
      expect(true, value);
    });
    test("Solve Expression1", () async {
      bool value = ConditionEquation().solveExpression(
          "((0.00==1)||(180.00>=180)&&(180.00<=400)&&(1.00<=300)||(1.00>=110)&&(1.00<=300)&&(180.00<=400))");
      expect(true, value);
    });

    test("Solve Expression2", () async {
      bool value =
          ConditionEquation().solveExpression("(((9>7) && (6>7)) && (3>1))");
      expect(false, value);
    });

    test("Solve Expression3", () async {
      bool value = ConditionEquation()
          .solveExpression("((5==5) && (12 <= 10) || (14>= 9))");
      expect(true, value);
    });

    test("Solve Expression4", () async {
      bool value = ConditionEquation().solveExpression("((7==7) && (12<= 9))");
      expect(false, value);
    });
    test("Solve Expression5", () async {
      bool value = ConditionEquation()
          .solveExpression("((3>= 4) || (7>=6) || (12 == 10))");
      expect(true, value);
    });
    test("Solve Expression6", () async {
      bool value = ConditionEquation()
          .solveExpression("((9 < 7) || (12 < 13) || (7==8 ))");
      expect(true, value);
    });
    test("Solve Expression7 ", () async {
      bool value =
          ConditionEquation().solveExpression("((1>2) || (3>5) || (7 == 8))");
      expect(false, value);
    });
    test("Solve Expression8", () async {
      bool value = ConditionEquation().solveExpression("((7>4) || (8>=8))");
      expect(true, value);
    });
    test("Solve Expression9", () async {
      bool value = ConditionEquation().evaluateExpression("((7>4) || (8!=8))");
      expect(true, value);
    });
    test("Solve Expression10", () async {
      bool value = ConditionEquation().evaluateExpression("(1==@^[1]@)");
      expect(true, value);
      // bool value = ConditionEquation().solveExpression("(!(9>7))");
      // expect(false, value);
    });

    // test("Solve Expression10.1", () async {
    //   bool value = ConditionEquation().solveExpression("(!(9>7) && !(7==5) || (5==5))");
    //   expect(true, value);
    // });
    test("Solve Expression11", () async {
      bool value =
          ConditionEquation().solveExpression("(9>7) && (6>7) || (3>1) ");
      expect(true, value);
    });
    test("Solve Expression12", () async {
      bool value = ConditionEquation().solveExpression("((9>7)&(3>1))");
      expect(true, value);
    });
    test("Solve Expression13", () async {
      bool value =
          ConditionEquation().solveExpression("((9>7) && (6>7) || (3>3))");
      expect(false, value);
    });
    test("Solve Expression14", () async {
      bool value =
          ConditionEquation().solveExpression("( (9>7) && ((6>7)&&(3>3)))");
      expect(false, value);
    });
    test("Solve Expression15", () async {
      bool value =
          ConditionEquation().solveExpression("( (9>7) && ((8>7)&&(3>=3)))");
      expect(true, value);
    });
    test("Solve Expression16", () async {
      bool value = ConditionEquation().solveExpression("(1==1)");
      expect(true, value);
    });

    // "!(((3+4)>7)&&(1==1 && 1<0 || 2>1)))"
    // test("Solve Expression17", () async {
    //   bool value = ConditionEquation().solveExpression("!(7 == 8)");
    //   expect(true, value);
    // });
    test("Solve Expression18", () async {
      bool value = ConditionEquation()
          .solveExpression("(((3+4)>7)&&(1==1 && 1<0 || 2>1))");
      expect(false, value);
    });

    test("MATH Expression1", () async {
      bool value = ConditionEquation().solveExpression("(5>(1+2))");
      expect(true, value);
    });
    test("MATH Expression2", () async {
      bool value = ConditionEquation().solveExpression("(5<(1+2))");
      expect(false, value);
    });

    test("MATH Addition", () async {
      var value =
          MathUtils().putValueAndSolveExpression("a+b", {"a": 1, "b": 2});
      expect(value, 3.0);
    });
    test("MATH Multiply", () async {
      var value =
          MathUtils().putValueAndSolveExpression("a*b", {"a": 2, "b": 2});
      expect(value, 4.0);
    });
    test("MATH Subtract", () async {
      var value =
          MathUtils().putValueAndSolveExpression("a-b", {"a": 1, "b": 2});
      expect(value, -1.0);
    });
    test("MATH divide", () async {
      var value =
          MathUtils().putValueAndSolveExpression("a/b", {"a": 1, "b": 2});
      expect(value, 0.5);
    });
    test("MATH power", () async {
      var value =
          MathUtils().putValueAndSolveExpression("a^b", {"a": 3, "b": 2});
      expect(value, 9);
    });

    test("EXT", () async {
      var value = ConditionEquation(answerMap: {
        "order30": [
          "c70c7c93-f486-43a7-bff6-9e82ec849885",
          "deb0118f-85c3-47c9-81b2-ed1b9b595224",
          "8279398a-ff02-4c08-84df-e755611ca017",
          "4c8e76bb-869a-4f85-9892-5c1c6341e922"
        ]
      }).solveExpression("(order30==4c8e76bb-869a-4f85-9892-5c1c6341e922)");
      expect(value, true);
    });

    test("SINGLE SELECT LOOPING ADD BUTTON", () {
      var map = {"order11": ''};
      bool result = ConditionEquation(answerMap: map)
          .evaluateExpression("(order11==@^(1)\$@)");
      print(result);
      expect(false, result);
    });

    test("Check regular Expression", () async {
      var value = ConditionEquation(answerMap: {'order4': "2"})
          .evaluateExpression(
              "(order4==@^((?:[1-9]|1[0-8]))\$@)||(order5==@^([1])\$@)");
      expect(true, value);
    });
  });
}
