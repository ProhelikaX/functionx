import 'package:math_expressions/math_expressions.dart' as math hide Parser;
import 'package:petitparser/petitparser.dart';
import 'equation_grammar.dart';

class ExplicitEquationParser {
  static final _definition = EquationGrammarDefinition();
  static final _parser = _definition.build();

  /// Parses the input string into a MathExpression or a List for equation.
  static dynamic parse(String input) {
    final result = _parser.parse(input.trim());
    if (result is Failure) {
      throw FormatException(
        'Parsing failed: ${result.message} at ${result.position}',
      );
    }
    return result.value;
  }

  /// Extracts variable names from the equation.
  static List<String> extractVariables(String input) {
    try {
      final parsed = parse(input);
      final variables = <String>{};

      void collect(dynamic node) {
        if (node == null) return;

        if (node is math.Variable) {
          if (node.name == 'anon')
            return; // Ignore phantom/placeholder variables
          variables.add(node.name);
          return;
        }
        if (node is math.Number) {
          return;
        }

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

        // Generic fallback for Functions (Sin, Cos, Log, etc.)
        // which might not correspond to exported types like 'Function' or 'UnaryFunction'
        try {
          // Try 'args' list (standard Function)
          final args = (node as dynamic).args;
          if (args is List) {
            for (var arg in args) collect(arg);
            return;
          }
        } catch (_) {}

        try {
          // Try 'arg' (UnaryFunction like Sin)
          final arg = (node as dynamic).arg;
          if (arg != null) {
            collect(arg);
            return;
          }
        } catch (_) {}
      }

      if (parsed is List) {
        // Equation [LHS, =, RHS]
        collect(parsed[0]);
        if (parsed.length > 2) collect(parsed[2]);
      } else {
        collect(parsed);
      }

      return variables.toList()..sort();
    } catch (e) {
      return [];
    }
  }
}
