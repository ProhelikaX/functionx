import 'evaluator.dart';
import 'parser.dart';
import 'complex.dart';

/// Result of solving an equation.
class SolveResult {
  /// The computed value of the solved variable (double or Complex).
  final dynamic value;

  /// The name of the variable that was solved.
  final String variable;

  /// Human-readable steps showing the solution process.
  final List<String> steps;

  /// Whether the solution was found numerically (vs algebraically).
  final bool isNumeric;

  /// Error message if solving failed.
  final String? error;

  /// Whether the solve operation succeeded.
  bool get success => error == null;

  const SolveResult({
    required this.value,
    required this.variable,
    this.steps = const [],
    this.isNumeric = false,
    this.error,
  });

  const SolveResult.error(this.error)
    : value = double.nan,
      variable = '',
      steps = const [],
      isNumeric = false;

  @override
  String toString() {
    if (!success) return 'SolveResult.error($error)';
    return 'SolveResult($variable = $value)';
  }
}

/// Solves equations for unknown variables.
///
/// Supports both algebraic (symbolic) and numerical solving methods.
class Solver {
  /// Solves an equation for the unknown variable.
  ///
  /// [equation] - The equation string (must contain `=`).
  /// [values] - Map of known variable values. Omit or set to `null` for the unknown.
  /// [solveFor] - Optional: explicitly specify which variable to solve for.
  ///
  /// Returns a [SolveResult] with the solution.
  static SolveResult solve(
    String equation,
    Map<String, dynamic> values, {
    String? solveFor,
  }) {
    try {
      // Parse the equation
      final parsed = ExpressionParser.parse(equation);
      if (!parsed.isEquation) {
        return const SolveResult.error('Input must be an equation with =');
      }

      // Determine which variable to solve for
      final allVars = ExpressionParser.extractVariables(equation);
      final unknowns = allVars.where((v) => values[v] == null).toList();

      String targetVar;
      if (solveFor != null) {
        targetVar = solveFor;
      } else if (unknowns.length == 1) {
        targetVar = unknowns.first;
      } else if (unknowns.isEmpty) {
        return const SolveResult.error('No unknown variable to solve for');
      } else {
        return SolveResult.error(
          'Multiple unknowns: ${unknowns.join(", ")}. Specify solveFor.',
        );
      }

      // Convert nullable map to non-nullable (filter out nulls)
      final knownValues = <String, dynamic>{};
      for (final entry in values.entries) {
        if (entry.value != null) {
          knownValues[entry.key] = entry.value!;
        }
      }

      // Extract left and right expressions as strings
      final parts = equation.split('=');
      if (parts.length != 2) {
        return const SolveResult.error('Invalid equation format');
      }

      final leftExpr = parts[0].trim();
      final rightExpr = parts[1].trim();

      // Try algebraic solution first
      final algebraicResult = _tryAlgebraicSolve(
        leftExpr,
        rightExpr,
        targetVar,
        knownValues,
      );
      if (algebraicResult != null) {
        return algebraicResult;
      }

      // Fall back to numerical solution
      return _solveNumerically(leftExpr, rightExpr, targetVar, knownValues);
    } catch (e) {
      return SolveResult.error('Solving failed: $e');
    }
  }

  /// Attempts algebraic solving for common equation patterns.
  static SolveResult? _tryAlgebraicSolve(
    String leftExpr,
    String rightExpr,
    String variable,
    Map<String, dynamic> values,
  ) {
    final steps = <String>[];

    // Check if variable is isolated on left side
    if (leftExpr.trim() == variable) {
      try {
        final result = Evaluator.evaluateMixed(rightExpr, values);
        steps.add('$variable = $rightExpr');
        steps.add('$variable = ${_formatValue(result)}');
        return SolveResult(
          value: result,
          variable: variable,
          steps: steps,
          isNumeric: false,
        );
      } catch (_) {}
    }

    // Check if variable is isolated on right side
    if (rightExpr.trim() == variable) {
      try {
        final result = Evaluator.evaluateMixed(leftExpr, values);
        steps.add('$leftExpr = $variable');
        steps.add('${_formatValue(result)} = $variable');
        return SolveResult(
          value: result,
          variable: variable,
          steps: steps,
          isNumeric: false,
        );
      } catch (_) {}
    }

    // More algebraic patterns could be added here
    return null;
  }

  /// Solves the equation numerically using bisection and Newton's method.
  static SolveResult _solveNumerically(
    String leftExpr,
    String rightExpr,
    String variable,
    Map<String, dynamic> values,
  ) {
    double f(double x) {
      final testValues = Map<String, dynamic>.from(values);
      testValues[variable] = x;
      final leftVal = Evaluator.evaluate(leftExpr, testValues);
      final rightVal = Evaluator.evaluate(rightExpr, testValues);
      return leftVal - rightVal;
    }

    // Try bisection first
    double? solution;
    const ranges = [
      [-1e6, 1e6],
      [-1e3, 1e3],
      [-100.0, 100.0],
      [-10.0, 10.0],
      [0.0, 1e6],
      [0.0, 100.0],
    ];

    for (final range in ranges) {
      try {
        final a = range[0];
        final b = range[1];
        if (f(a).sign != f(b).sign) {
          solution = _bisection(f, a, b);
          if (solution != null) break;
        }
      } catch (_) {}
    }

    // Try Newton's method if bisection fails
    if (solution == null || solution.isNaN) {
      for (final x0 in [0.0, 1.0, -1.0, 10.0, -10.0, 100.0]) {
        try {
          final result = _newton(f, x0);
          if (result != null && !result.isNaN && f(result).abs() < 1e-6) {
            solution = result;
            break;
          }
        } catch (_) {}
      }
    }

    if (solution == null || solution.isNaN) {
      return const SolveResult.error('Could not find numerical solution');
    }

    return SolveResult(
      value: solution,
      variable: variable,
      steps: ['Solved numerically: $variable ≈ ${_formatValue(solution)}'],
      isNumeric: true,
    );
  }

  /// Bisection method for root finding.
  static double? _bisection(
    double Function(double) f,
    double a,
    double b, {
    double tol = 1e-10,
    int maxIter = 100,
  }) {
    double fa = f(a);
    double fb = f(b);

    if (fa.sign == fb.sign) return null;

    for (int i = 0; i < maxIter; i++) {
      double c = (a + b) / 2;
      double fc = f(c);

      if (fc.abs() < tol || (b - a) / 2 < tol) {
        return c;
      }

      if (fc.sign == fa.sign) {
        a = c;
        fa = fc;
      } else {
        b = c;
        fb = fc;
      }
    }

    return (a + b) / 2;
  }

  /// Newton's method for root finding.
  static double? _newton(
    double Function(double) f,
    double x0, {
    double tol = 1e-10,
    int maxIter = 50,
  }) {
    double x = x0;
    const h = 1e-8;

    for (int i = 0; i < maxIter; i++) {
      double fx = f(x);
      if (fx.abs() < tol) return x;

      double fpx = (f(x + h) - f(x - h)) / (2 * h);
      if (fpx.abs() < 1e-15) return null;

      double xNew = x - fx / fpx;
      if ((xNew - x).abs() < tol) return xNew;
      x = xNew;
    }

    return x;
  }

  /// Formats a numeric value for display.
  static String _formatValue(dynamic value) {
    if (value is Complex) {
      return value.toString();
    }
    if (value is double) {
      if (value.isNaN) return 'NaN';
      if (value.isInfinite) return 'Infinity';
      if (value == value.roundToDouble() && value.abs() < 1e10) {
        return value.toInt().toString();
      }
      if (value.abs() < 1e-6 && value != 0) {
        return value.toStringAsExponential(6);
      }
      return value.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
    }
    return value.toString();
  }
}
