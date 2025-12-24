import 'package:functionx/functionx.dart';

void main() {
  print('=== Testing EquationParser with Complex(1,5) ===\n');

  final equation = 'y=x';
  final values = {'x': Complex(1, 5)};
  final solveFor = 'y';

  print('Equation: $equation');
  print('Values: $values');
  print('Solve for: $solveFor');
  print('');

  final result = EquationParser.solve(
    equation,
    values,
    solveFor: solveFor,
  );

  print('=== Result ===');
  print('solvedValue: ${result.solvedValue}');
  print('solvedValue type: ${result.solvedValue?.runtimeType}');
  print('error: ${result.error}');
  print('');

  print('=== Steps ===');
  for (final step in result.steps) {
    print('Step type: ${step.type}');
    print('Step data: ${step.data}');
    print('');
  }

  // Also test direct evaluation with IN
  print('\n=== Test evaluating "1+5*IN" ===');
  final evalResult = EquationParser.evaluate('1+5*IN');
  print('Result: $evalResult (${evalResult.runtimeType})');
}
