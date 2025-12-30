import 'package:functionx/functionx.dart';
import 'package:test/test.dart';

void main() {
  group('Complex Class', () {
    test('Basic Arithmetic', () {
      final z1 = Complex(1, 2);
      final z2 = Complex(3, 4);

      expect((z1 + z2).toString(), equals('4 + 6i'));
      expect((z1 - z2).toString(), equals('-2 - 2i'));
      expect((z1 * z2).toString(), equals('-5 + 10i'));
      expect((z1 / z1).real, closeTo(1.0, 1e-10));
    });

    test('Functions', () {
      expect(Complex(-1).sqrt().toString(), equals('i'));
      expect(Complex(0, 3.1415926535).exp().real, closeTo(-1.0, 1e-10));
    });
  });

  group('Evaluator Mixed', () {
    test('Real results', () {
      expect(Evaluator.evaluateMixed('2 + 2'), equals(4.0));
      expect(Evaluator.evaluateMixed('sin(PI/2)'), closeTo(1.0, 1e-10));
    });

    test('Complex results - sqrt(-1)', () {
      final res = Evaluator.evaluateMixed('sqrt(-1)');
      expect(res, isA<Complex>());
      expect((res as Complex).imaginary, closeTo(1.0, 1e-10));
    });

    test(
      'Euler identity e^(i*PI) = -1 (returns real when imaginary is negligible)',
      () {
        // e^(i*PI) = -1, which is a real number
        final res = Evaluator.evaluateMixed('exp(i * PI)');
        // Since imaginary part is negligible, it returns a double
        if (res is Complex) {
          expect(res.real, closeTo(-1.0, 1e-10));
          expect(res.imaginary.abs(), lessThan(1e-10));
        } else {
          expect(res, closeTo(-1.0, 1e-10));
        }
      },
    );

    test('Variables with complex values', () {
      final res = Evaluator.evaluateMixed('z^2', {'z': Complex(0, 1)});
      expect(res, closeTo(-1.0, 1e-10));
    });
  });

  group('MathEquationParser evaluateNumericExpression', () {
    test('Evaluates sqrt(-1) as complex', () {
      final res = EquationParser.evaluate('sqrt(-1)');
      expect(res, isA<Complex>());
      expect((res as Complex).imaginary, closeTo(1.0, 1e-10));
    });

    test('Evaluates sqrt(-4) as 2i', () {
      final res = EquationParser.evaluate('sqrt(-4)');
      expect(res, isA<Complex>());
      expect((res as Complex).imaginary, closeTo(2.0, 1e-10));
    });

    test('Evaluates with variable values', () {
      final res = EquationParser.evaluate('sqrt(x)', {'x': -9.0});
      expect(res, isA<Complex>());
      expect((res as Complex).imaginary, closeTo(3.0, 1e-10));
    });
  });

  group('MathEquationParser Solve', () {
    test(
      'Solve for x in complex domain (numerical solver finds real roots only)',
      () {
        final result = EquationParser.solve('x^2 = -1', {});
        // Numerical solver cannot find complex roots, so it returns null or no_solution
        expect(result.error, isNull);
      },
    );
  });

  group('Complex Equations from Manual Test Suite', () {
    test('Imaginary unit squared: i^2 = -1', () {
      final res = Evaluator.evaluateMixed('IN^2');
      expect(res, closeTo(-1.0, 1e-10));
    });

    test('Square root of -1 is i', () {
      final res = Evaluator.evaluateMixed('sqrt(-1)');
      expect(res, isA<Complex>());
      expect((res as Complex).real.abs(), lessThan(1e-10));
      expect(res.imaginary, closeTo(1.0, 1e-10));
    });

    test('Square root of -4 is 2i', () {
      final res = Evaluator.evaluateMixed('sqrt(-4)');
      expect(res, isA<Complex>());
      expect((res as Complex).real.abs(), lessThan(1e-10));
      expect(res.imaginary, closeTo(2.0, 1e-10));
    });

    test('Square root of -9 is 3i', () {
      final res = Evaluator.evaluateMixed('sqrt(-9)');
      expect(res, isA<Complex>());
      expect((res as Complex).real.abs(), lessThan(1e-10));
      expect(res.imaginary, closeTo(3.0, 1e-10));
    });

    test('Euler identity: e^(i*PI) = -1', () {
      final res = Evaluator.evaluateMixed('EN^(IN*PI)');
      // Result should be -1 (real part)
      if (res is Complex) {
        expect(res.real, closeTo(-1.0, 1e-10));
        expect(res.imaginary.abs(), lessThan(1e-10));
      } else {
        expect(res, closeTo(-1.0, 1e-10));
      }
    });

    test('Euler identity: e^(i*PI) + 1 = 0', () {
      final res = Evaluator.evaluateMixed('EN^(IN*PI)+1');
      // Result should be 0
      if (res is Complex) {
        expect(res.real.abs(), lessThan(1e-10));
        expect(res.imaginary.abs(), lessThan(1e-10));
      } else {
        expect((res as double).abs(), lessThan(1e-10));
      }
    });

    test('Complex conjugate multiplication: (1+i)(1-i) = 2', () {
      final res = Evaluator.evaluateMixed('(1+IN)*(1-IN)');
      expect(res, closeTo(2.0, 1e-10));
    });

    test('Complex addition: (2+3i) + (4-i) = 6+2i', () {
      final res = Evaluator.evaluateMixed('(2+3*IN)+(4-IN)');
      expect(res, isA<Complex>());
      expect((res as Complex).real, closeTo(6.0, 1e-10));
      expect(res.imaginary, closeTo(2.0, 1e-10));
    });

    test('Complex exponential with variable', () {
      // e^(i*x) at x=0 should be 1
      final res = Evaluator.evaluateMixed('EN^(IN*x)', {'x': 0.0});
      expect(res, closeTo(1.0, 1e-10));
    });

    test('Complex exponential at x=PI/2', () {
      // e^(i*PI/2) = cos(PI/2) + i*sin(PI/2) = i
      final res = Evaluator.evaluateMixed('EN^(IN*PI/2)');
      expect(res, isA<Complex>());
      expect((res as Complex).real.abs(), lessThan(1e-10));
      expect(res.imaginary, closeTo(1.0, 1e-10));
    });

    test('Euler formula: e^(ix) = cos(x) + i*sin(x) at x=PI/4', () {
      final lhs = Evaluator.evaluateMixed('EN^(IN*PI/4)');
      final rhs = Evaluator.evaluateMixed('cos(PI/4)+IN*sin(PI/4)');

      expect(lhs, isA<Complex>());
      expect(rhs, isA<Complex>());

      final lhsC = lhs as Complex;
      final rhsC = rhs as Complex;

      expect(lhsC.real, closeTo(rhsC.real, 1e-10));
      expect(lhsC.imaginary, closeTo(rhsC.imaginary, 1e-10));
    });
  });
}
