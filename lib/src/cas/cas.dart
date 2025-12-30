import 'package:math_expressions/math_expressions.dart';

/// Computer Algebra System (CAS) for symbolic mathematics.
///
/// Supports:
/// - Symbolic differentiation: `d/dx(x^2)` → `2*x`
/// - Symbolic integration: `int(x)dx` → `0.5*x^2`
/// - Expression simplification
///
/// Example usage:
/// ```dart
/// // Differentiation
/// final result = Cas.differentiate('x^2', 'x');
/// print(result); // '2.0 * x'
///
/// // Integration
/// final result = Cas.integrate('x', 'x');
/// print(result); // '0.5*x^2'
/// ```
class Cas {
  static final GrammarParser _parser = GrammarParser();

  /// Computes the symbolic derivative of an expression.
  ///
  /// [expression] - The mathematical expression to differentiate.
  /// [variable] - The variable to differentiate with respect to.
  ///
  /// Returns the derivative as a string.
  static String differentiate(String expression, String variable) {
    try {
      Expression exp = _parser.parse(expression);
      Expression derived = exp.derive(variable);
      Expression simplified = derived.simplify();
      return simplified.toString();
    } catch (e) {
      throw FormatException('Differentiation failed: $e');
    }
  }

  /// Computes the symbolic integral of an expression.
  ///
  /// [expression] - The mathematical expression to integrate.
  /// [variable] - The variable to integrate with respect to.
  ///
  /// Note: Integration support is limited to common patterns.
  /// Returns the integral as a string, or throws if unsupported.
  static String integrate(String expression, String variable) {
    try {
      Expression exp = _parser.parse(expression);
      exp = exp.simplify();

      // Pattern matching for common integrals
      if (exp is Variable) {
        if (exp.name == variable) {
          return '0.5*$variable^2';
        }
        // Constant with respect to variable
        return '${exp.name}*$variable';
      }

      if (exp is Number) {
        return '${exp.value}*$variable';
      }

      // Handle Power: x^n -> x^(n+1)/(n+1)
      if (exp is Power) {
        if (exp.first is Variable &&
            (exp.first as Variable).name == variable &&
            exp.second is Number) {
          double n = (exp.second as Number).value.toDouble();
          if (n == -1) return 'ln($variable)';
          return '($variable^${n + 1})/${n + 1}';
        }
      }

      // Handle common trig functions
      String s = exp.toString();
      if (s == 'sin($variable)') return '-cos($variable)';
      if (s == 'cos($variable)') return 'sin($variable)';
      if (s == 'exp($variable)') return 'exp($variable)';

      throw FormatException('Integral of $s is not supported');
    } catch (e) {
      if (e is FormatException) rethrow;
      throw FormatException('Integration failed: $e');
    }
  }

  /// Simplifies a mathematical expression.
  ///
  /// [expression] - The expression to simplify.
  ///
  /// Returns the simplified expression as a string.
  static String simplify(String expression) {
    try {
      Expression exp = _parser.parse(expression);
      Expression simplified = exp.simplify();
      return simplified.toString();
    } catch (e) {
      throw FormatException('Simplification failed: $e');
    }
  }

  /// Evaluates CAS commands in various formats.
  ///
  /// Supported formats:
  /// - `d/dx(expression)` - Differentiation
  /// - `int(expression)dx` - Integration
  /// - Plain expression - Simplification
  static String evaluate(String input) {
    // Handle equations (LHS = RHS)
    if (input.contains('=')) {
      final parts = input.split('=');
      return parts.map((part) => evaluate(part.trim())).join(' = ');
    }

    // Derivative: d/dx(...)
    if (input.startsWith('d/d')) {
      final match = RegExp(r'd/d([a-z])\((.+)\)').firstMatch(input);
      if (match != null) {
        return differentiate(match.group(2)!, match.group(1)!);
      }
      throw FormatException('Invalid derivative format');
    }

    // Integral: int(...)dx
    if (input.startsWith('int') || input.contains('integrate')) {
      final fullMatch = RegExp(r'int\((.+)\)d([a-zA-Z])').firstMatch(input);
      if (fullMatch != null) {
        return integrate(fullMatch.group(1)!, fullMatch.group(2)!);
      }
      final simpleMatch = RegExp(r'int\((.+)\)').firstMatch(input);
      if (simpleMatch != null) {
        return integrate(simpleMatch.group(1)!, 'x');
      }
      throw FormatException('Invalid integral format');
    }

    // Default: Simplify
    return simplify(input);
  }
}
