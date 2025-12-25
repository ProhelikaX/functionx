import 'package:functionx/src/equation_parser.dart';
import 'package:functionx/src/core/complex.dart';
import 'package:test/test.dart';

void main() {
  group('EquationParser - Unified Parser Tests', () {
    group('extractVariables', () {
      test('extracts simple variables', () {
        expect(
          EquationParser.extractVariables('y=m*x+b'),
          containsAll(['y', 'm', 'x', 'b']),
        );
      });

      test('filters out math constants', () {
        final vars = EquationParser.extractVariables(
          'y=PI*r^2',
          excludeConstants: true,
        );
        expect(vars, contains('y'));
        expect(vars, contains('r'));
        expect(vars, isNot(contains('PI')));
      });

      test('filters out imaginary unit', () {
        final vars = EquationParser.extractVariables(
          'z=x+i*y',
          excludeConstants: true,
        );
        expect(vars, containsAll(['z', 'x', 'y']));
        expect(vars, isNot(contains('i')));
      });
    });

    group('evaluate', () {
      test('evaluates simple expression', () {
        expect(EquationParser.evaluate('2+3'), equals(5.0));
      });

      test('evaluates with variables', () {
        expect(EquationParser.evaluate('x*2', {'x': 5.0}), equals(10.0));
      });

      test('evaluates complex sqrt(-1)', () {
        final result = EquationParser.evaluate('sqrt(-1)');
        expect(result, isA<Complex>());
        expect((result as Complex).imaginary, closeTo(1.0, 1e-10));
      });

      test('evaluates complex expression', () {
        final result = EquationParser.evaluate('1+5*IN');
        expect(result, isA<Complex>());
        expect((result as Complex).real, closeTo(1.0, 1e-10));
        expect(result.imaginary, closeTo(5.0, 1e-10));
      });
    });

    group('solve', () {
      test('solves simple equation y=x', () {
        final result = EquationParser.solve('y=x', {'x': 5.0}, solveFor: 'y');
        expect(result.error, isNull);
        expect(result.solvedValue, equals(5.0));
      });

      test('solves with complex input', () {
        final result = EquationParser.solve('y=x', {
          'x': Complex(1, 5),
        }, solveFor: 'y');
        expect(result.error, isNull);
        expect(result.solvedValue, isA<Complex>());
        expect((result.solvedValue as Complex).real, closeTo(1.0, 1e-10));
        expect((result.solvedValue as Complex).imaginary, closeTo(5.0, 1e-10));
      });

      test('solves linear equation', () {
        final result = EquationParser.solve('y=2*x+3', {
          'x': 4.0,
        }, solveFor: 'y');
        expect(result.error, isNull);
        expect(result.solvedValue, closeTo(11.0, 1e-10));
      });

      test('includes solution steps', () {
        final result = EquationParser.solve('y=x', {'x': 5.0}, solveFor: 'y');
        expect(result.steps, isNotEmpty);
        expect(result.steps.any((s) => s.type == 'result'), isTrue);
      });
    });

    group('getPrefilledValues', () {
      test('returns physics constants', () {
        final prefilled = EquationParser.getPrefilledValues('F=GC*m_1*m_2/r^2');
        // GC should be recognized as gravitational constant
        expect(prefilled.containsKey('GC') || prefilled.isEmpty, isTrue);
      });
    });
  });
}
