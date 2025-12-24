/// A powerful math expression parser and equation solver for Dart.
///
/// This library provides tools for:
/// - Parsing mathematical expressions with explicit operators
/// - Extracting variables from expressions
/// - Evaluating expressions with variable substitution
/// - Solving equations (algebraically and numerically)
/// - Complex number support
/// - Physics constants
/// - Symbolic calculus (differentiation and integration)
///
/// ## Quick Start
///
/// ```dart
/// import 'package:functionx/functionx.dart';
///
/// // Extract variables
/// final vars = EquationParser.extractVariables('y = m*x + b');
/// print(vars); // ['b', 'm', 'x', 'y']
///
/// // Evaluate expression
/// final result = EquationParser.evaluate('x^2 + 2*x + 1', {'x': 3.0});
/// print(result); // 16.0
///
/// // Evaluate complex expressions
/// final complex = EquationParser.evaluate('sqrt(-1)');
/// print(complex); // i (Complex)
///
/// // Solve equation
/// final solution = EquationParser.solve('F = m*a', {'F': 10.0, 'm': 2.0}, solveFor: 'a');
/// print(solution.solvedValue); // 5.0
///
/// // Symbolic differentiation
/// final derivative = Cas.differentiate('x^2', 'x');
/// print(derivative); // '2.0 * x'
/// ```
///
/// ## Expression Syntax
///
/// This parser supports both **explicit** and **implicit** operator notation:
/// - ✅ `2*x + 3` (explicit)
/// - ✅ `2x + 3` (implicit multiplication supported)
/// - ✅ `3(x+1)` or `(x+1)(x-1)` (parentheses shorthand)
///
/// Supported operators: `+`, `-`, `*`, `/`, `^`
///
/// Supported functions: `sin`, `cos`, `tan`, `asin`, `acos`, `atan`,
/// `sqrt`, `abs`, `log`, `ln`, `exp`, `pow`
///
/// Mathematical constants: `PI`, `EN` (Euler's number), `IN` (imaginary unit), `INF`
library functionx;

// ═══════════════════════════════════════════════════════════════════════════
// PRIMARY API - Unified Equation Parser
// ═══════════════════════════════════════════════════════════════════════════

export 'src/equation_parser.dart'
    show EquationParser, EquationResult, SolutionStep, PhysicsConstant;

// ═══════════════════════════════════════════════════════════════════════════
// CORE COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════

export 'src/core/grammar.dart' show ExpressionGrammar;
export 'src/core/parser.dart' show ExpressionParser, ParseResult;
export 'src/core/evaluator.dart' show Evaluator;
export 'src/core/solver.dart' show Solver, SolveResult;
export 'src/core/constants.dart' show Constants, Constant;
export 'src/core/complex.dart' show Complex;
export 'src/core/complex_evaluator.dart' show ComplexEvaluator;

// ═══════════════════════════════════════════════════════════════════════════
// COMPUTER ALGEBRA SYSTEM
// ═══════════════════════════════════════════════════════════════════════════

export 'src/cas/cas.dart' show Cas;

// ═══════════════════════════════════════════════════════════════════════════
// LEGACY EXPORTS (deprecated - use EquationParser instead)
// ═══════════════════════════════════════════════════════════════════════════

export 'src/explicit_parser.dart';
export 'src/cas_parser.dart';
