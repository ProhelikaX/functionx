/// A powerful math expression parser and equation solver for Dart.
///
/// This library provides tools for:
/// - Parsing mathematical expressions with explicit operators
/// - Extracting variables from expressions
/// - Evaluating expressions with variable substitution
/// - Solving equations (algebraically and numerically)
/// - Symbolic calculus (differentiation and integration)
///
/// ## Quick Start
///
/// ```dart
/// import 'package:functionx/functionx.dart';
///
/// // Extract variables
/// final vars = ExpressionParser.extractVariables('y = m*x + b');
/// print(vars); // ['b', 'm', 'x', 'y']
///
/// // Evaluate expression
/// final result = Evaluator.evaluate('x^2 + 2*x + 1', {'x': 3});
/// print(result); // 16.0
///
/// // Solve equation
/// final solution = Solver.solve('F = m*a', {'F': 10, 'm': 2}, solveFor: 'a');
/// print(solution.value); // 5.0
///
/// // Symbolic differentiation
/// final derivative = Cas.differentiate('x^2', 'x');
/// print(derivative); // '2.0 * x'
/// ```
///
/// ## Expression Syntax
///
/// This parser uses **explicit operator notation**:
/// - ✅ `2*x + 3` (correct)
/// - ❌ `2x + 3` (implicit multiplication not supported)
///
/// Supported operators: `+`, `-`, `*`, `/`, `^`
///
/// Supported functions: `sin`, `cos`, `tan`, `asin`, `acos`, `atan`,
/// `sqrt`, `abs`, `log`, `ln`, `exp`, `pow`
///
/// Mathematical constants: `pi`, `e`, `infinity`
library functionx;

// Core parsing and evaluation
export 'src/core/grammar.dart' show ExpressionGrammar;
export 'src/core/parser.dart' show ExpressionParser, ParseResult;
export 'src/core/evaluator.dart' show Evaluator;
export 'src/core/solver.dart' show Solver, SolveResult;
export 'src/core/constants.dart' show Constants, Constant;

// Computer Algebra System
export 'src/cas/cas.dart' show Cas;

// Legacy exports (for backward compatibility)
// These will be deprecated in a future version
export 'src/math_equation_parser.dart';
export 'src/algebraic_equation_parser.dart';
export 'src/cas_parser.dart';
