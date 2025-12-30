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
class NaturalConstant {
  final dynamic value;
  final String name;
  final String unit;
  final String symbol;

  const NaturalConstant({
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
  // NATURAL CONSTANTS
  // ═════════════════════════════════════════════════════════════════════════

  /// Common natural constants with their values and descriptions.
  static const Map<String, NaturalConstant> naturalConstants = {
    'GC': NaturalConstant(
      value: 6.67430e-11,
      name: 'Gravitational Constant',
      unit: 'N⋅m²/kg²',
      symbol: 'G',
    ),
    'SOL': NaturalConstant(
      value: 299792458.0,
      name: 'Speed of Light',
      unit: 'm/s',
      symbol: 'c',
    ),
    'EN': NaturalConstant(
      value: 2.71828182846,
      name: 'Euler\'s Number',
      unit: '',
      symbol: 'e',
    ),
    'PI': NaturalConstant(value: math.pi, name: 'Pi', unit: '', symbol: 'π'),
    'INF': NaturalConstant(
      value: double.infinity,
      name: 'Infinity',
      unit: '',
      symbol: '∞',
    ),
    'IN': NaturalConstant(
      value: Complex(0, 1),
      name: 'Imaginary Unit',
      unit: '',
      symbol: 'i',
    ),
    'PC': NaturalConstant(
      value: 6.62607015e-34,
      name: 'Planck Constant',
      unit: 'J⋅s',
      symbol: 'h',
    ),
    'BC': NaturalConstant(
      value: 1.380649e-23,
      name: 'Boltzmann Constant',
      unit: 'J/K',
      symbol: 'k_B',
    ),
    'EC': NaturalConstant(
      value: 1.602176634e-19,
      name: 'Elementary Charge',
      unit: 'C',
      symbol: 'e',
    ),
    'ME': NaturalConstant(
      value: 9.1093837015e-31,
      name: 'Electron Mass',
      unit: 'kg',
      symbol: 'm_e',
    ),
    'MP': NaturalConstant(
      value: 1.67262192369e-27,
      name: 'Proton Mass',
      unit: 'kg',
      symbol: 'm_p',
    ),
    'MN': NaturalConstant(
      value: 1.67492749804e-27,
      name: 'Neutron Mass',
      unit: 'kg',
      symbol: 'm_n',
    ),
    'CC': NaturalConstant(
      value: 8.9875517923e9,
      name: 'Coulomb Constant',
      unit: 'N⋅m²/C²',
      symbol: 'k_e',
    ),
    'EP': NaturalConstant(
      value: 8.8541878128e-12,
      name: 'Vacuum Permittivity',
      unit: 'F/m',
      symbol: 'ε₀',
    ),
    'MU': NaturalConstant(
      value: 1.25663706212e-6,
      name: 'Vacuum Permeability',
      unit: 'H/m',
      symbol: 'μ₀',
    ),
    'SG': NaturalConstant(
      value: 9.80665,
      name: 'Standard Gravity',
      unit: 'm/s²',
      symbol: 'g',
    ),
    'GE': NaturalConstant(
      value: 9.8,
      name: 'Gravitational acceleration Earth',
      unit: 'm/s²',
      symbol: 'GE',
    ),
    'AN': NaturalConstant(
      value: 6.02214076e23,
      name: 'Avogadro Number',
      unit: '1/mol',
      symbol: 'N_A',
    ),
    'RG': NaturalConstant(
      value: 8.314462618,
      name: 'Gas Constant',
      unit: 'J/(mol⋅K)',
      symbol: 'R',
    ),
    'SBC': NaturalConstant(
      value: 5.670374419e-8,
      name: 'Stefan-Boltzmann',
      unit: 'W/(m²⋅K⁴)',
      symbol: 'σ',
    ),
    'RYD': NaturalConstant(
      value: 10973731.568160,
      name: 'Rydberg Constant',
      unit: '1/m',
      symbol: 'R∞',
    ),
    'BM': NaturalConstant(
      value: 9.2740100783e-24,
      name: 'Bohr Magneton',
      unit: 'J/T',
      symbol: 'μ_B',
    ),
    'BR': NaturalConstant(
      value: 5.29177210903e-11,
      name: 'Bohr Radius',
      unit: 'm',
      symbol: 'a₀',
    ),
    'FSC': NaturalConstant(
      value: 7.2973525693e-3,
      name: 'Fine Structure Constant',
      unit: '',
      symbol: 'α',
    ),
    'FC': NaturalConstant(
      value: 96485.33212,
      name: 'Faraday Constant',
      unit: 'C/mol',
      symbol: 'F',
    ),
    'EM': NaturalConstant(
      value: 5.972e24,
      name: 'Earth Mass',
      unit: 'kg',
      symbol: 'M_E',
    ),
    'ER': NaturalConstant(
      value: 6.371e6,
      name: 'Earth Radius',
      unit: 'm',
      symbol: 'R_E',
    ),
    'AU': NaturalConstant(
      value: 1.495978707e11,
      name: 'Astronomical Unit',
      unit: 'm',
      symbol: 'AU',
    ),
    'LY': NaturalConstant(
      value: 9.4607e15,
      name: 'Light Year',
      unit: 'm',
      symbol: 'ly',
    ),
    'WIE': NaturalConstant(
      value: 2.897771955e-3,
      name: 'Wien Displacement Constant',
      unit: 'm⋅K',
      symbol: 'b',
    ),
    'SB': NaturalConstant(
      value: 5.670374419e-8,
      name: 'Stefan-Boltzmann Constant',
      unit: 'W/(m²⋅K⁴)',
      symbol: 'σ',
    ),
    'MFQ': NaturalConstant(
      value: 2.067833848e-15,
      name: 'Magnetic Flux Quantum',
      unit: 'Wb',
      symbol: 'Φ₀',
    ),
    'CQ': NaturalConstant(
      value: 7.748091729e-5,
      name: 'Conductance Quantum',
      unit: 'S',
      symbol: 'G₀',
    ),
    'JC': NaturalConstant(
      value: 4.835978484e14,
      name: 'Josephson Constant',
      unit: 'Hz/V',
      symbol: 'K_J',
    ),
    'VK': NaturalConstant(
      value: 25812.80745,
      name: 'Von Klitzing Constant',
      unit: 'Ω',
      symbol: 'R_K',
    ),
    'C1': NaturalConstant(
      value: 3.741771852e-16,
      name: 'First Radiation Constant',
      unit: 'W⋅m²',
      symbol: 'c₁',
    ),
    'C2': NaturalConstant(
      value: 1.438776877e-2,
      name: 'Second Radiation Constant',
      unit: 'm⋅K',
      symbol: 'c₂',
    ),
  };

  /// Returns the constant definition for a given name.
  static NaturalConstant? getConstant(String name) {
    // Ultra-Strict lookup: ONLY look for keys in naturalConstants.
    // Use 'SOL' for Speed of Light, 'GC' for Gravitational Constant, etc.
    // 'c', 'G', 'h', 'e' are ALWAYS variables.

    final upper = name.toUpperCase();
    if (naturalConstants.containsKey(upper)) return naturalConstants[upper];

    return null;
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
  /// Extracts variable names from an equation string.
  ///
  /// Filters out known mathematical constants if [excludeConstants] is true (default: false).
  /// Constants include:
  /// - 'i', 'e', 'pi', 'PI', 'INF', etc.
  /// - Known physics symbols from [physicsConstants]
  /// - Constants from [Constants.all]
  ///
  /// Handles both LaTeX and algebraic notation.
  static List<String> extractVariables(
    String equation, {
    bool excludeConstants = false,
  }) {
    // Clean up LaTeX if present
    String expr = _cleanLatex(equation);

    // Use ExplicitEquationParser for extraction
    final rawVars = ExplicitEquationParser.extractVariables(expr);

    if (!excludeConstants) return rawVars;

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
      ...naturalConstants.keys,
      ...naturalConstants.values.map((c) => c.symbol),
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
      String? findVar = solveFor != null
          ? _cleanLatex(solveFor).replaceAll(' ', '')
          : null;

      // Get ALL mentioned names (including constants) for full derivation display
      final displayVars = ExplicitEquationParser.extractVariables(
        _cleanLatex(equation),
      )..sort((a, b) => b.length.compareTo(a.length));

      String substitutedExpr = expr;
      // Skip substitution for built-in constants - parser handles them directly
      const builtInConstants = {'IN', 'EN', 'PI', 'INF'};
      for (final v in displayVars) {
        if (builtInConstants.contains(v)) continue; // Parser evaluates these
        final val = values[v];
        if (val != null && !_isUnknown(val)) {
          final replacement = '(${_formatForParsing(val)})';
          final pattern = RegExp(
            r'(?<![a-zA-Z0-9_])' + RegExp.escape(v) + r'(?![a-zA-Z0-9_])',
          );
          substitutedExpr = substitutedExpr.replaceAll(pattern, replacement);
        }
      }

      // Insert explicit multiplication operators where implicit multiplication
      // would be expected but isn't supported by the parser.
      // Cases: )( , )letter, )digit, digit(, letter(
      substitutedExpr = substitutedExpr.replaceAllMapped(
        RegExp(r'\)([a-zA-Z0-9(])'),
        (m) => ')*${m.group(1)}',
      );
      substitutedExpr = substitutedExpr.replaceAllMapped(
        RegExp(r'(\d)\('),
        (m) => '${m.group(1)}*(',
      );

      if (expr.contains('=')) {
        final sides = substitutedExpr.split('=');
        if (sides.length >= 2) {
          String leftExpr = sides[0].trim();
          String rightExpr = sides[1].trim();

          final leftVal = evaluate(leftExpr, values);
          final rightVal = evaluate(rightExpr, values);

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

          if (findVar != null) {
            steps.add(
              SolutionStep(type: 'solving_for', data: {'variable': findVar}),
            );

            // Simple isolation: if one side equals the variable
            if (_containsOnlyVariable(leftExpr, findVar) &&
                _isValidValue(rightVal)) {
              solvedValue = rightVal;
            } else if (_containsOnlyVariable(rightExpr, findVar) &&
                _isValidValue(leftVal)) {
              solvedValue = leftVal;
            } else {
              // Try algebraic solving, then numerical
              final solveResult = _tryAlgebraicSolve(
                leftExpr,
                rightExpr,
                findVar,
                leftVal,
                rightVal,
              );

              if (solveResult is List) {
                allValues = solveResult;
                solvedValue = solveResult.first;
              } else {
                solvedValue =
                    solveResult ??
                    _solveNumerically(leftExpr, rightExpr, findVar, values);
                if (solvedValue != null) allValues = [solvedValue];
              }
            }

            if (solvedValue != null && _isValidValue(solvedValue)) {
              // Add result step (with all values if available)
              steps.add(
                SolutionStep(
                  type: 'result',
                  data: {
                    'variable': findVar,
                    'value': solvedValue,
                    if (allValues != null && allValues.length > 1)
                      'allValues': allValues,
                  },
                ),
              );

              // Verification
              final verifyLeft = _evaluateWithValue(
                leftExpr,
                findVar,
                solvedValue,
              );
              final verifyRight = _evaluateWithValue(
                rightExpr,
                findVar,
                solvedValue,
              );

              if (_isValidValue(verifyLeft) && _isValidValue(verifyRight)) {
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
    if (latex.isEmpty) return '';
    // print('CleanLatex Input: $latex');

    String expr = latex;

    // Remove LaTeX wrappers
    if (expr.startsWith(r'$$') && expr.endsWith(r'$$')) {
      expr = expr.substring(2, expr.length - 2).trim();
    } else if (expr.startsWith(r'$') && expr.endsWith(r'$')) {
      expr = expr.substring(1, expr.length - 1).trim();
    }

    // 1. Remove common LaTeX style commands
    // \text{...} -> remove entirely (content often units/labels)
    expr = expr.replaceAllMapped(RegExp(r'\\text\{([^}]*)\}'), (m) => '');
    // Others -> keep content
    expr = expr.replaceAllMapped(
      RegExp(
        r'\\(mathrm|mathbf|mathit|mathsf|mathtt|bold|invisible)\{([^}]*)\}',
      ),
      (m) => m[2]!,
    );
    expr = expr.replaceAll(RegExp(r'\\(left|right|big|Big|bigg|Bigg)'), '');
    expr = expr.replaceAll(r'\,', ' ');
    expr = expr.replaceAll(r'\:', ' ');
    expr = expr.replaceAll(r'\;', ' ');
    expr = expr.replaceAll(r'\!', '');

    // 1.5 Remove decorations: \vec{x}, \hat{x}, \bar{x}, \dot{x}, \ddot{x}
    expr = expr.replaceAllMapped(
      RegExp(r'\\(vec|hat|bar|dot|ddot|tilde)\{([^}]*)\}'),
      (m) => '${m[2]}',
    );
    expr = expr.replaceAllMapped(
      RegExp(r'\\(vec|hat|bar|dot|ddot|tilde)\s+([a-zA-Z])'),
      (m) => '${m[2]}',
    );

    // 2. Constants/Operators
    expr = expr.replaceAll(r'\cdot', '*');
    expr = expr.replaceAll(r'\times', '*');
    expr = expr.replaceAll(r'\div', '/');
    expr = expr.replaceAll(r'\pm', '+');
    expr = expr.replaceAll(r'\mp', '-');
    expr = expr.replaceAll(r'\approx', '='); // Handle approximation as equality
    expr = expr.replaceAll(r'\to', ' ');
    expr = expr.replaceAll(r'\rightarrow', ' ');

    // 3. Limits
    expr = expr.replaceAllMapped(RegExp(r'\\lim_\{([^}]*)\}'), (m) => 'lim ');
    expr = expr.replaceAll(r' \lim ', ' lim ');
    expr = expr.replaceAll(r'\lim ', 'lim ');

    // 4. Exponents and Subscripts (removes {} - do this BEFORE fractions to handle nested braces in exp)
    expr = expr.replaceAllMapped(RegExp(r'\^{([^}]*)}'), (m) => '^(${m[1]})');
    expr = expr.replaceAllMapped(RegExp(r'_\{([^}]*)\}'), (m) => '_${m[1]}');

    // 5. Fractions (Recursive, removes {})
    final fracPattern = RegExp(r'\\frac\{([^}]*)\}\{([^}]*)\}');
    while (expr.contains(r'\frac{')) {
      final oldExpr = expr;
      expr = expr.replaceAllMapped(fracPattern, (m) => '(${m[1]})/(${m[2]})');
      if (oldExpr == expr) break;
    }

    // 6. Roots (removes {})
    // \sqrt[n]{x}
    expr = expr.replaceAllMapped(
      RegExp(r'\\sqrt\[([^\]]*)\]\{([^}]*)\}'),
      (m) => '(${m[2]})^(1/${m[1]})',
    );
    // \sqrt{x}
    expr = expr.replaceAllMapped(
      RegExp(r'\\sqrt\{([^}]*)\}'),
      (m) => 'sqrt(${m[1]})',
    );

    // 7. Replace literal functions (e.g. \sin -> sin)
    // Note: \sin is often space separated, but might be attached if braces were removed?
    // Usually \sin x or \sin(x).
    for (final f in [
      'asin',
      'acos',
      'atan',
      'sinh',
      'cosh',
      'tanh',
      'sin',
      'cos',
      'tan',
      'sqrt',
      'exp',
      'log',
      'abs',
      'sec',
      'csc',
      'cot',
      'lim',
      'pow',
    ]) {
      expr = expr.replaceAll('\\$f ', '$f ');
      expr = expr.replaceAll('\\$f(', '$f(');
      // Also catch cases where space might have been removed or not present
      // e.g. \sinx -> sinx (then split).
      // Use regex to be safe
      expr = expr.replaceAllMapped(RegExp('\\\\$f(?![a-zA-Z])'), (m) => f);
    }

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
      r'\pi': 'PI',
      r'\infty': 'INF',
    };
    greekMap.forEach((k, v) => expr = expr.replaceAll(k, v));

    // Special case for Delta/delta as prefix for change (Delta t)
    expr = expr.replaceAllMapped(
      RegExp(r'(\b[Dd]elta)\s+([a-zA-Z])'),
      (m) => '${m[1]}${m[2]}',
    );

    // Implicit Multiplication

    // Implicit Multiplication & Repair - All REMOVED for Explicit Compliance.

    // 5. Letter followed by ( (G (...) -> G*(...)) - REMOVED

    // Normalize standalone 'i' to 'IN' (imaginary unit internal token)
    // This ensures consistency between extractVariables and substitution
    expr = expr.replaceAllMapped(
      RegExp(r'(?<![a-zA-Z])i(?![a-zA-Z])'),
      (m) => 'IN',
    );

    return expr;
  }

  /// Formats a value for re-parsing (uses IN instead of i for complex).
  /// Formats a value for re-parsing (uses IN instead of i for complex).
  static String _formatForParsing(dynamic value) {
    if (value is Complex) {
      String fmt(double v) => v.toString();

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
      if (value.isNaN) return 'NaN';
      if (value.isInfinite) return 'Infinity';
      // Use standard string representation to preserve precision/scientific notation
      return value.toString();
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

  static bool _isValidValue(dynamic val) {
    if (val is double && val.isInfinite) return true; // Allow explicit infinity
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

    // If values are small (or comparing against zero), use absolute difference
    // handling approximation errors (e.g. user input 2.7183 for e)
    if (maxVal < 1e-3) return absDiff < 1e-4;

    // Otherwise use relative difference
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

      if (!_isValidValue(f0) || !_isValidValue(f1) || !_isValidValue(fm1)) {
        return null;
      }

      // Convert to doubles for coefficient extraction
      double c = _toDouble(f0);
      double sumF = _toDouble(f1) + _toDouble(fm1);
      double diffF = _toDouble(f1) - _toDouble(fm1);

      double a = sumF / 2 - c;
      double b = diffF / 2;

      // Check if it's an identity (0 = 0): all coefficients approximately zero
      if (a.abs() < 1e-3 && b.abs() < 1e-3 && c.abs() < 1e-3) {
        return null; // Let _solveNumerically detect as identity
      }

      // Check if it's actually quadratic (a ≠ 0)
      if (a.abs() < 1e-30) {
        // Linear equation: bx + c = 0 -> x = -c/b
        // Use a very small epsilon to allow physics constants like h (6e-34)
        if (b.abs() > 1e-50) {
          return -c / b;
        }
        return null; // No solution or infinite solutions
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

        // Sort to prefer positive roots first (UX improvement)
        final roots = [x1, x2];
        roots.sort((a, b) => b.compareTo(a)); // Descending: 14, -14
        return roots;
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
    // Relax threshold to handle user approximations (e.g., e ≈ 2.7183)
    if (val is Complex && val.imaginary.abs() < 1e-4) return val.real;
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
      if (left is num) {
        l = left.toDouble();
      } else if (left is Complex) {
        l = left.real;
      }
      if (right is num) {
        r = right.toDouble();
      } else if (right is Complex) {
        r = right.real;
      }
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

    // Check for Identity (True for all x)
    // If f(x) is ~0 for two distinct random points, it's likely an identity.
    final f0 = f(0.12345); // Random non-integer points
    final f1 = f(1.67890);
    if (!f0.isNaN && !f1.isNaN && f0.abs() < 1e-3 && f1.abs() < 1e-3) {
      return double.infinity; // Infinite solutions (Identity)
    }

    // Try Newton's method from various starting points
    for (final x0 in [0.0, 1.0, -1.0, 10.0, -10.0, 100.0, -100.0, 4.0]) {
      final root = _newton(f, x0, 1e-12, 100);
      if (root != null && root.isFinite && f(root).abs() < 1e-3) {
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
