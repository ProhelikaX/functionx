import 'dart:math' as math;
import 'package:petitparser/petitparser.dart';

/// A structured result from solving an equation
class SolvingResult {
  /// The final computed value for the unknown variable, if any
  final double? solvedValue;

  /// Human-readable steps of the solution (may contain placeholders for localization)
  final List<SolvingStep> steps;

  /// Any error message during solving
  final String? error;

  SolvingResult({this.solvedValue, this.steps = const [], this.error});
}

/// A single step in the solution process
class SolvingStep {
  final String type; // e.g., 'substitution', 'solving_for', 'result', 'error'
  final Map<String, dynamic> data;

  SolvingStep({required this.type, required this.data});
}

/// A parser and solver for mathematical equations, particularly LaTeX
class MathEquationParser {
  static final Parser<double> _parser = _buildParser();

  static Parser<double> _buildParser() {
    final builder = ExpressionBuilder<double>();

    final number =
        ((digit().plus() &
                    (char('.') & digit().plus()).optional() &
                    (pattern('eE') & pattern('+-').optional() & digit().plus())
                        .optional()) |
                (char('.') &
                    digit().plus() &
                    (pattern('eE') & pattern('+-').optional() & digit().plus())
                        .optional()))
            .flatten()
            .trim()
            .map(double.tryParse)
            .where((value) => value != null)
            .map((value) => value!);

    final constants =
        (string('Infinity').trim().map((_) => double.infinity) |
                string('pi').trim().map((_) => math.pi) |
                string('e').trim().map((_) => math.e))
            .cast<double>();

    // Support for variables like x, v_0, F_{net}
    final variableName =
        (letter().plus() &
                (char('_') &
                        (char('{') & pattern('^}').plus() & char('}') |
                            digit().plus() |
                            letter().plus()))
                    .optional())
            .flatten()
            .trim();

    final loopback = builder.loopback;

    final functionCall =
        (variableName &
                char('(').trim() &
                loopback.starSeparated(char(',').trim()) &
                char(')').trim())
            .map((values) {
              final String name = values[0];
              final SeparatedList<double, void> list = values[2];
              final args = list.elements;

              switch (name.toLowerCase()) {
                case 'sqrt':
                  return math.sqrt(args.isNotEmpty ? args[0] : 0.0);
                case 'pow':
                  return math
                      .pow(
                        args.isNotEmpty ? args[0] : 0.0,
                        args.length > 1 ? args[1] : 2.0,
                      )
                      .toDouble();
                case 'sin':
                  return math.sin(args.isNotEmpty ? args[0] : 0.0);
                case 'cos':
                  return math.cos(args.isNotEmpty ? args[0] : 0.0);
                case 'tan':
                  return math.tan(args.isNotEmpty ? args[0] : 0.0);
                case 'asin':
                case 'arcsin':
                  return math.asin(args.isNotEmpty ? args[0] : 0.0);
                case 'acos':
                case 'arccos':
                  return math.acos(args.isNotEmpty ? args[0] : 0.0);
                case 'atan':
                case 'arctan':
                  return math.atan(args.isNotEmpty ? args[0] : 0.0);
                case 'log':
                case 'log10':
                  return math.log(args.isNotEmpty ? args[0] : 1.0) / math.ln10;
                case 'ln':
                  return math.log(args.isNotEmpty ? args[0] : 1.0);
                case 'exp':
                  return math.exp(args.isNotEmpty ? args[0] : 0.0);
                case 'abs':
                  return args.isNotEmpty ? args[0].abs() : 0.0;
                default:
                  return double.nan;
              }
            });

    // Order matters: function calls and complex variables before simple variables
    builder.primitive(functionCall);
    builder.primitive(constants);
    builder.primitive(number);
    builder.primitive(variableName.map((_) => double.nan));

    builder.group().wrapper(char('(').trim(), char(')').trim(), (l, v, r) => v);

    // Power (right-associative)
    builder.group()
      ..right(char('^').trim(), (a, op, b) => math.pow(a, b).toDouble());

    // Negation and positive sign
    builder.group()
      ..prefix(char('-').trim(), (op, a) => -a)
      ..prefix(char('+').trim(), (op, a) => a);

    // Multiplication and Division
    builder.group()
      ..left(char('*').trim(), (a, op, b) => a * b)
      ..left(char('/').trim(), (a, op, b) => a / b);

    // Addition and Subtraction
    builder.group()
      ..left(char('+').trim(), (a, op, b) => a + b)
      ..left(char('-').trim(), (a, op, b) => a - b);

    return builder.build().end();
  }

  /// Extracts variable names from a LaTeX equation
  static List<String> extractVariables(String latex) {
    final variables = <String>{};

    // LaTeX commands to exclude (functions, operators, etc.)
    final excludedCommands = {
      'sin',
      'cos',
      'tan',
      'cot',
      'sec',
      'csc',
      'arcsin',
      'arccos',
      'arctan',
      'sinh',
      'cosh',
      'tanh',
      'log',
      'ln',
      'exp',
      'lg',
      'sqrt',
      'frac',
      'sum',
      'prod',
      'int',
      'lim',
      'max',
      'min',
      'sup',
      'inf',
      'text',
      'textbf',
      'textit',
      'mathrm',
      'mathbf',
      'mathit',
      'times',
      'div',
      'cdot',
      'pm',
      'mp',
      'le',
      'ge',
      'ne',
      'lt',
      'gt',
      'leq',
      'geq',
      'neq',
      'approx',
      'equiv',
      'sim',
      'propto',
      'infty',
      'partial',
      'nabla',
      'forall',
      'exists',
      'in',
      'notin',
      'ni',
      'subset',
      'subseteq',
      'supset',
      'supseteq',
      'cup',
      'cap',
      'setminus',
      'emptyset',
      'varnothing',
      'mathbb',
      'mathcal',
      'mathfrak',
      'left',
      'right',
      'big',
      'Big',
      'bigg',
      'Bigg',
      'begin',
      'end',
      'bmatrix',
      'pmatrix',
      'vmatrix',
      'over',
      'atop',
      'choose',
      'to',
      'rightarrow',
      'leftarrow',
      'Rightarrow',
      'Leftarrow',
      'quad',
      'qquad',
      'hspace',
      'vspace',
    };

    int i = 0;
    while (i < latex.length) {
      final char = latex[i];

      if (char == '\\') {
        i++;
        String cmd = '';
        while (i < latex.length && RegExp(r'[a-zA-Z]').hasMatch(latex[i])) {
          cmd += latex[i];
          i++;
        }

        if (cmd == 'text' || cmd == 'mathrm') {
          // Skip the entire braced block for text/units
          if (i < latex.length && latex[i] == '{') {
            int depth = 1;
            i++;
            while (i < latex.length && depth > 0) {
              if (latex[i] == '{') depth++;
              if (latex[i] == '}') depth--;
              i++;
            }
          }
        }
        continue;
      }

      if (char == '_') {
        i++;
        if (i < latex.length && latex[i] == '{') {
          int depth = 1;
          i++;
          while (i < latex.length && depth > 0) {
            if (latex[i] == '{') depth++;
            if (latex[i] == '}') depth--;
            i++;
          }
        } else {
          i++;
        }
        continue;
      }

      if (RegExp(r'[a-zA-Z]').hasMatch(char)) {
        String word = char;
        int j = i + 1;
        while (j < latex.length && RegExp(r'[a-zA-Z]').hasMatch(latex[j])) {
          word += latex[j];
          j++;
        }

        if (excludedCommands.contains(word.toLowerCase())) {
          i = j;
          continue;
        }

        // Check for function usage
        int nextNonSpace = j;
        while (nextNonSpace < latex.length && latex[nextNonSpace] == ' ') {
          nextNonSpace++;
        }

        bool isFunction = false;
        String nextChar = '';
        if (nextNonSpace < latex.length) {
          nextChar = latex[nextNonSpace];
          if (nextChar == '(' || nextChar == "'" || nextChar == '^') {
            isFunction = true;
          }
        }

        // If it looks like a function call (e.g. f(x)) but checking for power (x^2) which is allowed variable usage
        if (!isFunction || nextChar == '^') {
          if (word.length > 2) {
            variables.add(word);
          } else {
            for (int k = 0; k < word.length; k++) {
              variables.add(word[k]);
            }
          }
          i = j;
        } else {
          i = j;
        }
        continue;
      }

      i++;
    }

    final subscriptPattern = RegExp(
      r'([a-zA-Z])\}?_(?:\{([^}]+)\}|([a-zA-Z0-9]))',
    );
    for (final match in subscriptPattern.allMatches(latex)) {
      final base = match.group(1);
      final subscript = match.group(2) ?? match.group(3);
      if (base != null && subscript != null) {
        int basePos = match.start;
        bool isCommand = false;
        int k = basePos - 1;
        while (k >= 0 && RegExp(r'[a-zA-Z]').hasMatch(latex[k])) {
          k--;
        }
        if (k >= 0 && latex[k] == '\\') {
          isCommand = true;
        }
        if (isCommand) continue;

        final matchStart = match.start;
        if (matchStart >= 4) {
          final prefix = latex.substring(matchStart - 4, matchStart);
          if (prefix == '\\lim' || prefix.endsWith('lim_')) {
            continue;
          }
        }
        if (subscript == '0' && (base == 'h' || base == 'n' || base == 'x')) {
          if (latex.contains(r'\lim') || latex.contains(r'\to')) {
            continue;
          }
        }

        // Also remove the base
        variables.remove(base);
        variables.add('${base}_$subscript');
      }
    }

    final greekPattern = RegExp(
      r'\\(theta|alpha|beta|gamma|delta|epsilon|lambda|mu|sigma|omega|phi|psi|rho|tau|eta|nu|xi|zeta|kappa|chi|Gamma|Delta|Theta|Lambda|Xi|Pi|Sigma|Phi|Psi|Omega)(?![a-zA-Z])',
    );
    for (final match in greekPattern.allMatches(latex)) {
      final greek = match.group(1);
      if (greek != null) {
        variables.add('\\$greek');
      }
    }

    if (latex.contains(r'\lim')) {
      final limSubPattern = RegExp(r'\\lim_\{?([a-zA-Z])\\?to');
      for (final match in limSubPattern.allMatches(latex)) {
        final limitVar = match.group(1);
        if (limitVar != null) {
          variables.remove(limitVar);
        }
      }
    }

    // Filter out common unit letters if they are likely just units
    // e.g. 'm', 's', 'kg' often appear in results
    final result = variables.toList()..sort();
    final commonUnits = {
      'm',
      's',
      'kg',
      'N',
      'J',
      'W',
      'V',
      'A',
      'K',
      'Pa',
      'Hz',
    };
    return result.where((v) {
      if (commonUnits.contains(v)) {
        // If it's a single letter and at the very end or after a result, it's likely a unit
        // For now, only remove if it's precisely one of these and not used as a variable in the prompt
        // But since we don't know the prompt, we'll be conservative.
        // Actually, if it's 'm' or 's' and there's a lot of other stuff, it's usually units.
        // I'll leave them for now unless they are inside \text which we now skip.
      }
      return true;
    }).toList();
  }

  /// Evaluates or solves the given LaTeX equation
  static SolvingResult solve(
    String latex,
    Map<String, double> values, {
    String? solveFor,
  }) {
    try {
      final steps = <SolvingStep>[];
      double? solvedValue;

      // Clean up the LaTeX
      String expr = latex
          .replaceAll(r'\times', '*')
          .replaceAll(r'\cdot', '*')
          .replaceAll(r'\div', '/')
          .replaceAll(r'\pm', '+')
          .replaceAll(r'\mp', '-')
          .replaceAll(r'\left', '')
          .replaceAll(r'\right', '')
          .replaceAll(r'\,', '')
          .replaceAll(r'\ ', '')
          .replaceAll(' ', '');

      expr = expr.replaceAll(RegExp(r'\\lim_\{[^}]*\}'), '');
      expr = expr.replaceAll(RegExp(r'\\lim'), '');
      expr = expr.replaceAll(r'\to', '');
      expr = expr.replaceAll(r'\rightarrow', '');
      expr = expr.replaceAll(r'\infty', 'Infinity');
      expr = expr.replaceAll(r'\approx', '=');
      expr = expr.replaceAll(r'\cong', '=');
      expr = expr.replaceAll(r'\doteq', '=');
      // Replace other approx symbols if any
      expr = expr.replaceAll('≈', '=');

      expr = expr.replaceAll(r'\displaystyle', '');
      expr = expr.replaceAll(r'\textstyle', '');
      expr = expr.replaceAll(r'\scriptstyle', '');
      expr = expr.replaceAll(r'\scriptscriptstyle', '');

      // Use balanced brace replacement for style and structural commands
      expr = _replaceLatexCommand(expr, 'mathrm', 1);
      expr = _replaceLatexCommand(expr, 'mathbf', 1);
      expr = _replaceLatexCommand(expr, 'mathit', 1);
      expr = _replaceLatexCommand(expr, 'text', 1);

      // Strip functional notation from the target variable if it's the LHS
      // e.g. g(r) = ... => g = ...
      // Do this EARLY before any other complex transformations
      if (solveFor != null) {
        final funcPat = RegExp(
          '^' + RegExp.escape(solveFor) + r'\([^)]+\)([=≈])',
        );
        expr = expr.replaceFirstMapped(
          funcPat,
          (m) => '$solveFor${m.group(1)}',
        );
      }

      expr = _replaceLatexCommand(expr, 'vec', 1);
      expr = _replaceLatexCommand(expr, 'hat', 1); // Unit vector
      expr = _replaceLatexCommand(expr, 'tilde', 1);
      expr = _replaceLatexCommand(expr, 'bar', 1);
      expr = _replaceLatexCommand(expr, 'dot', 1);
      expr = _replaceLatexCommand(expr, 'ddot', 1);

      // Use balanced brace replacement for common LaTeX commands
      expr = _replaceLatexCommand(expr, 'frac', 2);
      expr = _replaceLatexCommand(expr, 'sqrt', 1);

      // Support powers with balanced braces and robust base detection
      // Base can be a number, a variable (with subscript), or a parenthesized expression
      const basePattern =
          r'(?:\d+(?:\.\d*)?|[a-zA-Z](?:_\{[^}]+\}|_[a-zA-Z0-9]+)?|\([^)]+\))';

      // 1. Braced powers: base^{exp}
      // We need to handle nested braces in exp if any, though rare.
      // For now, solve outer powers by working through the string.
      int powIdx = 0;
      while ((powIdx = expr.indexOf('^', powIdx)) != -1) {
        if (powIdx + 1 < expr.length && expr[powIdx + 1] == '{') {
          final closeIdx = _findClosingBrace(expr, powIdx + 1);
          if (closeIdx != -1) {
            final exp = expr.substring(powIdx + 2, closeIdx);
            // Identify base by looking back from powIdx
            final before = expr.substring(0, powIdx);
            final match = RegExp('$basePattern\$').firstMatch(before);
            if (match != null) {
              final base = match.group(0)!;
              expr = expr.replaceRange(
                powIdx - base.length,
                closeIdx + 1,
                'pow($base,$exp)',
              );
              // Re-scan from the same position
              continue;
            }
          }
        } else if (powIdx + 1 < expr.length) {
          // 2. Simple powers: base^2
          final exp = expr[powIdx + 1];
          // Only digits or letters for simplicity if not braced
          if (RegExp(r'[0-9a-zA-Z]').hasMatch(exp)) {
            final before = expr.substring(0, powIdx);
            final match = RegExp('$basePattern\$').firstMatch(before);
            if (match != null) {
              final base = match.group(0)!;
              expr = expr.replaceRange(
                powIdx - base.length,
                powIdx + 2,
                'pow($base,$exp)',
              );
              continue;
            }
          }
        }
        powIdx++;
      }

      // Protect functions and other constants before substitution to avoid partial replacement (e.g. 'r' in 'sqrt')
      final functions = [
        'sqrt',
        'pow',
        'sin',
        'cos',
        'tan',
        'asin',
        'acos',
        'atan',
        'arcsin',
        'arccos',
        'arctan',
        'log',
        'ln',
        'exp',
        'abs',
      ];
      final constants = ['Infinity', 'pi'];
      final placeholdersArr = <String, String>{};
      int pIdx = 0;

      for (final f in functions) {
        final p = '§_p_F${pIdx++}_§';
        if (expr.contains(f + '(')) {
          placeholdersArr[p] = f;
          expr = expr.replaceAll(f + '(', p + '(');
        }
      }
      for (final c in constants) {
        final p = '§_p_C${pIdx++}_§';
        if (expr.contains(c)) {
          placeholdersArr[p] = c;
          expr = expr.replaceAll(c, p);
        }
      }

      // Substitute known values
      final allVarsInExpr = extractVariables(latex)
        ..sort((a, b) => b.length.compareTo(a.length));
      final varPlaceholders = <String, String>{};
      String substitutedExpr = expr;
      for (int i = 0; i < allVarsInExpr.length; i++) {
        final v = allVarsInExpr[i];
        final p = '§_V${i}_§';
        varPlaceholders[p] = v;
        if (v.contains('_')) {
          final parts = v.split('_');
          substitutedExpr = substitutedExpr.replaceAll(
            '${parts[0]}_{${parts[1]}}',
            p,
          );
          substitutedExpr = substitutedExpr.replaceAll(
            '${parts[0]}_${parts[1]}',
            p,
          );
        } else {
          substitutedExpr = substitutedExpr.replaceAll(v, p);
        }
      }
      for (final p in varPlaceholders.keys) {
        final v = varPlaceholders[p]!;
        final val = values[v];
        if (val != null && !val.isNaN) {
          substitutedExpr = substitutedExpr.replaceAll(
            p,
            '(${_formatValueForStep(val)})',
          );
        } else {
          substitutedExpr = substitutedExpr.replaceAll(p, v);
        }
      }
      expr = substitutedExpr;

      // Restore protected tokens
      placeholdersArr.forEach((p, orig) => expr = expr.replaceAll(p, orig));

      expr = _addImplicitMultiplication(expr);

      if (expr.contains('=')) {
        final sides = expr.split('=');
        if (sides.length >= 2) {
          String leftExpr = sides[0].trim();
          String rightExpr = sides[1].trim();

          final leftVal = evaluateNumericExpression(leftExpr);
          final rightVal = evaluateNumericExpression(rightExpr);

          steps.add(
            SolvingStep(
              type: 'substitution',
              data: {
                'leftExpr': leftExpr,
                'rightExpr': rightExpr,
                'leftVal': leftVal,
                'rightVal': rightVal,
              },
            ),
          );

          if (solveFor != null) {
            steps.add(
              SolvingStep(type: 'solving_for', data: {'variable': solveFor}),
            );

            if (leftExpr == solveFor && rightVal.isFinite) {
              solvedValue = rightVal;
            } else if (rightExpr == solveFor && leftVal.isFinite) {
              solvedValue = leftVal;
            } else {
              solvedValue = _solveNumerically(
                leftExpr,
                rightExpr,
                solveFor,
                values,
              );
            }

            if (solvedValue != null) {
              steps.add(
                SolvingStep(
                  type: 'result',
                  data: {'variable': solveFor, 'value': solvedValue},
                ),
              );

              final verifyLeft = _evaluateWithValue(
                leftExpr,
                solveFor,
                solvedValue,
                values,
              );
              final verifyRight = _evaluateWithValue(
                rightExpr,
                solveFor,
                solvedValue,
                values,
              );

              bool isBalanced = false;
              if (verifyLeft == 0 && verifyRight == 0) {
                isBalanced = true;
              } else {
                final maxVal = math.max(verifyLeft.abs(), verifyRight.abs());
                if ((verifyLeft - verifyRight).abs() / maxVal < 0.0001) {
                  isBalanced = true;
                }
              }

              if (isBalanced) {
                steps.add(
                  SolvingStep(
                    type: 'verification',
                    data: {'left': verifyLeft, 'right': verifyRight},
                  ),
                );
              }
            } else {
              steps.add(SolvingStep(type: 'no_solution', data: {}));
            }
          } else {
            bool isBalanced = false;
            if (leftVal == 0 && rightVal == 0) {
              isBalanced = true;
            } else {
              final maxVal = math.max(leftVal.abs(), rightVal.abs());
              if ((leftVal - rightVal).abs() / maxVal < 0.0001) {
                isBalanced = true;
              }
            }

            steps.add(
              SolvingStep(
                type: 'balance_check',
                data: {
                  'balanced': isBalanced,
                  'difference': (leftVal - rightVal).abs(),
                },
              ),
            );
          }
        }
      } else {
        final result = evaluateNumericExpression(expr);
        steps.add(
          SolvingStep(
            type: 'expression_result',
            data: {'expression': expr, 'result': result},
          ),
        );
        solvedValue = result;
      }

      return SolvingResult(solvedValue: solvedValue, steps: steps);
    } catch (e) {
      return SolvingResult(error: e.toString());
    }
  }

  static double evaluateNumericExpression(String expr) {
    try {
      final cleaned = _addImplicitMultiplication(expr.replaceAll(' ', ''));
      final result = _parser.parse(cleaned);
      if (result is Success) return result.value;
      return double.nan;
    } catch (e) {
      return double.nan;
    }
  }

  static String _addImplicitMultiplication(String expr) {
    // Protect scientific notation (e.g., 1.2e-10)
    final sciPattern = RegExp(r'\d+(?:\.\d+)?[eE][+-]?\d+');
    String e = expr;
    final sciPlaceholders = <String, String>{};
    int sciIdx = 0;
    e = e.replaceAllMapped(sciPattern, (m) {
      final p = '§_s_${sciIdx++}_§';
      sciPlaceholders[p] = m.group(0)!;
      return p;
    });

    // Protect LaTeX commands (anything starting with \)
    final cmdPattern = RegExp(r'\\[a-zA-Z]+');
    final cmdPlaceholders = <String, String>{};
    int cmdIdx = 0;
    e = e.replaceAllMapped(cmdPattern, (m) {
      final p = '§_c_${cmdIdx++}_§';
      cmdPlaceholders[p] = m.group(0)!;
      return p;
    });

    // Protect subscripts (e.g., t_{far}, v_0)
    final subPattern = RegExp(r'[a-zA-Z](?:_\{[^}]+\}|_[a-zA-Z0-9]+)');
    final subPlaceholders = <String, String>{};
    int subIdx = 0;
    e = e.replaceAllMapped(subPattern, (m) {
      final p = '§_b_${subIdx++}_§';
      subPlaceholders[p] = m.group(0)!;
      return p;
    });

    // Protect function names
    final functions = [
      'sqrt',
      'pow',
      'sin',
      'cos',
      'tan',
      'asin',
      'acos',
      'atan',
      'arcsin',
      'arccos',
      'arctan',
      'log',
      'ln',
      'exp',
      'abs',
      'Infinity',
    ];
    final placeholders = <String, String>{};
    for (int i = 0; i < functions.length; i++) {
      final f = functions[i];
      final placeholder = '§_f_${i}_§';
      if (e.contains(f)) {
        placeholders[placeholder] = f;
        e = e.replaceAll(f, placeholder);
      }
    }

    e = e.replaceAllMapped(
      RegExp(r'(\d)([a-zA-Z])'),
      (m) => '${m.group(1)}*${m.group(2)}',
    );
    e = e.replaceAllMapped(
      RegExp(r'([a-zA-Z])(\d)'),
      (m) => '${m.group(1)}*${m.group(2)}',
    );
    e = e.replaceAllMapped(
      RegExp(r'([a-zA-Z])([a-zA-Z])'),
      (m) => '${m.group(1)}*${m.group(2)}',
    );

    // Handle number-placeholder and letter-placeholder and vice versa
    e = e.replaceAllMapped(
      RegExp(r'(\d)(§_[sfb]_\d+_§)'),
      (m) => '${m.group(1)}*${m.group(2)}',
    );
    e = e.replaceAllMapped(
      RegExp(r'(§_[sfb]_\d+_§)(\d)'),
      (m) => '${m.group(1)}*${m.group(2)}',
    );
    e = e.replaceAllMapped(
      RegExp(r'([a-zA-Z])(§_[sfb]_\d+_§)'),
      (m) => '${m.group(1)}*${m.group(2)}',
    );
    e = e.replaceAllMapped(
      RegExp(r'(§_[sfb]_\d+_§)([a-zA-Z])'),
      (m) => '${m.group(1)}*${m.group(2)}',
    );
    // Placeholder-Placeholder
    e = e.replaceAllMapped(
      RegExp(r'(§_[sfb]_\d+_§)(§_[sfb]_\d+_§)'),
      (m) => '${m.group(1)}*${m.group(2)}',
    );

    e = e.replaceAll(')(', ')*(');
    e = e.replaceAllMapped(
      RegExp(r'\)([a-zA-Z0-9§])'),
      (m) => ')*${m.group(1)}',
    );
    e = e.replaceAllMapped(RegExp(r'(\d)\('), (m) => '${m.group(1)}*(');
    e = e.replaceAllMapped(RegExp(r'([a-zA-Z])\('), (m) => '${m.group(1)}*(');
    e = e.replaceAllMapped(
      RegExp(r'(§_[sb]_\d+_§)\('),
      (m) => '${m.group(1)}*(',
    );
    // Note: §_f_...§ (functions) are explicitly NOT followed by * if they are before (

    // Restore everything in reverse order
    placeholders.forEach((p, orig) => e = e.replaceAll(p, orig));
    subPlaceholders.forEach((p, orig) => e = e.replaceAll(p, orig));
    cmdPlaceholders.forEach((p, orig) => e = e.replaceAll(p, orig));
    sciPlaceholders.forEach((p, orig) => e = e.replaceAll(p, orig));

    return e;
  }

  static double? _solveNumerically(
    String leftExpr,
    String rightExpr,
    String variable,
    Map<String, double> values,
  ) {
    double f(double x) {
      final left = _evaluateWithValue(leftExpr, variable, x, values);
      final right = _evaluateWithValue(rightExpr, variable, x, values);
      return left - right;
    }

    const ranges = [
      [0.0, 10.0],
      [-10.0, 0.0],
      [0.0, 100.0],
      [-100.0, 0.0],
      [-100.0, 100.0],
      [-1000.0, 1000.0],
      [-1e6, 1e6],
      [0.0, 1e12],
      [-1e12, 0.0],
      [-1.0, 1.0],
    ];
    for (final range in ranges) {
      final res = _bisection(f, range[0], range[1], 0.0000001, 100);
      if (res != null) return res;
    }
    for (final start in [
      0.0,
      1.0,
      10.0,
      -10.0,
      100.0,
      -100.0,
      1000.0,
      -1000.0,
      1e6,
      -1e6,
    ]) {
      final res = _newton(f, start, 0.0000001, 100);
      if (res != null && res.isFinite && res.abs() < 1e20) return res;
    }
    return null;
  }

  static double _evaluateWithValue(
    String expr,
    String variable,
    double value,
    Map<String, double> values,
  ) {
    return evaluateNumericExpression(
      _substituteVariable(expr, variable, value),
    );
  }

  static String _substituteVariable(
    String expr,
    String variable,
    double value,
  ) {
    String res = expr;
    if (variable.contains('_')) {
      final parts = variable.split('_');
      // Replace braced subscript F_{net}
      res = res.replaceAll('${parts[0]}_{${parts[1]}}', '($value)');
      // Replace non-braced subscript F_n
      res = res.replaceAll('${parts[0]}_${parts[1]}', '($value)');
    }
    // Replace standalone variable
    return res.replaceAll(variable, '($value)');
  }

  static double? _bisection(
    double Function(double) f,
    double a,
    double b,
    double tol,
    int maxIter,
  ) {
    var fa = f(a), fb = f(b);
    if (!fa.isFinite || !fb.isFinite) return null;
    if (fa.abs() < tol) return a;
    if (fb.abs() < tol) return b;
    if (fa * fb > 0) return null;
    for (int i = 0; i < maxIter; i++) {
      final c = (a + b) / 2, fc = f(c);
      if (fc.abs() < tol || (b - a) / 2 < tol) return c;
      if (fa * fc < 0) {
        b = c;
        fb = fc;
      } else {
        a = c;
        fa = fc;
      }
    }
    return (a + b) / 2;
  }

  static double? _newton(
    double Function(double) f,
    double x0,
    double tol,
    int maxIter,
  ) {
    const h = 0.0001;
    var x = x0;
    for (int i = 0; i < maxIter; i++) {
      final fx = f(x);
      if (fx.abs() < tol) return x;
      if (!fx.isFinite) return null;
      final dfx = (f(x + h) - f(x - h)) / (2 * h);
      if (dfx.abs() < 1e-12) return null;
      final xNew = x - fx / dfx;
      if ((xNew - x).abs() < tol) return xNew;
      x = xNew;
    }
    return null;
  }

  static String _formatValueForStep(double value) {
    if (value.isNaN) return '?';
    if (value.isInfinite) return 'Infinity';
    if (value == 0) return '0.0';

    final absVal = value.abs();
    if (absVal >= 1e6 || (absVal < 1e-4 && absVal > 0)) {
      return value
          .toStringAsExponential(4)
          .replaceAll(RegExp(r'0+e'), 'e')
          .replaceAll(RegExp(r'\.e'), 'e');
    }

    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  static String _replaceLatexCommand(String input, String command, int args) {
    String res = input;
    int lastFound = 0;
    while (true) {
      int idx = res.indexOf('\\$command', lastFound);
      if (idx == -1) break;

      final extractedArgs = <String>[];
      int currentPos = idx + command.length + 1;
      bool fail = false;

      for (int i = 0; i < args; i++) {
        // Find next {
        int start = res.indexOf('{', currentPos);
        if (start == -1) {
          fail = true;
          break;
        }

        // Check if it's strictly braced (ignoring [opt] briefly)
        final gap = res.substring(currentPos, start).trim();
        if (gap.isNotEmpty && !gap.startsWith('[')) {
          fail = true;
          break;
        }

        if (gap.startsWith('[')) {
          final endOpt = res.indexOf(']', currentPos);
          if (endOpt != -1) {
            start = res.indexOf('{', endOpt + 1);
            if (start == -1) {
              fail = true;
              break;
            }
          } else {
            fail = true;
            break;
          }
        }

        final end = _findClosingBrace(res, start);
        if (end == -1) {
          fail = true;
          break;
        }
        extractedArgs.add(res.substring(start + 1, end));
        currentPos = end + 1;
      }

      if (fail) {
        lastFound = idx + 1;
        continue;
      }

      String replacement;
      if (command == 'frac') {
        replacement = '(${extractedArgs[0]})/(${extractedArgs[1]})';
      } else if (command == 'sqrt') {
        replacement = 'sqrt(${extractedArgs[0]})';
      } else if (command == 'hat') {
        // Unit vector magnitude is 1
        replacement = '(1)';
      } else if (command == 'mathrm' ||
          command == 'mathbf' ||
          command == 'mathit' ||
          command == 'text' ||
          command == 'vec' ||
          command == 'tilde' ||
          command == 'bar' ||
          command == 'dot' ||
          command == 'ddot') {
        replacement = extractedArgs[0];
      } else {
        replacement = '$command(${extractedArgs.join(',')})';
      }

      res = res.replaceRange(idx, currentPos, replacement);
      // Re-scan from the same position to handle nested commands
      lastFound = idx;
    }
    return res;
  }

  static int _findClosingBrace(String s, int openIndex) {
    int count = 0;
    for (int i = openIndex; i < s.length; i++) {
      if (s[i] == '{') {
        count++;
      } else if (s[i] == '}') {
        count--;
        if (count == 0) return i;
      }
    }
    return -1;
  }
}
