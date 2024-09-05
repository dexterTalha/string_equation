# ConditionEquation

## Description

ConditionEquation is a powerful Dart package that allows you to dynamically evaluate both logical and mathematical expressions from a string format. It offers robust support for variables, making it highly useful in scenarios where you need to parse, interpret, and compute expressions programmatically. Whether you're working on rule engines, dynamic forms, or data validation, ConditionEquation simplifies the process of handling complex expressions in your Dart applications.

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
import 'package:condition_equation/condition_equation.dart';

void main() {
  double value = ConditionEquation({'a': 2, 'b': 3}).evaluateExpression("(a + b)");
  print(value); // 5.0
}
```
## Contributing
If you'd like to contribute to the package, please feel free to open a pull request or file an issue. All contributions are welcome!

## License
Modified BSD License

Copyright (c) 2024 Mohd Talha

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE
