import 'dart:math' as math;
import 'core/complex.dart';
import 'core/constants.dart';
import 'core/evaluator.dart';
import 'explicit_parser.dart';

// ═══════════════════════════════════════════════════════════════════════════
// RESULT CLASSES
// ═══════════════════════════════════════════════════════════════════════════

/// A step in the solution process.
class SolutionStep {
  /// Type of step: 'substitution', 'solving_for', 'result', 'verification',
  /// 'no_solution', 'balance_check', 'expression_result'
  final String type;

  /// Data associated with this step (varies by type)
  final Map<String, dynamic> data;

  const SolutionStep({required this.type, required this.data});
}

/// Result from solving an equation.
class EquationResult {
  /// The final computed value for the unknown variable (double or Complex)
  final dynamic solvedValue;

  /// Steps showing how the solution was derived
  final List<SolutionStep> steps;

  /// All found solutions (for equations with multiple roots)
  final List<dynamic>? allValues;

  /// Error message if solving failed
  final String? error;

  const EquationResult({
    this.solvedValue,
    this.allValues,
    this.steps = const [],
    this.error,
  });
}

/// A physics/natural constant.
class PhysicsConstant {
  final dynamic value;
  final String name;
  final String unit;
  final String symbol;

  const PhysicsConstant({
    required this.value,
    required this.name,
    required this.unit,
    required this.symbol,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// UNIFIED EQUATION PARSER
// ═══════════════════════════════════════════════════════════════════════════

/// A unified parser for mathematical equations.
///
/// Handles both LaTeX-style equations and clean algebraic notation.
/// Supports complex numbers, physics constants, and numerical solving.
///
/// Example usage:
/// ```dart
/// // Parse and solve
/// final result = EquationParser.solve('y=2*x+3', {'x': 5.0}, solveFor: 'y');
/// print(result.solvedValue); // 13.0
///
/// // Evaluate an expression
/// final value = EquationParser.evaluate('sqrt(-1)');
/// print(value); // Complex(0, 1) = i
///
/// // Extract variables
/// final vars = EquationParser.extractVariables('F=m*a');
/// print(vars); // ['F', 'm', 'a']
/// ```
class EquationParser {
  // ═════════════════════════════════════════════════════════════════════════
  // PHYSICS CONSTANTS
  // ═════════════════════════════════════════════════════════════════════════

  /// Common physics constants with their values and descriptions.
  static const Map<String, PhysicsConstant> physicsConstants = {
    'GC': PhysicsConstant(
      value: 6.67430e-11,
      name: 'Gravitational Constant',
      unit: 'N⋅m²/kg²',
      symbol: 'G',
    ),
    'SOL': PhysicsConstant(
      value: 299792458.0,
      name: 'Speed of Light',
      unit: 'm/s',
      symbol: 'c',
    ),
    'PC': PhysicsConstant(
      value: 6.62607015e-34,
      name: 'Planck Constant',
      unit: 'J⋅s',
      symbol: 'h',
    ),
    'BC': PhysicsConstant(
      value: 1.380649e-23,
      name: 'Boltzmann Constant',
      unit: 'J/K',
      symbol: 'k_B',
    ),
    'EC': PhysicsConstant(
      value: 1.602176634e-19,
      name: 'Elementary Charge',
      unit: 'C',
      symbol: 'e',
    ),
    'ME': PhysicsConstant(
      value: 9.1093837015e-31,
      name: 'Electron Mass',
      unit: 'kg',
      symbol: 'm_e',
    ),
    'MP': PhysicsConstant(
      value: 1.67262192369e-27,
      name: 'Proton Mass',
      unit: 'kg',
      symbol: 'm_p',
    ),
    'MN': PhysicsConstant(
      value: 1.67492749804e-27,
      name: 'Neutron Mass',
      unit: 'kg',
      symbol: 'm_n',
    ),
    'CC': PhysicsConstant(
      value: 8.9875517923e9,
      name: 'Coulomb Constant',
      unit: 'N⋅m²/C²',
      symbol: 'k_e',
    ),
    'EP': PhysicsConstant(
      value: 8.8541878128e-12,
      name: 'Vacuum Permittivity',
      unit: 'F/m',
      symbol: 'ε₀',
    ),
    'MU': PhysicsConstant(
      value: 1.25663706212e-6,
      name: 'Vacuum Permeability',
      unit: 'H/m',
      symbol: 'μ₀',
    ),
    'SG': PhysicsConstant(
      value: 9.80665,
      name: 'Standard Gravity',
      unit: 'm/s²',
      symbol: 'g',
    ),
    'AN': PhysicsConstant(
      value: 6.02214076e23,
      name: 'Avogadro Number',
      unit: '1/mol',
      symbol: 'N_A',
    ),
    'RG': PhysicsConstant(
      value: 8.314462618,
      name: 'Gas Constant',
      unit: 'J/(mol⋅K)',
      symbol: 'R',
    ),
    'SBC': PhysicsConstant(
      value: 5.670374419e-8,
      name: 'Stefan-Boltzmann',
      unit: 'W/(m²⋅K⁴)',
      symbol: 'σ',
    ),
    'RYD': PhysicsConstant(
      value: 10973731.568160,
      name: 'Rydberg Constant',
      unit: '1/m',
      symbol: 'R∞',
    ),
    'BM': PhysicsConstant(
      value: 9.2740100783e-24,
      name: 'Bohr Magneton',
      unit: 'J/T',
      symbol: 'μ_B',
    ),
    'BR': PhysicsConstant(
      value: 5.29177210903e-11,
      name: 'Bohr Radius',
      unit: 'm',
      symbol: 'a₀',
    ),
    'FSC': PhysicsConstant(
      value: 7.2973525693e-3,
      name: 'Fine Structure Constant',
      unit: '',
      symbol: 'α',
    ),
    'FC': PhysicsConstant(
      value: 96485.33212,
      name: 'Faraday Constant',
      unit: 'C/mol',
      symbol: 'F',
    ),
    'EM': PhysicsConstant(
      value: 5.972e24,
      name: 'Earth Mass',
      unit: 'kg',
      symbol: 'M_E',
    ),
    'ER': PhysicsConstant(
      value: 6.371e6,
      name: 'Earth Radius',
      unit: 'm',
      symbol: 'R_E',
    ),
    'AU': PhysicsConstant(
      value: 1.495978707e11,
      name: 'Astronomical Unit',
      unit: 'm',
      symbol: 'AU',
    ),
    'LY': PhysicsConstant(
      value: 9.4607e15,
      name: 'Light Year',
      unit: 'm',
      symbol: 'ly',
    ),
  };

  /// Returns the constant definition for a given name.
  static PhysicsConstant? getConstant(String name) {
    final upper = name.toUpperCase();
    return physicsConstants[upper];
  }

  /// Returns values for any recognized physics constants in the equation.
  static Map<String, dynamic> getPrefilledValues(String equation) {
    final values = <String, dynamic>{};
    final vars = ExplicitEquationParser.extractVariables(_cleanLatex(equation));

    for (final v in vars) {
      final constant = getConstant(v);
      if (constant != null && !constant.value.isNaN) {
        values[v] = constant.value;
      }
      // Also check Constants.all for additional constants
      final coreConstant = Constants.get(v);
      if (coreConstant != null && !coreConstant.value.isNaN) {
        values[v] = coreConstant.value;
      }
    }
    return values;
  }

  // ═════════════════════════════════════════════════════════════════════════
  // VARIABLE EXTRACTION
  // ═════════════════════════════════════════════════════════════════════════

  /// Extracts variable names from an equation.
  ///
  /// Automatically filters out:
  /// - Math constants: i, e, pi, PI, IN, EN, INF
  /// - Physics constants from [physicsConstants]
  /// - Constants from [Constants.all]
  ///
  /// Handles both LaTeX and algebraic notation.
  static List<String> extractVariables(String equation) {
    // Clean up LaTeX if present
    String expr = _cleanLatex(equation);

    // Use ExplicitEquationParser for extraction
    final rawVars = ExplicitEquationParser.extractVariables(expr);

    // Build set of constants to filter out
    final mathConstants = {
      'i',
      'e',
      'pi',
      'PI',
      'IN',
      'EN',
      'INF',
      'INFINITY',
      ...physicsConstants.keys,
      ...physicsConstants.values.map((c) => c.symbol),
      ...Constants.all.keys,
      ...Constants.all.values.map((c) => c.symbol),
    };

    return rawVars.where((v) => !mathConstants.contains(v)).toList();
  }

  // ═════════════════════════════════════════════════════════════════════════
  // EVALUATION
  // ═════════════════════════════════════════════════════════════════════════

  /// Evaluates an expression and returns the result.
  ///
  /// Returns [double] for real results, [Complex] for complex results.
  ///
  /// Example:
  /// ```dart
  /// EquationParser.evaluate('2+3');        // 5.0
  /// EquationParser.evaluate('sqrt(-1)');   // Complex(0, 1)
  /// EquationParser.evaluate('EN^(IN*PI)'); // -1.0 (Euler's identity)
  /// ```
  static dynamic evaluate(String expression, [Map<String, dynamic>? values]) {
    try {
      String expr = _cleanLatex(expression);

      final Map<String, dynamic> combinedValues = getPrefilledValues(expr);
      if (values != null) combinedValues.addAll(values);

      if (expr.contains('Infinity') || expr.contains('INFINITY')) {
        return double.infinity;
      }
      return Evaluator.evaluateMixed(expr, combinedValues);
    } catch (e) {
      return double.nan;
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // SOLVING
  // ═════════════════════════════════════════════════════════════════════════

  /// Solves an equation for a specified variable.
  ///
  /// [equation] - The equation to solve (LaTeX or algebraic notation)
  /// [values] - Map of known variable values
  /// [solveFor] - The variable to solve for (optional, auto-detected if one unknown)
  ///
  /// Returns [EquationResult] with the solution and steps.
  static EquationResult solve(
    String equation,
    Map<String, dynamic> values, {
    String? solveFor,
  }) {
    try {
      final steps = <SolutionStep>[];
      dynamic solvedValue;
      List<dynamic>? allValues;

      // Clean and prepare equation
      String expr = _cleanLatex(equation).replaceAll(' ', '');

      // Get ALL mentioned names (including constants) for full derivation display
      final displayVars = ExplicitEquationParser.extractVariables(
        _cleanLatex(equation),
      )..sort((a, b) => b.length.compareTo(a.length));

      String substitutedExpr = expr;
      for (final v in displayVars) {
        final val = values[v];
        if (val != null && !_isUnknown(val)) {
          final replacement = '(${_formatForParsing(val)})';
          final pattern = RegExp(
            r'(?<![a-zA-Z0-9_])' + RegExp.escape(v) + r'(?![a-zA-Z0-9_])',
          );
          substitutedExpr = substitutedExpr.replaceAll(pattern, replacement);
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
            SolutionStep(
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
              SolutionStep(type: 'solving_for', data: {'variable': solveFor}),
            );

            // Simple isolation: if one side equals the variable
            if (_containsOnlyVariable(leftExpr, solveFor) &&
                _isValid(rightVal)) {
              solvedValue = rightVal;
            } else if (_containsOnlyVariable(rightExpr, solveFor) &&
                _isValid(leftVal)) {
              solvedValue = leftVal;
            } else {
              // Try algebraic solving, then numerical
              final solveResult = _tryAlgebraicSolve(
                leftExpr,
                rightExpr,
                solveFor,
                leftVal,
                rightVal,
              );

              if (solveResult is List) {
                allValues = solveResult;
                solvedValue = solveResult.first;
              } else {
                solvedValue =
                    solveResult ??
                    _solveNumerically(leftExpr, rightExpr, solveFor, values);
                if (solvedValue != null) allValues = [solvedValue];
              }
            }

            if (solvedValue != null && _isValid(solvedValue)) {
              // Add result step (with all values if available)
              steps.add(
                SolutionStep(
                  type: 'result',
                  data: {
                    'variable': solveFor,
                    'value': solvedValue,
                    if (allValues != null && allValues.length > 1)
                      'allValues': allValues,
                  },
                ),
              );

              // Verification
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

              if (_isValid(verifyLeft) && _isValid(verifyRight)) {
                bool isBalanced = _isApproximatelyEqual(
                  verifyLeft,
                  verifyRight,
                );
                if (isBalanced) {
                  steps.add(
                    SolutionStep(
                      type: 'verification',
                      data: {'left': verifyLeft, 'right': verifyRight},
                    ),
                  );
                }
              }
            } else {
              steps.add(SolutionStep(type: 'no_solution', data: {}));
            }
          } else {
            // No variable to solve for - just check if equation balances
            bool isBalanced = _isApproximatelyEqual(leftVal, rightVal);
            steps.add(
              SolutionStep(
                type: 'balance_check',
                data: {
                  'balanced': isBalanced,
                  'difference': _getAbs(_subtract(leftVal, rightVal)),
                },
              ),
            );
          }
        }
      } else {
        // Just an expression, evaluate it
        final result = evaluate(substitutedExpr);
        steps.add(
          SolutionStep(
            type: 'expression_result',
            data: {'expression': substitutedExpr, 'result': result},
          ),
        );
        solvedValue = result;
      }

      return EquationResult(
        solvedValue: solvedValue,
        allValues: allValues,
        steps: steps,
      );
    } catch (e) {
      return EquationResult(error: e.toString());
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═════════════════════════════════════════════════════════════════════════

  /// Cleans LaTeX formatting from an expression.
  static String _cleanLatex(String latex) {
    String expr = latex
        .replaceAll(r'\times', '*')
        .replaceAll(r'\cdot', '*')
        .replaceAll(r'\div', '/')
        .replaceAll(r'\pm', '+')
        .replaceAll(r'\mp', '-')
        .replaceAll(r'\left', '')
        .replaceAll(r'\right', '')
        .replaceAll(r'\,', '')
        .replaceAll(r'\ ', '');

    // Handle \frac{a}{b} -> (a)/(b)
    final fracPattern = RegExp(r'\\frac\{([^}]*)\}\{([^}]*)\}');
    while (fracPattern.hasMatch(expr)) {
      expr = expr.replaceAllMapped(fracPattern, (m) => '(${m[1]})/(${m[2]})');
    }

    // Handle \sqrt{x} -> sqrt(x)
    expr = expr.replaceAllMapped(
      RegExp(r'\\sqrt\{([^}]*)\}'),
      (m) => 'sqrt(${m[1]})',
    );

    // Handle exponents: x^{n} -> x^(n)
    expr = expr.replaceAllMapped(RegExp(r'\^{([^}]*)}'), (m) => '^(${m[1]})');

    // Handle subscripts: x_{n} -> x_n
    expr = expr.replaceAllMapped(RegExp(r'_\{([^}]*)\}'), (m) => '_${m[1]}');

    // Greek letters
    final greekMap = {
      r'\alpha': 'alpha',
      r'\beta': 'beta',
      r'\gamma': 'gamma',
      r'\delta': 'delta',
      r'\epsilon': 'epsilon',
      r'\zeta': 'zeta',
      r'\eta': 'eta',
      r'\theta': 'theta',
      r'\iota': 'iota',
      r'\kappa': 'kappa',
      r'\lambda': 'lambda',
      r'\mu': 'mu',
      r'\nu': 'nu',
      r'\xi': 'xi',
      r'\rho': 'rho',
      r'\sigma': 'sigma',
      r'\tau': 'tau',
      r'\phi': 'phi',
      r'\chi': 'chi',
      r'\psi': 'psi',
      r'\omega': 'omega',
      r'\cap': 'cap',
      // Uppercase
      r'\Gamma': 'Gamma',
      r'\Delta': 'Delta',
      r'\Theta': 'Theta',
      r'\Lambda': 'Lambda',
      r'\Xi': 'Xi',
      r'\Pi': 'PI',
      r'\Sigma': 'Sigma',
      r'\Phi': 'Phi',
      r'\Psi': 'Psi',
      r'\Omega': 'Omega',
      // Constants
      r'\pi': 'PI',
      r'\infty': 'INF',
    };
    greekMap.forEach((k, v) => expr = expr.replaceAll(k, v));

    // Join Greek letters with following character if no space or explicitly space
    // e.g., Delta E -> DeltaE, DeltaE -> DeltaE
    expr = expr.replaceAllMapped(
      RegExp(
        r'(Delta|Phi|Gamma|Theta|Lambda|Sigma|Omega|alpha|beta|gamma|delta|theta|lambda|phi|omega)\s+([a-zA-Z])',
      ),
      (m) => '${m[1]}${m[2]}',
    );

    // Handle implicit multiplication: 3x -> 3*x, 3( -> 3*(, )x -> )*x, )( -> )*(
    // 1. Digit followed by letter or (
    expr = expr.replaceAllMapped(
      RegExp(r'(\d)\s*([a-zA-Z\(])'),
      (m) => '${m[1]}*${m[2]}',
    );
    // 2. ) followed by letter or (
    expr = expr.replaceAllMapped(
      RegExp(r'(\))\s*([a-zA-Z\(])'),
      (m) => '${m[1]}*${m[2]}',
    );

    // 3. i following a closing parenthesis: )i -> )*i
    expr = expr.replaceAllMapped(
      RegExp(r'(\))\s*i(?![a-zA-Z0-9])'),
      (m) => '${m[1]}*i',
    );

    // Map single i to IN just to be safe
    // Note: grammar already does this, but for some substitution logic it helps
    // expr = expr.replaceAll(RegExp(r'(?<![a-zA-Z0-9_])i(?![a-zA-Z0-9_])'), 'IN');

    return expr;
  }

  /// Formats a value for re-parsing (uses IN instead of i for complex).
  static String _formatForParsing(dynamic value) {
    if (value is Complex) {
      String fmt(double v) {
        if (v == v.roundToDouble()) return v.toInt().toString();
        return v.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
      }

      if (value.imaginary == 0) return fmt(value.real);

      final im = value.imaginary;
      final imAbs = im.abs();
      final imStr = imAbs == 1.0 ? 'IN' : '${fmt(imAbs)}*IN';

      if (value.real == 0) {
        return im >= 0 ? imStr : '-$imStr';
      }

      final sign = im >= 0 ? '+' : '-';
      return '${fmt(value.real)}$sign$imStr';
    }
    if (value is double) {
      if (value.isNaN) return '?';
      if (value.isInfinite) return 'Infinity';
      if (value == value.roundToDouble()) return value.toInt().toString();
      return value.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
    }
    return value.toString();
  }

  static bool _containsOnlyVariable(String expr, String variable) {
    final cleaned = expr.replaceAll('(', '').replaceAll(')', '').trim();
    return cleaned == variable;
  }

  static bool _isUnknown(dynamic value) {
    if (value == null) return true;
    if (value is double && value.isNaN) return true;
    return false;
  }

  static bool _isValid(dynamic val) {
    if (val is num) return val.isFinite;
    if (val is Complex) return val.isFinite;
    return false;
  }

  static double _getAbs(dynamic val) {
    if (val is num) return val.abs().toDouble();
    if (val is Complex) return val.abs();
    return double.nan;
  }

  static dynamic _subtract(dynamic a, dynamic b) {
    final aComplex = a is Complex ? a : Complex(a is num ? a.toDouble() : 0);
    final bComplex = b is Complex ? b : Complex(b is num ? b.toDouble() : 0);
    return aComplex - bComplex;
  }

  static bool _isApproximatelyEqual(dynamic a, dynamic b) {
    if (a == b) return true;
    final diff = _subtract(a, b);
    final absDiff = _getAbs(diff);
    final maxVal = math.max(_getAbs(a), _getAbs(b));
    if (maxVal == 0) return absDiff < 0.0001;
    return absDiff / maxVal < 0.0001;
  }

  static dynamic _evaluateWithValue(
    String expr,
    String variable,
    dynamic value,
  ) {
    final replacement = '(${_formatForParsing(value)})';
    final pattern = RegExp(
      r'(?<![a-zA-Z])' + RegExp.escape(variable) + r'(?![a-zA-Z0-9_])',
    );
    final substituted = expr.replaceAll(pattern, replacement);
    return evaluate(substituted);
  }

  static dynamic _tryAlgebraicSolve(
    String leftExpr,
    String rightExpr,
    String solveFor,
    dynamic leftVal,
    dynamic rightVal,
  ) {
    // Simple cases: variable = expression or expression = variable
    if (leftExpr == solveFor || leftExpr == '($solveFor)') {
      return rightVal;
    }
    if (rightExpr == solveFor || rightExpr == '($solveFor)') {
      return leftVal;
    }

    // Try quadratic formula for: left = right -> left - right = 0
    // Combine into single expression equal to zero
    final combinedExpr = '($leftExpr)-($rightExpr)';
    final quadResult = _tryQuadraticFormula(combinedExpr, solveFor);
    if (quadResult != null) {
      return quadResult;
    }

    return null; // Fall back to numerical solving
  }

  /// Tries to solve a quadratic equation using the quadratic formula.
  /// Handles equations of the form: ax² + bx + c = 0
  /// Returns the first root (complex if discriminant < 0).
  static dynamic _tryQuadraticFormula(String expr, String variable) {
    try {
      // Extract coefficients by evaluating at specific points
      // f(x) = ax² + bx + c
      // f(0) = c
      // f(1) = a + b + c
      // f(-1) = a - b + c
      // From these: c = f(0), a = (f(1) + f(-1))/2 - c, b = (f(1) - f(-1))/2

      final f0 = _evaluateWithValue(expr, variable, 0.0);
      final f1 = _evaluateWithValue(expr, variable, 1.0);
      final fm1 = _evaluateWithValue(expr, variable, -1.0);

      if (!_isValid(f0) || !_isValid(f1) || !_isValid(fm1)) return null;

      // Convert to doubles for coefficient extraction
      double c = _toDouble(f0);
      double sumF = _toDouble(f1) + _toDouble(fm1);
      double diffF = _toDouble(f1) - _toDouble(fm1);

      double a = sumF / 2 - c;
      double b = diffF / 2;

      // Check if it's actually quadratic (a ≠ 0)
      if (a.abs() < 1e-10) {
        // Linear equation: bx + c = 0 -> x = -c/b
        if (b.abs() > 1e-10) {
          return -c / b;
        }
        return null;
      }

      // Quadratic formula: x = (-b ± √(b² - 4ac)) / 2a
      double discriminant = b * b - 4 * a * c;

      if (discriminant >= 0) {
        // Real roots
        double sqrtD = math.sqrt(discriminant);
        double x1 = (-b + sqrtD) / (2 * a);
        double x2 = (-b - sqrtD) / (2 * a);

        // If roots are identical, return one
        if ((x1 - x2).abs() < 1e-10) return [x1];
        return [x1, x2];
      } else {
        // Complex roots: x = (-b ± i√|discriminant|) / 2a
        double realPart = -b / (2 * a);
        double imagPart = math.sqrt(-discriminant) / (2 * a);
        return [Complex(realPart, imagPart), Complex(realPart, -imagPart)];
      }
    } catch (e) {
      return null;
    }
  }

  static double _toDouble(dynamic val) {
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is Complex && val.imaginary.abs() < 1e-10) return val.real;
    return double.nan;
  }

  static dynamic _solveNumerically(
    String leftExpr,
    String rightExpr,
    String variable,
    Map<String, dynamic> values,
  ) {
    // Create objective function f(x) = left - right = 0
    double f(double x) {
      final left = _evaluateWithValue(leftExpr, variable, x);
      final right = _evaluateWithValue(rightExpr, variable, x);

      double l = 0, r = 0;
      if (left is num)
        l = left.toDouble();
      else if (left is Complex)
        l = left.real;
      if (right is num)
        r = right.toDouble();
      else if (right is Complex)
        r = right.real;

      return l - r;
    }

    // Try multiple search ranges
    const ranges = [
      [0.0, 10.0],
      [-10.0, 0.0],
      [0.0, 100.0],
      [-100.0, 0.0],
      [-100.0, 100.0],
      [-1000.0, 1000.0],
    ];

    for (final range in ranges) {
      final a = range[0], b = range[1];
      final fa = f(a), fb = f(b);

      if (fa.isNaN || fb.isNaN) continue;
      if (fa * fb < 0) {
        // Sign change - use bisection
        final root = _bisection(f, a, b, 1e-10, 100);
        if (root != null && root.isFinite) return root;
      }
    }

    // Try Newton's method from various starting points
    for (final x0 in [0.0, 1.0, -1.0, 10.0, -10.0, 100.0, -100.0, 4.0]) {
      final root = _newton(f, x0, 1e-12, 100);
      if (root != null && root.isFinite && f(root).abs() < 1e-5) {
        return root;
      }
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
    double fa = f(a), fb = f(b);
    if (fa * fb > 0) return null;

    for (int i = 0; i < maxIter; i++) {
      final c = (a + b) / 2;
      final fc = f(c);
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
    double x = x0;
    const h = 1e-7;

    for (int i = 0; i < maxIter; i++) {
      final fx = f(x);
      if (fx.abs() < tol) return x;

      final dfx = (f(x + h) - f(x - h)) / (2 * h);
      if (dfx.abs() < 1e-15) return null;

      final xNew = x - fx / dfx;
      if ((xNew - x).abs() < tol) return xNew;
      x = xNew;
    }
    return null;
  }
}
