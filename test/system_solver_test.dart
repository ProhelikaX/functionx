import 'package:functionx/functionx.dart';
import 'package:test/test.dart';

void main() {
  group('SystemSolver', () {
    test('solves linear system', () {
      // x + y = 3
      // x - y = 1
      // Solution: x = 2, y = 1
      final result = SystemSolver.solve(['x + y = 3', 'x - y = 1']);

      expect(
        result.success,
        isTrue,
        reason: 'Failed with error: ${result.error}',
      );
      expect(result.values['x']!.real, closeTo(2.0, 1e-6));
      expect(result.values['y']!.real, closeTo(1.0, 1e-6));
    });

    test('solves non-linear system (circle and line)', () {
      // x^2 + y^2 = 1
      // y = x
      // Solution: x = +/- 1/sqrt(2), y = +/- 1/sqrt(2)
      // With initial guess (0.5, 0.5), should find positive root
      final result = SystemSolver.solve(
        ['x^2 + y^2 = 1', 'y = x'],
        initialGuess: {'x': 0.5, 'y': 0.5},
      );

      expect(result.success, isTrue);
      expect(result.values['x']!.real, closeTo(0.70710678, 1e-6));
      expect(result.values['y']!.real, closeTo(0.70710678, 1e-6));
    });

    test('solves non-linear system (circle and line) negative root', () {
      final result = SystemSolver.solve(
        ['x^2 + y^2 = 1', 'y = x'],
        initialGuess: {'x': -0.5, 'y': -0.5},
      );

      expect(result.success, isTrue);
      expect(result.values['x']!.real, closeTo(-0.70710678, 1e-6));
      expect(result.values['y']!.real, closeTo(-0.70710678, 1e-6));
    });

    test('solves 3-variable linear system', () {
      // x + y + z = 6
      // 2x + y - z = 1
      // x - y + z = 2
      // Solution: x=1, y=2, z=3
      final result = SystemSolver.solve([
        'x + y + z = 6',
        '2*x + y - z = 1',
        'x - y + z = 2',
      ]);

      expect(result.success, isTrue);
      expect(result.values['x']!.real, closeTo(1.0, 1e-6));
      expect(result.values['y']!.real, closeTo(2.0, 1e-6));
      expect(result.values['z']!.real, closeTo(3.0, 1e-6));
    });

    test('solves complex system', () {
      // x^2 + 1 = 0
      // Solution: x = +/- i
      final result = SystemSolver.solve(
        ['x^2 + 1 = 0'],
        initialGuess: {'x': Complex(0, 0.5)}, // Guess near i
      );

      expect(result.success, isTrue);
      expect(result.values['x']!.real, closeTo(0.0, 1e-6));
      expect(result.values['x']!.imaginary, closeTo(1.0, 1e-6));
    });

    test('handles mismatched variables and equations', () {
      final result = SystemSolver.solve(['x + y = 3']);
      expect(result.success, isFalse);
      expect(result.error, contains('Number of variables'));
    });

    test('handles parsing errors', () {
      final result = SystemSolver.solve(['x + = 3']);
      expect(result.success, isFalse);
      expect(result.error, contains('Failed to parse'));
    });
  });
}
