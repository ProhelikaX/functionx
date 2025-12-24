import 'dart:math' as dart_math;
import 'package:math_expressions/math_expressions.dart';

/// Evaluates mathematical expressions with given variable values.
///
/// Example usage:
/// ```dart
/// final result = Evaluator.evaluate('x^2 + 2*x + 1', {'x': 3});
/// print(result); // 16.0
/// ```
class Evaluator {
  static final Parser _parser = Parser();

  /// Evaluates an expression string with the given variable values.
  ///
  /// [expression] - The mathematical expression to evaluate.
  /// [values] - Map of variable names to their numeric values.
  ///
  /// Returns the computed numeric result.
  /// Throws [FormatException] if the expression cannot be parsed.
  /// Throws [ArgumentError] if required variables are missing.
  static double evaluate(String expression, [Map<String, double>? values]) {
    final cleanExpr = expression.trim();
    final parsed = _parser.parse(cleanExpr);

    final context = ContextModel();

    // Add standard constants
    context.bindVariable(Variable('pi'), Number(dart_math.pi));
    context.bindVariable(Variable('e'), Number(dart_math.e));

    // Add user-provided values
    if (values != null) {
      for (final entry in values.entries) {
        context.bindVariable(Variable(entry.key), Number(entry.value));
      }
    }

    final result = parsed.evaluate(EvaluationType.REAL, context);
    return result.toDouble();
  }

  /// Evaluates a simple numeric expression (no variables).
  ///
  /// Example:
  /// ```dart
  /// Evaluator.evaluateNumeric('2 + 3 * 4'); // 14.0
  /// Evaluator.evaluateNumeric('sin(pi/2)'); // 1.0
  /// ```
  static double evaluateNumeric(String expression) {
    return evaluate(expression, {});
  }

  /// Checks if the expression can be evaluated with the given values.
  ///
  /// Returns `true` if evaluation succeeds, `false` otherwise.
  static bool canEvaluate(String expression, [Map<String, double>? values]) {
    try {
      evaluate(expression, values);
      return true;
    } catch (_) {
      return false;
    }
  }
}
