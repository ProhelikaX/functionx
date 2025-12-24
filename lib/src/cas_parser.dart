import 'package:math_expressions/math_expressions.dart';

class CasParser {
  static final Parser _parser = Parser();

  /// Evaluates specific CAS commands like derivative and integral.
  /// Returns the LaTeX result or the simplified expression string.
  static String solve(String equation) {
    // Handle equations (LHS = RHS)
    if (equation.contains('=')) {
      final parts = equation.split('=');
      return parts.map((part) => solve(part.trim())).join(' = ');
    }

    // 1. Check for derivative: d/dx(...) or diff(..., x)
    // 2. Check for integral: int(...) or integrate(..., x)

    try {
      if (equation.startsWith('d/d')) {
        return _handleDerivative(equation);
      } else if (equation.startsWith('int') || equation.contains('integrate')) {
        return _handleIntegral(equation);
      }

      // Default: Simplify
      Expression exp = _parser.parse(equation);

      Expression simplified = exp.simplify();
      return simplified.toString();
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  static String _handleDerivative(String input) {
    // Format: d/dx(expression) or d/dt(expression)
    final varMatch = RegExp(r'd/d([a-z])\((.*)\)').firstMatch(input);
    if (varMatch != null) {
      String variable = varMatch.group(1)!;
      String expressionStr = varMatch.group(2)!;

      try {
        Expression exp = _parser.parse(expressionStr);
        Expression derived = exp.derive(variable);
        Expression simplified = derived.simplify();
        return simplified.toString();
      } catch (e) {
        return 'Derivative Error: $e';
      }
    }
    return 'Invalid derivative format';
  }

  static String _handleIntegral(String input) {
    String expressionStr;
    String variable = 'x';

    // Regex for int(expression)dx or int(expression)dt
    final fullPattern = RegExp(r'int\((.+)\)d([a-zA-Z])');
    final match = fullPattern.firstMatch(input);

    if (match != null) {
      expressionStr = match.group(1)!.trim();
      variable = match.group(2)!;
    } else {
      // Fallback: try to just separate int(...)
      final simplePattern = RegExp(r'(?:int|integrate)\((.+)\)');
      final simpleMatch = simplePattern.firstMatch(input);
      if (simpleMatch != null) {
        expressionStr = simpleMatch.group(1)!.trim();
      } else {
        return 'Invalid integral format';
      }
    }

    try {
      Expression exp = _parser.parse(expressionStr);
      exp = exp.simplify();

      // Pattern matching integration
      if (exp is Variable) {
        if (exp.name == variable) {
          return '0.5*$variable^2';
        }
      } else if (exp is Number) {
        return '$exp*$variable';
      }
      // Handle Power: x^n -> x^(n+1)/(n+1)
      if (exp is Power) {
        if (exp.first is Variable &&
            (exp.first as Variable).name == variable &&
            exp.second is Number) {
          double n = (exp.second as Number).value.toDouble();
          if (n == -1) return 'ln($variable)';
          return '(${variable}^${n + 1})/${n + 1}';
        }
      }

      // Handle Trig
      String s = exp.toString();
      if (s == 'sin($variable)') return '-cos($variable)';
      if (s == 'cos($variable)') return 'sin($variable)';

      return 'Integral of $s not strictly supported yet.';
    } catch (e) {
      return 'Integration Error: ${e.toString()}';
    }
  }
}
