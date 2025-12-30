import 'package:functionx/functionx.dart';

void main() {
  print('=== functionx Examples ===\n');

  // 1. Variable Extraction
  print('1. Variable Extraction');
  print('-' * 40);
  final equation = 'F = m*a';
  final vars = ExpressionParser.extractVariables(equation);
  print('Equation: $equation');
  print('Variables: $vars');
  print('');

  // 2. Expression Evaluation
  print('2. Expression Evaluation');
  print('-' * 40);
  final expr = 'x^2 + 2*x + 1';
  final result = Evaluator.evaluate(expr, {'x': 3});
  print('Expression: $expr');
  print('With x = 3: $result');
  print('');

  // 3. Equation Solving
  print('3. Equation Solving');
  print('-' * 40);
  final solution = Solver.solve('F = m*a', {'F': 10, 'm': 2}, solveFor: 'a');
  print('Equation: F = m*a');
  print('Given: F = 10, m = 2');
  print('Solving for a: ${solution.value}');
  print('');

  // 4. Numerical Solving
  print('4. Numerical Solving');
  print('-' * 40);
  final numSolution = Solver.solve('x^2 - 4 = 0', {'x': null});
  print('Equation: x^2 - 4 = 0');
  print('Solution: x = ${numSolution.value}');
  print('Method: ${numSolution.isNumeric ? "Numerical" : "Algebraic"}');
  print('');

  // 5. Symbolic Differentiation
  print('5. Symbolic Differentiation');
  print('-' * 40);
  final derivative = Cas.differentiate('x^3', 'x');
  print('d/dx(x^3) = $derivative');
  print('');

  // 6. Symbolic Integration
  print('6. Symbolic Integration');
  print('-' * 40);
  final integral = Cas.integrate('x^2', 'x');
  print('∫ x^2 dx = $integral');
  print('');

  // 7. Trig Functions
  print('7. Trigonometric Functions');
  print('-' * 40);
  final trigResult = Evaluator.evaluateNumeric('sin(PI/2)');
  print('sin(π/2) = $trigResult');
  final cosResult = Evaluator.evaluateNumeric('cos(0)');
  print('cos(0) = $cosResult');
  print('');

  // 8. Complex Expression
  print('8. Complex Expressions');
  print('-' * 40);
  final complexVars = ExpressionParser.extractVariables('KE = 0.5*m*v^2');
  print('Equation: KE = 0.5*m*v^2');
  print('Variables: $complexVars');
  final keResult = Evaluator.evaluate('0.5*m*v^2', {'m': 10, 'v': 5});
  print('With m=10, v=5: KE = $keResult');
  print('');

  // 9. System of Equations
  print('9. System of Equations');
  print('-' * 40);
  final systemResult = SystemSolver.solve(
    ['x^2 + y^2 = 1', 'y = x'],
    initialGuess: {'x': 0.5, 'y': 0.5},
  );

  print('System:');
  print('  x^2 + y^2 = 1');
  print('  y = x');
  if (systemResult.success) {
    print('Solution:');
    systemResult.values.forEach((k, v) {
      if (v.isReal) {
        print('  $k = ${v.real.toStringAsFixed(4)}');
      } else {
        print(
          '  $k = ${v.real.toStringAsFixed(4)} + ${v.imaginary.toStringAsFixed(4)}i',
        );
      }
    });
  } else {
    print('Failed: ${systemResult.error}');
  }
}
