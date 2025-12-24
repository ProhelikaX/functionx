import 'dart:math' as dart_math;
import 'package:math_expressions/math_expressions.dart' as math hide Parser;
import 'package:petitparser/petitparser.dart';

/// A grammar for explicit algebraic equations that builds a [math.Expression] tree.
///
/// This grammar supports:
/// - Basic arithmetic: `+`, `-`, `*`, `/`, `^`
/// - Parentheses for grouping
/// - Standard math functions: `sin`, `cos`, `tan`, `sqrt`, `log`, `ln`, `exp`, `pow`, etc.
/// - Variables with optional subscripts: `x`, `v_0`, `m_1`
/// - Scientific notation: `1.5e-10`
/// - Mathematical constants: `pi`, `e`, `infinity`
///
/// Example usage:
/// ```dart
/// final grammar = ExpressionGrammar();
/// final parser = grammar.build();
/// final result = parser.parse('x^2 + 2*x + 1');
/// ```
class ExpressionGrammar extends GrammarDefinition {
  @override
  Parser start() => (ref0(equation) | ref0(expression)).end();

  /// Parses an equation in the form `LHS = RHS`.
  /// Returns a List: [leftExpression, '=', rightExpression]
  Parser equation() =>
      (ref0(expression) & char('=').trim() & ref0(expression)).map((values) {
        return values;
      });

  /// Top-level expression parser.
  Parser expression() => ref0(additive);

  /// Handles addition and subtraction (left-associative).
  Parser additive() =>
      (ref0(multiplicative) &
              (char('+').trim() & ref0(multiplicative) |
                      char('-').trim() & ref0(multiplicative))
                  .star())
          .map((values) {
            math.Expression left = values[0];
            final rest = values[1] as List;
            for (final item in rest) {
              final op = item[0] as String;
              final right = item[1] as math.Expression;
              if (op == '+') {
                left = math.Plus(left, right);
              } else if (op == '-') {
                left = math.Minus(left, right);
              }
            }
            return left;
          });

  /// Handles multiplication and division (left-associative).
  Parser multiplicative() =>
      (ref0(power) &
              (char('*').trim() & ref0(power) | char('/').trim() & ref0(power))
                  .star())
          .map((values) {
            math.Expression left = values[0];
            final rest = values[1] as List;
            for (final item in rest) {
              final op = item[0] as String;
              final right = item[1] as math.Expression;
              if (op == '*') {
                left = math.Times(left, right);
              } else if (op == '/') {
                left = math.Divide(left, right);
              }
            }
            return left;
          });

  /// Handles exponentiation (right-associative).
  Parser power() =>
      (ref0(unary) & (char('^').trim() & ref0(unary)).optional()).map((values) {
        math.Expression base = values[0];
        if (values[1] != null) {
          final exponent = values[1][1] as math.Expression;
          return math.Power(base, exponent);
        }
        return base;
      });

  /// Handles unary minus.
  Parser unary() =>
      (char('-').trim() & ref0(unary)).map((v) => math.UnaryMinus(v[1])) |
      ref0(primary);

  /// Primary expressions: functions, numbers, variables, or parenthesized expressions.
  Parser primary() =>
      ref0(functionCall) |
      ref0(number) |
      ref0(variable) |
      (char('(').trim() & ref0(expression) & char(')').trim()).map((v) => v[1]);

  /// Parses function calls like `sin(x)`, `pow(x, 2)`, `log(10, x)`.
  Parser functionCall() =>
      (ref0(identifier) &
              char('(').trim() &
              ref0(expression) &
              (char(',').trim() & ref0(expression)).star() &
              char(')').trim())
          .map((values) {
            final name = values[0] as String;
            final firstArg = values[2] as math.Expression;
            final otherArgs = (values[3] as List)
                .map((e) => e[1] as math.Expression)
                .toList();
            final args = [firstArg, ...otherArgs];

            switch (name) {
              case 'sin':
                return math.Sin(args[0]);
              case 'cos':
                return math.Cos(args[0]);
              case 'tan':
                return math.Tan(args[0]);
              case 'asin':
                return math.Asin(args[0]);
              case 'acos':
                return math.Acos(args[0]);
              case 'atan':
                return math.Atan(args[0]);
              case 'sqrt':
                return math.Sqrt(args[0]);
              case 'abs':
                return math.Abs(args[0]);
              case 'ln':
              case 'log':
                if (name == 'ln') return math.Ln(args[0]);
                if (args.length > 1) {
                  return math.Log(args[1], args[0]);
                }
                return math.Ln(args[0]);
              case 'exp':
                return math.Power(math.Number(dart_math.e), args[0]);
              case 'pow':
                if (args.length < 2) {
                  throw FormatException('pow() requires 2 arguments');
                }
                return math.Power(args[0], args[1]);
              default:
                throw FormatException('Unknown function: $name');
            }
          });

  /// Parses variable names with optional subscripts.
  /// Also handles mathematical constants: `pi`, `e`, `infinity`.
  Parser variable() => ref0(identifier).map((name) {
    if (name == 'pi') return math.Number(dart_math.pi);
    if (name == 'e') return math.Number(dart_math.e);
    if (name == 'infinity') return math.Number(double.infinity);
    return math.Variable(name);
  });

  /// Parses identifiers: starts with a letter, followed by letters, digits, or underscores.
  Parser identifier() =>
      (letter() & (word() | char('_') | digit()).star()).flatten();

  /// Parses numbers including decimals and scientific notation.
  Parser number() =>
      (char('-').optional() &
              digit().plus() &
              (char('.') & digit().plus()).optional() &
              (anyOf('eE') & anyOf('-+').optional() & digit().plus())
                  .optional())
          .flatten()
          .map((val) => math.Number(double.parse(val)));
}
