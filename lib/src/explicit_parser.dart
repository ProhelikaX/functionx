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
    // try {
    final parsed = parse(input);
    final variables = <String>{};

    final visited = <dynamic>{};
    void collect(dynamic node) {
      if (node == null) return;
      if (visited.contains(node)) return;
      visited.add(node);

      if (node is List) {
        for (final item in node) collect(item);
        return;
      }

      try {
        if (node is math.Variable) {
          // 'anon' is used for bound variables that wrap expressions; we must descend into them.
          if (node.name != 'anon') {
            variables.add(node.name);
          }
        }
      } catch (_) {}

      if (node is math.Number) return;

      // Try 'args' first
      try {
        final args = (node as dynamic).args;
        if (args is List && args.isNotEmpty) {
          for (var a in args) collect(a);
          // Don't return, allow fallbacks
        }
      } catch (_) {}

      // Fallback: Exhaustive property search for children
      try {
        collect((node as dynamic).first);
      } catch (_) {}
      try {
        collect((node as dynamic).second);
      } catch (_) {}
      try {
        collect((node as dynamic).arg);
      } catch (_) {}
      try {
        collect((node as dynamic).exp);
      } catch (_) {}
      try {
        collect((node as dynamic).expression);
      } catch (_) {}
      try {
        collect((node as dynamic).value);
      } catch (_) {}
      try {
        collect((node as dynamic).base);
      } catch (_) {}
      try {
        collect((node as dynamic).left);
      } catch (_) {}
      try {
        collect((node as dynamic).right);
      } catch (_) {}
      try {
        collect((node as dynamic).exponent);
      } catch (_) {}

      // Hack for BoundVariable which hides contents in toString
      // Some versions of math_expressions wrap content in BoundVariable with name 'anon'.
      try {
        final str = node.toString();
        if (str.startsWith('{') && str.endsWith('}')) {
          final inner = str.substring(1, str.length - 1);
          if (inner.trim().isNotEmpty && inner != 'anon') {
            variables.addAll(ExplicitEquationParser.extractVariables(inner));
          }
        }
      } catch (_) {}
    }

    collect(parsed);

    return variables.toList()..sort();
    // } catch (e) {
    //   return [];
    // }
  }
}
