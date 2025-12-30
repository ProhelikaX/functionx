import 'dart:math' as dart_math;
import 'package:math_expressions/math_expressions.dart';
import 'complex.dart';
import 'complex_evaluator.dart';
import '../explicit_parser.dart';

/// Evaluates mathematical expressions with given variable values.
///
/// Example usage:
/// ```dart
/// final result = Evaluator.evaluate('x^2 + 2*x + 1', {'x': 3});
/// print(result); // 16.0
/// ```
class Evaluator {
  // We use ExplicitEquationParser which uses our custom grammar

  /// Evaluates an expression string with the given variable values.
  ///
  /// [expression] - The mathematical expression to evaluate.
  /// [values] - Map of variable names to their numeric values.
  ///
  /// Returns the computed numeric result.
  /// Throws [FormatException] if the expression cannot be parsed.
  /// Throws [ArgumentError] if required variables are missing.
  static double evaluate(String expression, [Map<String, dynamic>? values]) {
    final cleanExpr = expression.trim();
    final parsedResult = ExplicitEquationParser.parse(cleanExpr);
    final Expression parsed = parsedResult is List
        ? parsedResult[0]
        : parsedResult;

    final context = ContextModel();

    // Add standard constants (handled by ExplicitEquationParser mapping or logic)
    // and manually here for Standard evaluation mode
    context.bindVariable(Variable('PI'), Number(dart_math.pi));
    context.bindVariable(Variable('EN'), Number(dart_math.e));
    context.bindVariable(Variable('INF'), Number(double.infinity));

    // Add user-provided values
    if (values != null) {
      for (final entry in values.entries) {
        final val = entry.value;
        if (val is num) {
          context.bindVariable(Variable(entry.key), Number(val.toDouble()));
        } else if (val is Complex) {
          // Warning: REAL evaluation mode might not handle Complex variables well unless they are real-valued?
          // Actually math_expressions expects Number/Vector/etc.
          // If we pass Complex, standard evaluate might crash or unexpected behavior.
          // For now, if it's real, pass double. If complex, pass NaN?
          // Or just don't support Complex in 'evaluate' (use 'evaluateMixed').
          if (val.isReal) {
            context.bindVariable(Variable(entry.key), Number(val.real));
          } else {
            context.bindVariable(Variable(entry.key), Number(double.nan));
          }
        }
      }
    }

    // Use Expression.evaluate with ignore as RealEvaluator API is not fully clear/compatible in this version
    // ignore: deprecated_member_use
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

  /// Evaluates expression returning either double (if real) or Complex (if imaginary).
  static dynamic evaluateMixed(
    String expression, [
    Map<String, dynamic>? values,
  ]) {
    final cleanExpr = expression.trim();
    final parsedResult = ExplicitEquationParser.parse(cleanExpr);
    final Expression parsed = parsedResult is List
        ? parsedResult.last
        : parsedResult;

    // Prepare Complex context
    final complexValues = <String, Complex>{};
    if (values != null) {
      values.forEach((key, value) {
        if (value is num) {
          complexValues[key] = Complex(value.toDouble());
        } else if (value is Complex) {
          complexValues[key] = value;
        } else {
          // Try to parse string or null
          complexValues[key] = Complex(0); // Default/Error handling
        }
      });
    }

    try {
      // Use ComplexEvaluator
      final result = ComplexEvaluator.evaluate(parsed, complexValues);

      // If imaginary part is negligible, return double
      if (result.imaginary.abs() < 1e-15) {
        return result.real;
      }
      return result;
    } catch (e) {
      // Fallback or rethrow
      rethrow;
    }
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
