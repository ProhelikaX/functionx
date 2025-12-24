import 'package:math_expressions/math_expressions.dart';
import 'complex.dart';
import 'dart:math' as math;

/// Evaluates math_expressions using Complex arithmetic.
class ComplexEvaluator {
  /// Evaluates the given [expression] with the provided variable [values].
  static Complex evaluate(Expression expression, Map<String, Complex> values) {
    if (expression is Number) {
      if (expression.value is num) {
        return Complex((expression.value as num).toDouble());
      }
      return Complex(0); // Should not happen for standard parsing
    }

    if (expression is Variable) {
      if (expression.name == 'anon') {
        try {
          return evaluate(_getArg(expression), values);
        } catch (_) {}
      }

      if (values.containsKey(expression.name)) {
        return values[expression.name]!;
      }
      // Check for constants (case-insensitive)
      final name = expression.name.toUpperCase();
      if (name == 'PI') return Complex(math.pi);
      if (name == 'E' || name == 'EN') return Complex(math.e);
      if (name == 'I' || name == 'IN') return Complex.i;
      if (name == 'INFINITY' || name == 'INF') return Complex(double.infinity);

      throw ArgumentError('Unknown variable: ${expression.name}');
    }

    if (expression is UnaryMinus) {
      return -evaluate(_getArg(expression), values);
    }

    // Binary Operators
    if (expression is Plus) {
      return evaluate(expression.first, values) +
          evaluate(expression.second, values);
    }
    if (expression is Minus) {
      return evaluate(expression.first, values) -
          evaluate(expression.second, values);
    }
    if (expression is Times) {
      return evaluate(expression.first, values) *
          evaluate(expression.second, values);
    }
    if (expression is Divide) {
      return evaluate(expression.first, values) /
          evaluate(expression.second, values);
    }
    if (expression is Power) {
      return evaluate(
        expression.first,
        values,
      ).pow(evaluate(expression.second, values));
    }

    // Functions - Use dynamic casting for arg to handle different class structures safely
    // (e.g. UnaryExpression vs SingleArgumentFunction)

    if (expression is Sin) {
      return evaluate(_getArg(expression), values).sin();
    }
    if (expression is Cos) {
      return evaluate(_getArg(expression), values).cos();
    }
    if (expression is Tan) {
      return evaluate(_getArg(expression), values).tan();
    }
    if (expression is Exponential) {
      // e^x
      return evaluate(_getArg(expression), values).exp();
    }
    if (expression is Ln) {
      // Natural log
      return evaluate(_getArg(expression), values).log();
    }
    if (expression is Log) {
      // Log base x
      // Standard math_expressions Logarithm(base, x).
      final args = _getArgs(expression);
      if (args.length == 2) {
        return evaluate(args[1], values).log() /
            evaluate(args[0], values).log();
      }
      // Fallback for single arg log (base 10 usually)
      return evaluate(args[0], values).log() / Complex(math.ln10);
    }
    if (expression is Sqrt) {
      return evaluate(_getArg(expression), values).sqrt();
    }
    if (expression is Root) {
      // Root(degree, radicand) -> radicand^(1/degree)
      final base = evaluate((expression as dynamic).base, values);
      final r = evaluate((expression as dynamic).exp, values);
      return r.pow(Complex.one / base);
    }
    if (expression is Abs) {
      return Complex(evaluate(_getArg(expression), values).abs());
    }

    if (expression is Asin) {
      return _asin(evaluate(_getArg(expression), values));
    }
    if (expression is Acos) {
      return _acos(evaluate(_getArg(expression), values));
    }
    if (expression is Atan) {
      return _atan(evaluate(_getArg(expression), values));
    }

    // Handle generic Function nodes or Parenthesis if they exist
    try {
      return evaluate(_getArg(expression), values);
    } catch (_) {}

    // Last resort fallback: if it's a known math_expressions node but unknown to us,
    // we can't easily evaluate it as complex without specific logic.
    throw UnimplementedError(
      'Expression type ${expression.runtimeType} not supported in ComplexEvaluator: $expression',
    );
  }

  // Inverse Trig Functions (Complex formulas)

  static Complex _asin(Complex z) {
    // asin(z) = -i * log(iz + sqrt(1 - z^2))
    final i = Complex.i;
    final term = (i * z) + (Complex.one - (z * z)).sqrt();
    return -i * term.log();
  }

  static Complex _acos(Complex z) {
    // acos(z) = -i * log(z + i * sqrt(1 - z^2))
    final i = Complex.i;
    final term = z + (i * (Complex.one - (z * z)).sqrt());
    return -i * term.log();
  }

  static Complex _atan(Complex z) {
    // atan(z) = (i/2) * log((1-iz)/(1+iz))
    final i = Complex.i;
    final t1 = Complex.one - (i * z);
    final t2 = Complex.one + (i * z);
    return (i / 2) * (t1 / t2).log();
  }

  static Expression _getArg(Expression node) {
    try {
      return (node as dynamic).exp;
    } catch (_) {}
    try {
      return (node as dynamic).arg;
    } catch (_) {}
    try {
      return (node as dynamic).expression;
    } catch (_) {}
    try {
      return (node as dynamic).first;
    } catch (_) {}
    try {
      return (node as dynamic).value;
    } catch (_) {}
    try {
      return (node as dynamic).inner;
    } catch (_) {}
    try {
      return (node as dynamic).args[0];
    } catch (_) {}

    throw ArgumentError(
      'Could not find argument for expression $node (${node.runtimeType})',
    );
  }

  static List<Expression> _getArgs(Expression node) {
    try {
      final args = (node as dynamic).args;
      if (args is List<Expression>) return args;
    } catch (_) {}
    try {
      // For Logarithm often it has base and exp
      final base = (node as dynamic).base as Expression;
      final radicand = (node as dynamic).exp as Expression;
      return [base, radicand];
    } catch (_) {}
    try {
      return [_getArg(node)];
    } catch (_) {}
    return [];
  }
}
