# functionx

A powerful equation parser and solver for Dart — f(x) for your code.

[![pub package](https://img.shields.io/pub/v/functionx.svg)](https://pub.dev/packages/functionx)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- 🧮 **Expression Parsing** - Strictly explicit parsing (e.g. `2*x`, `m*a`) for maximum predictability
- 📊 **Variable Extraction** - Intelligently extract variables while filtering constants
- 🔢 **Expression Evaluation** - Multi-mode evaluation (Real, Complex, and Mixed)
- ⚡ **Equation Solving** - High-precision algebraic and numerical solvers
- � **System Solver** - Solve systems of non-linear equations (Real & Complex)
- �📈 **Symbolic Calculus** - Fast differentiation and integration
- 🔬 **Auto-resolve Constants** - Automatic identification of symbols like $c$, $h$, and $k_B$
- 🇬🇷 **LaTeX Support** - Seamless parsing of Greek letters and complex subscripts

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  functionx: ^1.3.1
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

  // Solve a system of equations
  final system = SystemSolver.solve([
    'x^2 + y^2 = 1',
    'y = x'
  ]);
  print(system.values); // {x: 0.707..., y: 0.707...}

  // Use physical constants
  final c = Constants.speedOfLight;
  print('${c.name}: ${c.value} ${c.unit}'); // Speed of Light: 299792458 m/s

  // Symbolic differentiation
  final derivative = Cas.differentiate('x^2', 'x');
  print(derivative); // '2.0 * x'
}
```

## Expression Syntax

This parser is designed to be ergonomic but **strictly explicit**:

| ✅ Notation | 📝 Example |
|-------------|------------|
| Explicit | `2*x + 3*y` |
| Parentheses | `3*(x+1)*(x-1)` |
| Complex | `(1+i)i` |
| Greek | `\Delta E = h*\nu` |
| Subscripts | `x_1 + x_2` |

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
| `PI` | 3.14159... |
| `EN` | 2.71828... |
| `INF` | ∞ |
| `IN` | i (√-1) |

### Reserved Words & Aliases

To avoid ambiguity (like $c$ for the speed of light vs $c$ for a variable), `functionx` uses **Strict Constant Lookup**.
You MUST use these specific keys if you want the parser to auto-resolve constants. Common symbols like `c`, `g`, `h` are treated as plain variables.

- **Functions**: `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `sqrt`, `abs`, `log`, `ln`, `exp`, `pow`
- **Math Constants**: `PI`, `EN`, `INF`, `IN`
- **Natural Constants (Keys)**: `SOL` (Speed of Light), `GC` (Gravitational), `PC` (Planck), `SG` (Standard Gravity), `NA` (Avogadro), etc.

*Note: You must explicitly use `SOL` (or `speed_of_light`) to get the constant $c$. Uses of `c` will just be the variable $c$.*

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
final g = Constants.get('GC');
print(g?.value); // 6.6743e-11

// List all constants in a category
final fundamental = Constants.byCategory('fundamental');

// Search constants
final results = Constants.search('mass');
```

#### Available Categories

| Category | Examples |
|----------|----------|
| `mathematical` | π, e, φ (golden ratio), √2, i |
| `fundamental` | Speed of light, Planck constant, Gravitational constant |
| `electromagnetic` | Elementary charge, Vacuum permittivity, Coulomb constant |
| `atomic` | Electron/Proton mass, Bohr radius, Fine structure, Rydberg |
| `thermodynamic` | Boltzmann const, Gas constant, Radiation constants |
| `quantum` | Magnetic Flux Quantum, Conductance Quantum, Josephson |
| `electrochemical` | Faraday constant |
| `earth` | Standard gravity, Earth mass, Earth radius |
| `celestial` | Sun mass, Astronomical unit, Light year |

#### Common Constants

| Property | Key | Symbol | Value |
|----------|-----|--------|-------|
| `Constants.speedOfLight` | `SOL` | c | 299792458 m/s |
| `Constants.planck` | `PC` | h | 6.626e-34 J⋅s |
| `Constants.gravitationalConstant` | `GC` | G | 6.674e-11 N⋅m²/kg² |
| `Constants.boltzmann` | `BC` | kB | 1.381e-23 J/K |
| `Constants.avogadro` | `AN` | NA | 6.022e23 1/mol |
| `Constants.faraday` | `FC` | F | 96485 C/mol |
| `Constants.rydberg` | `RYD` | R∞ | 1.097e7 1/m |
| `Constants.standardGravity` | `SG` | g | 9.807 m/s² |
| `Constants.elementaryCharge` | `EC` | e | 1.602e-19 C |
| `Constants.coulomb` | `CC` | k | 8.988e9 N⋅m²/C² |
| `Constants.pi` | `PI` | π | 3.14159... |
| `Constants.e` | `EN` | e | 2.71828... |
| `Constants.imaginaryUnit` | `IN` | i | √-1 |

## License

MIT License - see [LICENSE](LICENSE) for details.
