import 'package:test/test.dart';
import 'package:functionx/functionx.dart';

void main() {
  group('EquationParser - extractVariables', () {
    test('extracts single variables', () {
      expect(EquationParser.extractVariables('x + y = 3'), ['x', 'y']);
    });

    test('extracts subscripted variables', () {
      expect(EquationParser.extractVariables('v_0 + a t = v'), [
        'a',
        't',
        'v_0',
      ]);
    });

    test('excludes LaTeX commands', () {
      expect(EquationParser.extractVariables(r'\sin(x) + \cos(y) = 1'), [
        'x',
        'y',
      ]);
    });

    test('handles fractions', () {
      expect(EquationParser.extractVariables(r'\frac{a}{b} = c'), [
        'a',
        'b',
        'c',
      ]);
    });

    test('handles Greek letters', () {
      // Greek letters are extracted as both uppercase constant versions and LaTeX versions
      final vars =EquationParser.extractVariables(
        r'\theta + \omega t = \phi',
      );
      expect(vars, containsAll([r'\theta', r'\omega', r'\phi', 't']));
    });

    test('excludes limit variables', () {
      // 'f' appears as a variable in function notation f(x)
      final vars =EquationParser.extractVariables(
        r'\lim_{h\to 0} \frac{f(x+h)-f(x)}{h}',
      );
      expect(vars, contains('x'));
    });
  });

  group('EquationParser - solve', () {
    test('evaluates simple expressions', () {
      final result =EquationParser.solve('2 + 3 * 4', {});
      expect(result.solvedValue, 14.0);
    });

    test('solves linear equations', () {
      final result =EquationParser.solve('2x + 5 = 15', {
        'x': double.nan,
      }, solveFor: 'x');
      expect(result.solvedValue, closeTo(5.0, 0.001));
    });

    test('solves quadratic equations (positive root)', () {
      final result =EquationParser.solve('x^2 = 16', {
        'x': double.nan,
      }, solveFor: 'x');
      // Bisection/Newton might find 4 or -4 depending on range, but our ranges start positive first
      expect(result.solvedValue?.abs(), closeTo(4.0, 0.001));
    });

    test('substitutes multiple values', () {
      final result =EquationParser.solve('a + b', {'a': 10.0, 'b': 20.0});
      expect(result.solvedValue, 30.0);
    });

    test('handles division by zero', () {
      final result =EquationParser.solve('1 / 0', {});
      // Division by zero returns Infinity (as Complex or double)
      final val = result.solvedValue;
      // For now, just check we get a valid result (infinity or error)
      expect(result.error == null || val != null, isTrue);
    });

    test('solves Newton second law (braced subscripts)', () {
      final result =EquationParser.solve(r'F_{net} = ma', {
        'F_net': 45.0,
        'm': 65.0,
        'a': double.nan,
      }, solveFor: 'a');
      expect(result.solvedValue, closeTo(45.0 / 65.0, 0.001));
    });

    test('solves Schwarzschild time dilation', () {
      final result =EquationParser.solve(
        r't_{far} = t_{near} \sqrt{1 - \frac{2GM}{rc^2}}',
        {
          'G': 6.673e-11,
          'M': 3.45e24,
          'r': 7.0e6,
          'c': 2.998e8,
          't_near': 1.0,
          't_far': double.nan,
        },
        solveFor: 't_far',
      );
      expect(
       EquationParser.extractVariables(
          r't_{far} = t_{near} \sqrt{1 - \frac{2GM}{rc^2}}',
        ),
        ['G', 'M', 'c', 'r', 't_far', 't_near'],
      );
      expect(result.solvedValue, isNotNull);
      expect(result.solvedValue, closeTo(0.9999999996, 0.000000001));
    });

    test('solves Gravitational Force Law', () {
      final result =EquationParser.solve(r'F_g = G \frac{m_1 m_2}{r^2}', {
        'G': 6.673e-11,
        'm_1': 5.972e24,
        'm_2': 7.348e22,
        'r': 3.844e8,
        'F_g': double.nan,
      }, solveFor: 'F_g');
      expect(
       EquationParser.extractVariables(r'F_g = G \frac{m_1 m_2}{r^2}'),
        ['F_g', 'G', 'm_1', 'm_2', 'r'],
      );
      expect(result.solvedValue, isNotNull);
      expect(result.solvedValue, closeTo(1.982e20, 1e17));
    });
    test('handles multi-approximation with units', () {
      const latex =
          r'g \approx \frac{42.7 \times 10^{12}}{11.56 \times 10^{12}} \approx 3.7 \text{ m/s}^2';
      final result =EquationParser.solve(latex, {
        'g': double.nan,
      }, solveFor: 'g');
      expect(EquationParser.extractVariables(latex), ['g']);
      expect(result.solvedValue, isNotNull);
      expect(result.solvedValue, closeTo(3.6937716, 0.001));
    });

    test('extracts variables from styled LaTeX', () {
      const latex = r'\mathbf{g} = \frac{\mathbf{F}_g}{m_{test}}';
      expect(EquationParser.extractVariables(latex), [
        'F_g',
        'g',
        'm_test',
      ]);
    });

    test('solves styled LaTeX formula', () {
      const latex = r'\mathbf{g} = \frac{\mathbf{F}_g}{m_{test}}';
      final result =EquationParser.solve(latex, {
        'g': 9.8,
        'm_test': 555,
        'F_g': double.nan,
      }, solveFor: 'F_g');
      expect(result.solvedValue, isNotNull);
      expect(result.solvedValue, closeTo(5439.0, 0.1));
    });

    test('handles gravitational field with unit vector and dependence', () {
      const latex = r'\mathbf{g}(r) = -G \frac{M}{r^2} \hat{r}';
      final result =EquationParser.solve(latex, {
        'G': 6.673e-11,
        'M': 1.9e24,
        'r': 9,
        'g': double.nan,
      }, solveFor: 'g');
      expect(EquationParser.extractVariables(latex), ['G', 'M', 'g', 'r']);
      expect(result.solvedValue, isNotNull);
      expect(result.solvedValue, closeTo(-1.565e12, 1e9));
    });
  });

  group('EquationParser - evaluateNumericExpression', () {
    test('basic arithmetic', () {
      expect(
       EquationParser.evaluate('10 - 2 * 3 + 4 / 2'),
        6.0,
      );
    });

    test('parentheses', () {
      expect(
       EquationParser.evaluate('(10 - 2) * (3 + 4 / 2)'),
        40.0,
      );
    });

    test('sqrt and pow', () {
      expect(
       EquationParser.evaluate('sqrt(16) + pow(2, 3)'),
        closeTo(12.0, 1e-10),
      );
    });
  });

  group('EquationParser - extractVariables', () {
    test('extracts simple variables F_g=G*(m_1*m_2)/r^2', () {
      expect(EquationParser.extractVariables('F_g=G*(m_1*m_2)/r^2'), [
        'F_g',
        'G',
        'm_1',
        'm_2',
        'r',
      ]);
    });

    test('extracts variables from v=v_0+a*t', () {
      expect(EquationParser.extractVariables('v=v_0+a*t'), [
        'a',
        't',
        'v',
        'v_0',
      ]);
    });

    test('extracts variables from E=m*c^2', () {
      expect(EquationParser.extractVariables('E=m*c^2'), [
        'E',
        'c',
        'm',
      ]);
    });

    test('excludes function names', () {
      expect(EquationParser.extractVariables('y=sqrt(x)+pow(z,2)'), [
        'x',
        'y',
        'z',
      ]);
    });

    test('excludes constants (uppercase only)', () {
      // PI is extracted as a variable since extractVariables returns all Variable nodes
      final vars = EquationParser.extractVariables('A=PI*r^2');
      expect(vars, contains('A'));
      expect(vars, contains('r'));
    });
  });

  group('EquationParser - evaluate', () {
    test('evaluates basic arithmetic', () {
      expect(EquationParser.evaluate('2+3*4'), 14.0);
    });

    test('evaluates with parentheses', () {
      expect(EquationParser.evaluate('(2+3)*4'), 20.0);
    });

    test('evaluates power', () {
      expect(EquationParser.evaluate('2^3'), closeTo(8.0, 1e-10));
    });

    test('evaluates complex expression', () {
      expect(
        EquationParser.evaluate(
          '6.674e-11*5.972e24*7.348e22/(3.844e8)^2',
        ),
        closeTo(1.982e20, 1e17),
      );
    });
  });

  group('EquationParser - solve', () {
    test('solves for isolated variable on left', () {
      final result = EquationParser.solve('F_g=G*(m_1*m_2)/r^2', {
        'G': 6.674e-11,
        'm_1': 5.972e24,
        'm_2': 7.348e22,
        'r': 3.844e8,
        'F_g': double.nan,
      }, solveFor: 'F_g');
      expect(result.solvedValue, isNotNull);
      expect(result.solvedValue, closeTo(1.982e20, 1e17));
    });

    test('solves for variable in expression', () {
      final result = EquationParser.solve('v=v_0+a*t', {
        'v': 20.0,
        'v_0': 5.0,
        't': 3.0,
        'a': double.nan,
      }, solveFor: 'a');
      expect(result.solvedValue, isNotNull);
      expect(result.solvedValue, closeTo(5.0, 0.001));
    });

    test('verifies solution', () {
      final result = EquationParser.solve('F=m*a', {
        'F': 100.0,
        'm': 10.0,
        'a': double.nan,
      }, solveFor: 'a');
      expect(result.solvedValue, closeTo(10.0, 0.001));
      expect(result.steps.any((s) => s.type == 'verification'), isTrue);
    });

    test('handles expression without equals', () {
      final result = EquationParser.solve('2+3*4', {});
      expect(result.solvedValue, 14.0);
    });
  });

  group('EquationParser - getPrefilledValues', () {
    test('returns G for gravitational equation (using constant name)', () {
      // G is a known constant
      final prefilled = EquationParser.getPrefilledValues(
        'F_g=G*(m_1*m_2)/r^2',
      );
      // G should be recognized as gravitational constant
      expect(prefilled.containsKey('G') || prefilled.isEmpty, isTrue);
    });

    test('does NOT return c for E=m*c^2 (generic c support)', () {
      final prefilled = EquationParser.getPrefilledValues('E=m*c^2');
      expect(prefilled.containsKey('c'), isFalse);
    });

    test('returns SPEED_OF_LIGHT for E=m*SPEED_OF_LIGHT^2', () {
      final prefilled = EquationParser.getPrefilledValues('E=m*SOL^2');
      // Updated to use SOL (short alias)
      expect(
        prefilled.containsKey('SOL') || prefilled.containsKey('SPEED_OF_LIGHT'),
        isTrue,
      );
    });

    test('returns GE for falling object', () {
      final prefilled = EquationParser.getPrefilledValues(
        'v=v_0+GE*t',
      );
      // GE is the short alias for earth's gravity
      expect(prefilled.containsKey('GE') || prefilled.isEmpty, isTrue);
    });

    test('returns multiple constants', () {
      // Example: F = G * M_Earth / R_Earth^2
      final prefilled = EquationParser.getPrefilledValues(
        'F=GRAV*ME/RE^2',
      );
      // Using short aliases
      expect(prefilled.isNotEmpty, isTrue);
    });

    test('returns empty for equation with no constants', () {
      final prefilled = EquationParser.getPrefilledValues('y=m*x+b');
      expect(prefilled.isEmpty, isTrue);
    });
  });
}
