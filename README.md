# ConditionEquation

ConditionEquation is a Dart package that allows you to evaluate logical and mathematical expressions dynamically, with support for variables. The package is useful in scenarios where you need to interpret and evaluate expressions from a string format.

## Features

- Evaluate complex boolean expressions with logical operators.
- Support for comparison operators like `<`, `>`, `<=`, `>=`, `==`, `!=`.
- Evaluate mathematical expressions with standard arithmetic operations.
- Support for variables within expressions.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  string_equation: ^1.0.0
```
Then, run:

```bash
flutter pub get
```
## Usage
### Example 1: Evaluate a Complex Boolean Expression

```dart
import 'package:condition_equation/condition_equation.dart';

void main() {
  bool value = ConditionEquation().evaluateExpression(
    "((0.00==1)||(180.00>=180)&&(180.00<=400)&&(1.00<=300)||(1.00>=110)&&(1.00<=300)&&(180.00<=400))"
  );
  print(value); // true
}
```
### Example 2: Evaluate a Mathematical Expression
```dart
import 'package:condition_equation/condition_equation.dart';

void main() {
  double value = ConditionEquation().evaluateExpression("(2+3)");
  print(value); // 5.0
}
```
### Example 3: Evaluate an Expression with Variables
```dart
import 'package:condition_equation/condition_equation.dart';

void main() {
  bool value = ConditionEquation({'a': 2, 'b': 3}).evaluateExpression("(a < b)");
  print(value); // true
}
```

### Example 4: Evaluate a Mathematical Expression with Variables
```dart
Copy code
import 'package:condition_equation/condition_equation.dart';

void main() {
  double value = ConditionEquation({'a': 2, 'b': 3}).evaluateExpression("(a + b)");
  print(value); // 5.0
}
```
## Contributing
If you'd like to contribute to the package, please feel free to open a pull request or file an issue. All contributions are welcome!

## License
MIT License

Copyright (c) 2024 Mohd Talha

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
