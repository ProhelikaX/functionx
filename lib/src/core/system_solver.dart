import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';
import 'complex.dart';
import 'complex_evaluator.dart';
import 'parser.dart';

/// Result of solving a system of equations.
class SystemSolveResult {
  /// Map of variable names to their solved values (Complex).
  final Map<String, Complex> values;

  /// Whether the solution converged.
  final bool success;

  /// Error message if solving failed.
  final String? error;

  /// Number of iterations performed.
  final int iterations;

  const SystemSolveResult({
    required this.values,
    required this.success,
    this.error,
    this.iterations = 0,
  });

  const SystemSolveResult.error(this.error)
    : values = const {},
      success = false,
      iterations = 0;

  @override
  String toString() {
    if (!success) return 'SystemSolveResult.error($error)';
    final sortedEntries = values.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final valStr = sortedEntries
        .map((e) {
          final val = e.value;
          final valStr = val.isReal
              ? val.real.toStringAsFixed(6)
              : '${val.real.toStringAsFixed(6)} + ${val.imaginary.toStringAsFixed(6)}i';
          return '${e.key} = $valStr';
        })
        .join(', ');
    return 'SystemSolveResult($valStr)';
  }
}

/// Solves systems of non-linear equations using Newton-Raphson method.
/// Supports both real and complex numbers.
class SystemSolver {
  /// Solves a system of equations.
  ///
  /// [equations] - List of equation strings (e.g., ["x^2 + y^2 = 1", "y = x"]).
  /// [initialGuess] - Optional map of initial guesses for variables.
  /// [maxIterations] - Maximum number of iterations (default: 100).
  /// [tolerance] - Convergence tolerance (default: 1e-7).
  ///
  /// Returns a [SystemSolveResult].
  static SystemSolveResult solve(
    List<String> equations, {
    Map<String, dynamic>? initialGuess,
    int maxIterations = 100,
    double tolerance = 1e-7,
  }) {
    if (equations.isEmpty) {
      return const SystemSolveResult.error('No equations provided');
    }

    // 1. Parse equations and identify variables
    final parsedEquations = <ParseResult>[];
    final allVariables = <String>{};

    for (final eq in equations) {
      try {
        final parsed = ExpressionParser.parse(eq);
        parsedEquations.add(parsed);
        allVariables.addAll(ExpressionParser.extractVariables(eq));
      } catch (e) {
        return SystemSolveResult.error('Failed to parse equation "$eq": $e');
      }
    }

    final variables = allVariables.toList()..sort();
    final n = variables.length;
    final m = equations.length;

    if (n != m) {
      return SystemSolveResult.error(
        'Number of variables ($n) does not match number of equations ($m). '
        'Variables: ${variables.join(", ")}',
      );
    }

    // 2. Initialize variables (Complex)
    var currentValues = <String, Complex>{};
    for (final v in variables) {
      final guess = initialGuess?[v];
      if (guess is Complex) {
        currentValues[v] = guess;
      } else if (guess is num) {
        currentValues[v] = Complex(guess.toDouble());
      } else {
        currentValues[v] = Complex(1.0, 0.0); // Default guess 1.0
      }
    }

    // 3. Newton-Raphson Iteration
    for (var iter = 0; iter < maxIterations; iter++) {
      // Evaluate F(X)
      final F = List<Complex>.filled(n, Complex.zero);
      var maxError = 0.0;

      for (var i = 0; i < n; i++) {
        final parsed = parsedEquations[i];
        Complex val;
        if (parsed.isEquation) {
          val =
              _evaluateExpression(parsed.left!, currentValues) -
              _evaluateExpression(parsed.right!, currentValues);
        } else {
          val = _evaluateExpression(parsed.expression!, currentValues);
        }
        F[i] = val;
        maxError = math.max(maxError, val.abs());
      }

      if (maxError < tolerance) {
        return SystemSolveResult(
          values: currentValues,
          success: true,
          iterations: iter,
        );
      }

      // Compute Jacobian J(X)
      final J = List.generate(n, (_) => List<Complex>.filled(n, Complex.zero));
      final h = 1e-8; // Step size for finite difference

      for (var j = 0; j < n; j++) {
        final varName = variables[j];
        final originalVal = currentValues[varName]!;

        // Perturb variable j
        currentValues[varName] = originalVal + h;

        for (var i = 0; i < n; i++) {
          final parsed = parsedEquations[i];
          Complex valPerturbed;
          if (parsed.isEquation) {
            valPerturbed =
                _evaluateExpression(parsed.left!, currentValues) -
                _evaluateExpression(parsed.right!, currentValues);
          } else {
            valPerturbed = _evaluateExpression(
              parsed.expression!,
              currentValues,
            );
          }
          J[i][j] = (valPerturbed - F[i]) / h;
        }

        // Restore variable j
        currentValues[varName] = originalVal;
      }

      // Solve J * deltaX = -F
      final b = F.map((v) => -v).toList();

      try {
        final deltaX = _solveComplexLinearSystem(J, b);

        // Update X
        for (var j = 0; j < n; j++) {
          currentValues[variables[j]] =
              currentValues[variables[j]]! + deltaX[j];
        }
      } catch (e) {
        return SystemSolveResult.error(
          'Singular matrix or solver error at iter $iter: $e',
        );
      }
    }

    return SystemSolveResult(
      values: currentValues,
      success: false,
      error: 'Did not converge after $maxIterations iterations',
      iterations: maxIterations,
    );
  }

  // Helper to evaluate AST with current values and constants
  static Complex _evaluateExpression(
    Expression expression,
    Map<String, Complex> values,
  ) {
    return ComplexEvaluator.evaluate(expression, values);
  }

  /// Solves A * x = b for Complex numbers using Gaussian elimination.
  static List<Complex> _solveComplexLinearSystem(
    List<List<Complex>> A,
    List<Complex> b,
  ) {
    final n = b.length;
    // Deep copy A and b
    final mat = List.generate(n, (i) => List<Complex>.from(A[i]));
    final rhs = List<Complex>.from(b);

    // Forward elimination
    for (var i = 0; i < n; i++) {
      // Pivot
      var maxRow = i;
      for (var k = i + 1; k < n; k++) {
        if (mat[k][i].abs() > mat[maxRow][i].abs()) {
          maxRow = k;
        }
      }

      // Swap rows
      final tempRow = mat[i];
      mat[i] = mat[maxRow];
      mat[maxRow] = tempRow;

      final tempRhs = rhs[i];
      rhs[i] = rhs[maxRow];
      rhs[maxRow] = tempRhs;

      if (mat[i][i].abs() < 1e-12) {
        throw Exception('Matrix is singular or nearly singular');
      }

      // Eliminate
      for (var k = i + 1; k < n; k++) {
        final factor = mat[k][i] / mat[i][i];
        rhs[k] = rhs[k] - (factor * rhs[i]);
        for (var j = i; j < n; j++) {
          mat[k][j] = mat[k][j] - (factor * mat[i][j]);
        }
      }
    }

    // Back substitution
    final x = List<Complex>.filled(n, Complex.zero);
    for (var i = n - 1; i >= 0; i--) {
      var sum = Complex.zero;
      for (var j = i + 1; j < n; j++) {
        sum = sum + (mat[i][j] * x[j]);
      }
      x[i] = (rhs[i] - sum) / mat[i][i];
    }

    return x;
  }
}
