import 'dart:math' as dart_math;
import 'package:math_expressions/math_expressions.dart' as math hide Parser;
import 'package:petitparser/petitparser.dart';

/// A grammar for explicit algebraic equations that builds a [math.Expression] tree.
class EquationGrammarDefinition extends GrammarDefinition {
  @override
  Parser start() => (ref0(equation) | ref0(expression)).end();

  // Returns [math.Expression left, =, math.Expression right]
  Parser equation() =>
      (ref0(expression) & char('=').trim() & ref0(expression)).map((values) {
        return values;
      });

  Parser expression() => ref0(additive);

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

  Parser multiplicative() =>
      (ref0(power) &
              ((char('*').trim() | char('/').trim()) & ref0(power)).star())
          .map((values) {
            math.Expression left = values[0];
            final rest = values[1] as List;
            for (final item in rest) {
              final op = item[0] as String;
              final right = item[1] as math.Expression;
              if (op == '*') left = math.Times(left, right);
              if (op == '/') left = math.Divide(left, right);
            }
            return left;
          });

  Parser power() =>
      (ref0(unary) & (char('^').trim() & ref0(unary)).optional()).map((values) {
        math.Expression base = values[0];
        if (values[1] != null) {
          final exponent = values[1][1] as math.Expression;
          return math.Power(base, exponent);
        }
        return base;
      });

  Parser unary() =>
      (char('-').trim() & ref0(unary)).map((v) => math.UnaryMinus(v[1])) |
      ref0(primary);

  Parser primary() =>
      ref0(functionCall) |
      ref0(number) |
      ref0(variable) |
      (char('(').trim() & ref0(expression) & char(')').trim()).map((v) => v[1]);

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

            // Standard math functions
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
                // Handle log(x) as Ln(x)
                if (name == 'ln') return math.Ln(args[0]);
                if (args.length > 1) {
                  return math.Log(args[1], args[0]);
                }
                return math.Ln(args[0]);
              case 'exp':
                return math.Power(math.Number(dart_math.e), args[0]);
              case 'pow':
                return math.Power(args[0], args[1]);
              default:
                throw FormatException('Unknown function: $name');
            }
          });

  Parser variable() => ref0(identifier).map((name) {
    if (name == 'PI') return math.Variable('PI');
    if (name == 'EN') return math.Variable('EN');
    if (name == 'INF') return math.Variable('INF');
    if (name == 'i') return math.Variable('IN');
    return math.Variable(name);
  });

  Parser identifier() =>
      (letter() & (word() | char('_') | digit()).star()).flatten();

  Parser number() =>
      (char('-').optional() &
              digit().plus() &
              (char('.') & digit().plus()).optional() &
              (anyOf('eE') & anyOf('-+').optional() & digit().plus())
                  .optional())
          .flatten()
          .map((val) => math.Number(double.parse(val)));
}
