import 'package:math_expressions/math_expressions.dart' as math hide Parser;
import 'package:petitparser/petitparser.dart';
import 'grammar.dart';

/// Result of parsing an expression or equation.
class ParseResult {
  /// The parsed expression (for single expressions).
  final math.Expression? expression;

  /// For equations, the left-hand side expression.
  final math.Expression? left;

  /// For equations, the right-hand side expression.
  final math.Expression? right;

  /// Whether this is an equation (has `=` sign).
  final bool isEquation;

  const ParseResult._({
    this.expression,
    this.left,
    this.right,
    required this.isEquation,
  });

  /// Creates a result for a single expression.
  factory ParseResult.expression(math.Expression expr) {
    return ParseResult._(expression: expr, isEquation: false);
  }

  /// Creates a result for an equation.
  factory ParseResult.equation(math.Expression left, math.Expression right) {
    return ParseResult._(left: left, right: right, isEquation: true);
  }
}

/// A parser for mathematical expressions and equations.
///
/// This parser uses explicit operator notation (e.g., `2*x` not `2x`).
/// It builds an AST using the `math_expressions` package.
///
/// Example usage:
/// ```dart
/// // Parse and extract variables
/// final vars = ExpressionParser.extractVariables('y = m*x + b');
/// print(vars); // ['b', 'm', 'x', 'y']
///
/// // Parse into AST
/// final result = ExpressionParser.parse('x^2 + 2*x + 1');
/// ```
class ExpressionParser {
  static final _grammar = ExpressionGrammar();
  static final _parser = _grammar.build();

  /// Parses the input string into a [ParseResult].
  ///
  /// Returns a [ParseResult] containing either:
  /// - A single expression (if no `=` sign)
  /// - An equation with left and right sides
  ///
  /// Throws [FormatException] if parsing fails.
  static ParseResult parse(String input) {
    final result = _parser.parse(input.trim());
    if (result is Failure) {
      throw FormatException(
        'Parsing failed: ${result.message} at position ${result.position}',
      );
    }

    final value = result.value;
    if (value is List && value.length == 3 && value[1] == '=') {
      return ParseResult.equation(
        value[0] as math.Expression,
        value[2] as math.Expression,
      );
    }
    return ParseResult.expression(value as math.Expression);
  }

  /// Extracts all variable names from an expression or equation.
  ///
  /// Returns a sorted list of unique variable names.
  /// Mathematical constants (`pi`, `e`, `infinity`) are not included.
  ///
  /// Example:
  /// ```dart
  /// ExpressionParser.extractVariables('F = m*a'); // ['F', 'a', 'm']
  /// ExpressionParser.extractVariables('y = sin(x) + 2*pi'); // ['x', 'y']
  /// ```
  static List<String> extractVariables(String input) {
    try {
      final result = _parser.parse(input.trim());
      if (result is Failure) return [];

      final variables = <String>{};

      void collect(dynamic node) {
        if (node == null) return;

        if (node is math.Variable) {
          // Ignore placeholder variables
          if (node.name == 'anon') return;
          variables.add(node.name);
          return;
        }

        if (node is math.Number) return;

        if (node is math.BinaryOperator) {
          collect(node.first);
          collect(node.second);
          return;
        }

        if (node is math.UnaryOperator) {
          try {
            collect((node as dynamic).value);
          } catch (_) {}
          return;
        }

        // Handle functions (Sin, Cos, etc.)
        try {
          final args = (node as dynamic).args;
          if (args is List) {
            for (var arg in args) {
              collect(arg);
            }
            return;
          }
        } catch (_) {}

        try {
          final arg = (node as dynamic).arg;
          if (arg != null) {
            collect(arg);
            return;
          }
        } catch (_) {}
      }

      final value = result.value;
      if (value is List) {
        collect(value[0]);
        if (value.length > 2) collect(value[2]);
      } else {
        collect(value);
      }

      return variables.toList()..sort();
    } catch (e) {
      return [];
    }
  }
}
