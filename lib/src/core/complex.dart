import 'dart:math' as math;

/// Represents a complex number z = real + imaginary * i
class Complex {
  final double real;
  final double imaginary;

  const Complex(this.real, [this.imaginary = 0]);

  static const i = Complex(0, 1);
  static const one = Complex(1, 0);
  static const zero = Complex(0, 0);

  bool get isReal => imaginary == 0;
  bool get isNaN => real.isNaN || imaginary.isNaN;
  bool get isInfinite => real.isInfinite || imaginary.isInfinite;
  bool get isFinite => real.isFinite && imaginary.isFinite;

  // Basic arithmetic
  Complex operator +(Object other) {
    if (other is Complex) {
      return Complex(real + other.real, imaginary + other.imaginary);
    } else if (other is num) {
      return Complex(real + other, imaginary);
    }
    throw ArgumentError('Cannot add Complex to ${other.runtimeType}');
  }

  Complex operator -(Object other) {
    if (other is Complex) {
      return Complex(real - other.real, imaginary - other.imaginary);
    } else if (other is num) {
      return Complex(real - other, imaginary);
    }
    throw ArgumentError('Cannot subtract ${other.runtimeType} from Complex');
  }

  Complex operator *(Object other) {
    if (other is Complex) {
      return Complex(
        real * other.real - imaginary * other.imaginary,
        real * other.imaginary + imaginary * other.real,
      );
    } else if (other is num) {
      return Complex(real * other, imaginary * other);
    }
    throw ArgumentError('Cannot multiply Complex by ${other.runtimeType}');
  }

  Complex operator /(Object other) {
    if (other is Complex) {
      final denom = other.real * other.real + other.imaginary * other.imaginary;
      return Complex(
        (real * other.real + imaginary * other.imaginary) / denom,
        (imaginary * other.real - real * other.imaginary) / denom,
      );
    } else if (other is num) {
      return Complex(real / other, imaginary / other);
    }
    throw ArgumentError('Cannot divide Complex by ${other.runtimeType}');
  }

  Complex operator -() => Complex(-real, -imaginary);

  // Functions
  double abs() => math.sqrt(real * real + imaginary * imaginary);

  Complex sqrt() {
    final r = abs();
    return Complex(
      math.sqrt((r + real) / 2),
      (imaginary >= 0 ? 1 : -1) * math.sqrt((r - real) / 2),
    );
  }

  Complex exp() {
    final ea = math.exp(real);
    return Complex(ea * math.cos(imaginary), ea * math.sin(imaginary));
  }

  Complex log() {
    return Complex(math.log(abs()), math.atan2(imaginary, real));
  }

  Complex pow(Object exponent) {
    if (exponent is num) return pow(Complex(exponent.toDouble()));
    if (exponent is Complex) {
      if (real == 0 && imaginary == 0) return Complex.zero;
      // a^b = exp(b * log(a))
      return (exponent * log()).exp();
    }
    throw ArgumentError('Invalid exponent type');
  }

  static double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;
  static double _cosh(double x) => (math.exp(x) + math.exp(-x)) / 2;

  Complex sin() {
    return Complex(
      math.sin(real) * _cosh(imaginary),
      math.cos(real) * _sinh(imaginary),
    );
  }

  Complex cos() {
    return Complex(
      math.cos(real) * _cosh(imaginary),
      -math.sin(real) * _sinh(imaginary),
    );
  }

  Complex tan() {
    final d = math.cos(2 * real) + _cosh(2 * imaginary);
    return Complex(math.sin(2 * real) / d, _sinh(2 * imaginary) / d);
  }

  @override
  String toString() {
    if (isNaN) return 'NaN';

    // Formatting helper
    String fmt(double v) {
      if (v == v.roundToDouble()) return v.toInt().toString();
      return v.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
    }

    if (imaginary == 0) return fmt(real);

    final sign = imaginary >= 0 ? '+' : '-';
    final im = imaginary.abs();

    // Special case for just "i" or "-i"
    final imStr = im == 1 ? 'i' : '${fmt(im)}i';

    if (real == 0) return imaginary >= 0 ? imStr : '-$imStr';

    return '${fmt(real)} $sign $imStr';
  }
}
