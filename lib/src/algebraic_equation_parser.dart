import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';
import 'explicit_parser.dart';

/// Result from parsing and solving an algebraic equation
class AlgebraicEquationResult {
  /// The final computed value for the unknown variable, if any
  final double? solvedValue;

  /// Ordered steps of the solution process
  final List<AlgebraicEquationStep> steps;

  /// Any error message during solving
  final String? error;

  AlgebraicEquationResult({
    this.solvedValue,
    this.steps = const [],
    this.error,
  });
}

/// A single step in the solution process
class AlgebraicEquationStep {
  final String type;
  final Map<String, dynamic> data;

  AlgebraicEquationStep({required this.type, required this.data});
}

/// A physics/natural constant with its value, name, unit, and display symbol.
class NaturalConstant {
  final double value;
  final String name;
  final String unit;
  final String shownAs;

  const NaturalConstant({
    required this.value,
    required this.name,
    required this.unit,
    required this.shownAs,
  });
}

/// A parser for algebraic equations with explicit operators and algebraic solving capabilities.
class AlgebraicEquationParser {
  /// Common natural constants with their values and descriptions.
  static const Map<String, NaturalConstant> naturalConstants = {
    // Fundamental constants
    'G': NaturalConstant(
      value: 6.67430e-11,
      name: 'Gravitational Constant',
      unit: 'N⋅m²/kg²',
      shownAs: 'G',
    ),

    'SPEED_OF_LIGHT': NaturalConstant(
      value: 299792458,
      name: 'Speed of Light',
      unit: 'm/s',
      shownAs: 'c',
    ),
    'PLANCK': NaturalConstant(
      value: 6.62607015e-34,
      name: 'Planck Constant',
      unit: 'J⋅s',
      shownAs: 'h',
    ),
    'K_B': NaturalConstant(
      value: 1.380649e-23,
      name: 'Boltzmann Constant',
      unit: 'J/K',
      shownAs: 'k_B',
    ),
    'E_CHARGE': NaturalConstant(
      value: 1.602176634e-19,
      name: 'Elementary Charge',
      unit: 'C',
      shownAs: 'e_{charge}',
    ),
    'N_A': NaturalConstant(
      value: 6.02214076e23,
      name: 'Avogadro Number',
      unit: '1/mol',
      shownAs: 'N_A',
    ),
    'R_GAS': NaturalConstant(
      value: 8.314462618,
      name: 'Gas Constant',
      unit: 'J/(mol⋅K)',
      shownAs: 'R',
    ),
    // Electromagnetic
    'EPSILON_0': NaturalConstant(
      value: 8.8541878128e-12,
      name: 'Vacuum Permittivity',
      unit: 'F/m',
      shownAs: '\\epsilon_0',
    ),
    'MU_0': NaturalConstant(
      value: 1.25663706212e-6,
      name: 'Vacuum Permeability',
      unit: 'H/m',
      shownAs: '\\mu_0',
    ),
    // Earth-specific
    'G_EARTH': NaturalConstant(
      value: 9.80665,
      name: 'Standard Gravity',
      unit: 'm/s²',
      shownAs: 'g',
    ),
    'M_EARTH': NaturalConstant(
      value: 5.972e24,
      name: 'Earth Mass',
      unit: 'kg',
      shownAs: 'M_{earth}',
    ),
    'R_EARTH': NaturalConstant(
      value: 6.371e6,
      name: 'Earth Radius',
      unit: 'm',
      shownAs: 'R_{earth}',
    ),
    // Sun
    'M_SUN': NaturalConstant(
      value: 1.989e30,
      name: 'Sun Mass',
      unit: 'kg',
      shownAs: 'M_{sun}',
    ),
    // Mathematical constants
    'PI': NaturalConstant(
      value: 3.14159265358979323846,
      name: 'Pi',
      unit: '',
      shownAs: '\\pi',
    ),
    'EULER': NaturalConstant(
      value: 2.718281828459045,
      name: 'Euler\'s Number',
      unit: '',
      shownAs: 'e',
    ),
  };

  /// Returns the constant definition for a given variable name or symbol.
  /// Only matches by explicit key (e.g., 'G', 'SPEED_OF_LIGHT', 'PLANCK').
  /// The shownAs field is only used for display, not for matching.
  static NaturalConstant? getConstant(String name) {
    // Check direct key match
    if (naturalConstants.containsKey(name)) {
      return naturalConstants[name];
    }

    // Check upper-case key match (e.g. m_earth -> M_EARTH)
    final upper = name.toUpperCase();
    if (naturalConstants.containsKey(upper)) {
      return naturalConstants[upper];
    }

    return null;
  }

  /// Returns a map of variable values with physics constants pre-filled.
  static Map<String, double> getPrefilledValues(String equation) {
    final values = <String, double>{};
    final variables = extractVariables(equation);

    for (final varName in variables) {
      final constant = getConstant(varName);
      if (constant != null) {
        values[varName] = constant.value;
      }
    }

    return values;
  }

  /// Evaluates a numeric expression.
  static double evaluate(String expr) {
    try {
      if (expr.contains('Infinity') || expr.contains('INFINITY')) {
        return double.infinity;
      }
      // Use the robust Explicit parser
      final parsed = ExplicitEquationParser.parse(expr);
      if (parsed is Expression) {
        ContextModel cm = ContextModel();
        return parsed.evaluate(EvaluationType.REAL, cm);
      }
      return double.nan;
    } catch (e) {
      return double.nan;
    }
  }

  /// Extracts variable names from a simplified equation string.
  ///
  /// Example: `F_g=G*(m_1*m_2)/r^2` returns `['F_g', 'G', 'm_1', 'm_2', 'r']`
  static List<String> extractVariables(String equation) {
    // Delegate to the robust grammar-based parser
    return ExplicitEquationParser.extractVariables(equation);
  }

  /// Evaluates or solves the given equation.
  ///
  /// [equation] - The equation string with explicit operators
  /// [values] - Map of variable names to their values
  /// [solveFor] - Optional variable name to solve for (leave empty in values)
  static AlgebraicEquationResult solve(
    String equation,
    Map<String, double> values, {
    String? solveFor,
  }) {
    try {
      final steps = <AlgebraicEquationStep>[];
      double? solvedValue;

      // Normalize the equation
      String expr = equation.replaceAll(' ', '');

      // Substitute known values
      final allVars = extractVariables(equation)
        ..sort((a, b) => b.length.compareTo(a.length));

      String substitutedExpr = expr;
      for (final v in allVars) {
        final val = values[v];
        if (val != null && !val.isNaN) {
          final replacement = '(${_formatValue(val)})';
          // Handle subscript variables
          if (v.contains('_')) {
            final parts = v.split('_');
            // Replace braced form: F_{net}
            substitutedExpr = substitutedExpr.replaceAll(
              '${parts[0]}_{${parts[1]}}',
              replacement,
            );
            // Replace simple form: F_g (use regex to avoid partial matches)
            final pattern = RegExp(
              r'(?<![a-zA-Z])' + RegExp.escape(v) + r'(?![a-zA-Z0-9_])',
            );
            substitutedExpr = substitutedExpr.replaceAll(pattern, replacement);
          } else {
            // Use regex with lookbehind/lookahead to avoid replacing parts of
            // function names (e.g., don't replace 'r' in 'sqrt')
            final pattern = RegExp(
              r'(?<![a-zA-Z])' + RegExp.escape(v) + r'(?![a-zA-Z0-9_])',
            );
            substitutedExpr = substitutedExpr.replaceAll(pattern, replacement);
          }
        }
      }

      if (expr.contains('=')) {
        final sides = substitutedExpr.split('=');
        if (sides.length >= 2) {
          String leftExpr = sides[0].trim();
          String rightExpr = sides[1].trim();

          final leftVal = evaluate(leftExpr);
          final rightVal = evaluate(rightExpr);

          steps.add(
            AlgebraicEquationStep(
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
              AlgebraicEquationStep(
                type: 'solving_for',
                data: {'variable': solveFor},
              ),
            );

            // Check if the unknown is isolated on one side
            if (leftExpr == solveFor ||
                leftExpr == '($solveFor)' ||
                _containsOnlyVariable(leftExpr, solveFor)) {
              if (rightVal.isFinite) {
                solvedValue = rightVal;
              }
            } else if (rightExpr == solveFor ||
                rightExpr == '($solveFor)' ||
                _containsOnlyVariable(rightExpr, solveFor)) {
              if (leftVal.isFinite) {
                solvedValue = leftVal;
              }
            } else {
              // Try to detect and handle common algebraic patterns
              solvedValue =
                  _tryAlgebraicSolve(
                    leftExpr,
                    rightExpr,
                    solveFor,
                    leftVal,
                    rightVal,
                  ) ??
                  // Fall back to numerical solving
                  _solveNumerically(leftExpr, rightExpr, solveFor);
            }

            if (solvedValue != null) {
              steps.add(
                AlgebraicEquationStep(
                  type: 'result',
                  data: {'variable': solveFor, 'value': solvedValue},
                ),
              );

              // Verify the solution
              final verifyLeft = _evaluateWithValue(
                leftExpr,
                solveFor,
                solvedValue,
              );
              final verifyRight = _evaluateWithValue(
                rightExpr,
                solveFor,
                solvedValue,
              );

              if (_isApproximatelyEqual(verifyLeft, verifyRight)) {
                steps.add(
                  AlgebraicEquationStep(
                    type: 'verification',
                    data: {'left': verifyLeft, 'right': verifyRight},
                  ),
                );
              }
            } else {
              steps.add(AlgebraicEquationStep(type: 'no_solution', data: {}));
            }
          } else {
            // No variable to solve for, just check if equation is balanced
            final isBalanced = _isApproximatelyEqual(leftVal, rightVal);
            steps.add(
              AlgebraicEquationStep(
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
        // No equals sign, just evaluate the expression
        final result = evaluate(substitutedExpr);
        steps.add(
          AlgebraicEquationStep(
            type: 'expression_result',
            data: {'expression': substitutedExpr, 'result': result},
          ),
        );
        solvedValue = result;
      }

      return AlgebraicEquationResult(solvedValue: solvedValue, steps: steps);
    } catch (e) {
      return AlgebraicEquationResult(error: e.toString());
    }
  }

  static bool _containsOnlyVariable(String expr, String variable) {
    // Remove parentheses and check if the expression is just the variable
    final cleaned = expr.replaceAll('(', '').replaceAll(')', '').trim();
    return cleaned == variable;
  }

  static bool _isApproximatelyEqual(double a, double b) {
    if (a == b) return true;
    if (!a.isFinite || !b.isFinite) return false;
    if (a == 0 && b == 0) return true;

    final maxVal = math.max(a.abs(), b.abs());
    return (a - b).abs() / maxVal < 0.0001;
  }

  /// Tries to solve the equation algebraically for common patterns.
  /// Returns null if no algebraic solution is found.
  static double? _tryAlgebraicSolve(
    String leftExpr,
    String rightExpr,
    String solveFor,
    double leftVal,
    double rightVal,
  ) {
    // Pattern 1: A = B/x  →  x = B/A
    // Example: v = d/t solving for t → t = d/v
    // leftExpr is a number, rightExpr is something/variable
    if (leftVal.isFinite && leftVal != 0) {
      final divPattern = RegExp(
        r'^\(([^)]+)\)/\(?(' + RegExp.escape(solveFor) + r')\)?$',
      );
      final match = divPattern.firstMatch(rightExpr);
      if (match != null) {
        // rightExpr is numerator/solveFor
        final numeratorExpr = match.group(1)!;
        final numeratorVal = evaluate(numeratorExpr);
        if (numeratorVal.isFinite) {
          // x = numerator/leftVal
          return numeratorVal / leftVal;
        }
      }
    }

    // Pattern 2: B/x = A  →  x = B/A
    // Same as above but flipped
    if (rightVal.isFinite && rightVal != 0) {
      final divPattern = RegExp(
        r'^\(([^)]+)\)/\(?(' + RegExp.escape(solveFor) + r')\)?$',
      );
      final match = divPattern.firstMatch(leftExpr);
      if (match != null) {
        final numeratorExpr = match.group(1)!;
        final numeratorVal = evaluate(numeratorExpr);
        if (numeratorVal.isFinite) {
          return numeratorVal / rightVal;
        }
      }
    }

    // Pattern 3: A = B*x  →  x = A/B
    // Example: F = m*a solving for a → a = F/m
    if (leftVal.isFinite) {
      // Check if rightExpr is coefficient*variable or variable*coefficient
      final mulPattern1 = RegExp(
        r'^\(([^)]+)\)\*\(?(' + RegExp.escape(solveFor) + r')\)?$',
      );
      final mulPattern2 = RegExp(
        r'^\(?(' + RegExp.escape(solveFor) + r')\)?\*\(([^)]+)\)$',
      );

      var match = mulPattern1.firstMatch(rightExpr);
      if (match != null) {
        final coeffExpr = match.group(1)!;
        final coeffVal = evaluate(coeffExpr);
        if (coeffVal.isFinite && coeffVal != 0) {
          return leftVal / coeffVal;
        }
      }

      match = mulPattern2.firstMatch(rightExpr);
      if (match != null) {
        final coeffExpr = match.group(2)!;
        final coeffVal = evaluate(coeffExpr);
        if (coeffVal.isFinite && coeffVal != 0) {
          return leftVal / coeffVal;
        }
      }
    }

    // Pattern 4: 1/x = A  →  x = 1/A
    // Example: 1/f = 1/d_o + 1/d_i  →  f = 1/(1/d_o + 1/d_i)
    if (rightVal.isFinite && rightVal != 0) {
      // Check if leftExpr is 1/variable
      final recipPattern = RegExp(
        r'^1/\(?(' + RegExp.escape(solveFor) + r')\)?$',
      );
      if (recipPattern.hasMatch(leftExpr)) {
        return 1.0 / rightVal;
      }
    }

    // Pattern 5: A = 1/x  →  x = 1/A
    // Same as above but flipped
    if (leftVal.isFinite && leftVal != 0) {
      final recipPattern = RegExp(
        r'^1/\(?(' + RegExp.escape(solveFor) + r')\)?$',
      );
      if (recipPattern.hasMatch(rightExpr)) {
        return 1.0 / leftVal;
      }
    }

    // Pattern 6: A + B*x = C  →  x = (C-A)/B
    // Pattern 7: A*x + B = C  →  x = (C-B)/A
    // These are more complex and would need more parsing...

    return null;
  }

  static double _evaluateWithValue(String expr, String variable, double value) {
    String substituted = expr;
    if (variable.contains('_')) {
      final parts = variable.split('_');
      substituted = substituted.replaceAll(
        '${parts[0]}_{${parts[1]}}',
        '(${_formatValue(value)})',
      );
      substituted = substituted.replaceAll(
        variable,
        '(${_formatValue(value)})',
      );
    } else {
      substituted = substituted.replaceAll(
        variable,
        '(${_formatValue(value)})',
      );
    }
    return evaluate(substituted);
  }

  static double? _solveNumerically(
    String leftExpr,
    String rightExpr,
    String variable,
  ) {
    double f(double x) {
      final left = _evaluateWithValue(leftExpr, variable, x);
      final right = _evaluateWithValue(rightExpr, variable, x);
      return left - right;
    }

    // Try various ranges with bisection
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

    // Try Newton's method with various starting points
    for (final start in [0.0, 1.0, 10.0, -10.0, 100.0, -100.0, 1000.0]) {
      final res = _newton(f, start, 0.0000001, 100);
      if (res != null && res.isFinite && res.abs() < 1e20) return res;
    }

    return null;
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

  static String _formatValue(double value) {
    if (value.isNaN) return '?';
    if (value.isInfinite) return 'Infinity';
    if (value == 0) return '0';

    final absVal = value.abs();
    if (absVal >= 1e6 || (absVal < 1e-4 && absVal > 0)) {
      return value
          .toStringAsExponential(6)
          .replaceAll(RegExp(r'0+e'), 'e')
          .replaceAll(RegExp(r'\.e'), 'e');
    }

    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(6)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}
