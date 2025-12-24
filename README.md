# functionx

A powerful equation parser and solver for Dart — f(x) for your code.

[![pub package](https://img.shields.io/pub/v/functionx.svg)](https://pub.dev/packages/functionx)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- 🧮 **Expression Parsing** - Parse mathematical expressions with explicit operators
- 📊 **Variable Extraction** - Extract all variables from an expression
- 🔢 **Expression Evaluation** - Evaluate expressions with variable substitution
- ⚡ **Equation Solving** - Solve equations algebraically and numerically
- 📈 **Symbolic Calculus** - Differentiation and integration (CAS)
- 🔬 **Physical Constants** - Comprehensive collection of physics and math constants

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  functionx: ^2.0.0
```

## Quick Start

```dart
import 'package:functionx/functionx.dart';

void main() {
  // Extract variables from an equation
  final vars = ExpressionParser.extractVariables('y = m*x + b');
  print(vars); // ['b', 'm', 'x', 'y']

  // Evaluate an expression
  final result = Evaluator.evaluate('x^2 + 2*x + 1', {'x': 3});
  print(result); // 16.0

  // Solve an equation
  final solution = Solver.solve(
    'F = m*a',
    {'F': 10, 'm': 2},
    solveFor: 'a',
  );
  print(solution.value); // 5.0

  // Use physical constants
  final c = Constants.speedOfLight;
  print('${c.name}: ${c.value} ${c.unit}'); // Speed of Light: 299792458 m/s

  // Symbolic differentiation
  final derivative = Cas.differentiate('x^2', 'x');
  print(derivative); // '2.0 * x'
}
```

## Expression Syntax

This parser uses **explicit operator notation**:

| ✅ Correct | ❌ Incorrect |
|-----------|-------------|
| `2*x + 3` | `2x + 3` |
| `a*b*c` | `abc` |
| `sin(x)^2` | `sin^2(x)` |

### Supported Operators

| Operator | Description |
|----------|-------------|
| `+` | Addition |
| `-` | Subtraction |
| `*` | Multiplication |
| `/` | Division |
| `^` | Exponentiation |

### Supported Functions

| Function | Description |
|----------|-------------|
| `sin(x)` | Sine |
| `cos(x)` | Cosine |
| `tan(x)` | Tangent |
| `asin(x)` | Arc sine |
| `acos(x)` | Arc cosine |
| `atan(x)` | Arc tangent |
| `sqrt(x)` | Square root |
| `abs(x)` | Absolute value |
| `log(x)` | Natural logarithm |
| `ln(x)` | Natural logarithm |
| `exp(x)` | Exponential |
| `pow(x, n)` | Power |

### Mathematical Constants

| Constant | Value |
|----------|-------|
| `pi` | 3.14159... |
| `e` | 2.71828... |
| `infinity` | ∞ |

## API Reference

### ExpressionParser

```dart
// Parse expression or equation
final result = ExpressionParser.parse('y = m*x + b');
print(result.isEquation); // true

// Extract variables
final vars = ExpressionParser.extractVariables('F = m*a');
print(vars); // ['F', 'a', 'm']
```

### Evaluator

```dart
// Evaluate with variables
final result = Evaluator.evaluate('x^2 + y', {'x': 3, 'y': 5});
print(result); // 14.0

// Evaluate numeric expression (no variables)
final result = Evaluator.evaluateNumeric('2 + 3 * 4');
print(result); // 14.0
```

### Solver

```dart
// Solve for unknown variable
final result = Solver.solve(
  '2*x + 5 = 11',
  {'x': null},
);
print(result.value); // 3.0
print(result.steps); // ['...solution steps...']

// Solve physics equation
final result = Solver.solve(
  'F = m*a',
  {'F': 10, 'm': 2},
  solveFor: 'a',
);
print(result.value); // 5.0
```

### Cas (Computer Algebra System)

```dart
// Differentiation
final deriv = Cas.differentiate('x^3', 'x');
print(deriv); // '3.0 * x ^ 2.0'

// Integration
final integral = Cas.integrate('x', 'x');
print(integral); // '0.5*x^2'

// Simplification
final simplified = Cas.simplify('x + x');
print(simplified); // '2.0 * x'
```

### Constants

A comprehensive collection of physical and mathematical constants.

```dart
// Access by property
final c = Constants.speedOfLight;
print(c.value);  // 299792458
print(c.symbol); // c
print(c.unit);   // m/s
print(c.name);   // Speed of Light

// Get by key
final g = Constants.get('G');
print(g?.value); // 6.6743e-11

// List all constants in a category
final fundamental = Constants.byCategory('fundamental');

// Search constants
final results = Constants.search('mass');
```

#### Available Categories

| Category | Examples |
|----------|----------|
| `mathematical` | π, e, φ (golden ratio), √2 |
| `fundamental` | Speed of light, Planck constant, Gravitational constant |
| `electromagnetic` | Elementary charge, Vacuum permittivity, Coulomb constant |
| `atomic` | Electron mass, Proton mass, Bohr radius, Fine structure constant |
| `thermodynamic` | Boltzmann constant, Gas constant, Avogadro number |
| `earth` | Standard gravity, Earth mass, Earth radius |
| `celestial` | Sun mass, Astronomical unit, Light year |

#### Common Constants

| Property | Key | Symbol | Value |
|----------|-----|--------|-------|
| `Constants.speedOfLight` | `SPEED_OF_LIGHT` | c | 299792458 m/s |
| `Constants.planck` | `PLANCK` | h | 6.626e-34 J⋅s |
| `Constants.gravitationalConstant` | `G` | G | 6.674e-11 N⋅m²/kg² |
| `Constants.boltzmann` | `K_B` | kB | 1.381e-23 J/K |
| `Constants.avogadro` | `N_A` | NA | 6.022e23 1/mol |
| `Constants.standardGravity` | `G_EARTH` | g | 9.807 m/s² |
| `Constants.elementaryCharge` | `E_CHARGE` | e | 1.602e-19 C |
| `Constants.pi` | `PI` | π | 3.14159... |
| `Constants.e` | `EULER` | e | 2.71828... |

## License

MIT License - see [LICENSE](LICENSE) for details.
