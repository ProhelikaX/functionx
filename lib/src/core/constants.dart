/// A physical or mathematical constant with its value, name, unit, and display symbol.
///
/// Example:
/// ```dart
/// final c = Constants.speedOfLight;
/// print('${c.name}: ${c.value} ${c.unit}'); // Speed of Light: 299792458 m/s
/// ```
class Constant {
  /// The numeric value of the constant.
  final double value;

  /// Full name of the constant (e.g., "Speed of Light").
  final String name;

  /// The unit of measurement (e.g., "m/s", "J⋅s").
  final String unit;

  /// Symbol used for display (e.g., "c", "h", "π").
  final String symbol;

  /// Key used for matching in equations (e.g., "SPEED_OF_LIGHT").
  final String key;

  /// Category of the constant (e.g., "fundamental", "electromagnetic").
  final String category;

  const Constant({
    required this.value,
    required this.name,
    required this.unit,
    required this.symbol,
    required this.key,
    required this.category,
  });

  @override
  String toString() => '$symbol = $value $unit ($name)';
}

/// A comprehensive collection of physical and mathematical constants.
///
/// Constants are organized by category:
/// - **Mathematical**: π, e, φ (golden ratio)
/// - **Fundamental**: Speed of light, Planck constant, Gravitational constant
/// - **Electromagnetic**: Vacuum permittivity, permeability, elementary charge
/// - **Atomic**: Electron mass, proton mass, Bohr radius
/// - **Thermodynamic**: Boltzmann constant, gas constant, Avogadro number
/// - **Earth & Celestial**: Standard gravity, Earth mass/radius, Sun mass
///
/// Example usage:
/// ```dart
/// // Access by property
/// final c = Constants.speedOfLight;
/// print(c.value); // 299792458
///
/// // Get by key
/// final g = Constants.get('G');
/// print(g?.value); // 6.6743e-11
///
/// // List all constants in a category
/// final fundamental = Constants.byCategory('fundamental');
/// ```
class Constants {
  Constants._(); // Prevent instantiation

  // ═══════════════════════════════════════════════════════════════════════════
  // MATHEMATICAL CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Pi (π) - ratio of circumference to diameter
  static const pi = Constant(
    value: 3.14159265358979323846,
    name: 'Pi',
    unit: '',
    symbol: 'π',
    key: 'PI',
    category: 'mathematical',
  );

  /// Euler's number (e) - base of natural logarithm
  static const e = Constant(
    value: 2.718281828459045,
    name: "Euler's Number",
    unit: '',
    symbol: 'e',
    key: 'EN',
    category: 'mathematical',
  );

  /// Imaginary Unit (i) - square root of -1
  static const imaginaryUnit = Constant(
    value: double.nan,
    name: 'Imaginary Unit',
    unit: '',
    symbol: 'i',
    key: 'IN',
    category: 'mathematical',
  );

  /// Golden ratio (φ)
  static const goldenRatio = Constant(
    value: 1.618033988749895,
    name: 'Golden Ratio',
    unit: '',
    symbol: 'φ',
    key: 'PHI',
    category: 'mathematical',
  );

  /// Square root of 2
  static const sqrt2 = Constant(
    value: 1.4142135623730951,
    name: 'Square Root of 2',
    unit: '',
    symbol: '√2',
    key: 'SQRT2',
    category: 'mathematical',
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // FUNDAMENTAL PHYSICAL CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Speed of light in vacuum
  static const speedOfLight = Constant(
    value: 299792458,
    name: 'Speed of Light',
    unit: 'm/s',
    symbol: 'c',
    key: 'SOL',
    category: 'fundamental',
  );

  /// Planck constant
  static const planck = Constant(
    value: 6.62607015e-34,
    name: 'Planck Constant',
    unit: 'J⋅s',
    symbol: 'h',
    key: 'PC',
    category: 'fundamental',
  );

  /// Reduced Planck constant (ħ = h/2π)
  static const hBar = Constant(
    value: 1.054571817e-34,
    name: 'Reduced Planck Constant',
    unit: 'J⋅s',
    symbol: 'ħ',
    key: 'HBAR',
    category: 'fundamental',
  );

  /// Gravitational constant
  static const gravitationalConstant = Constant(
    value: 6.67430e-11,
    name: 'Gravitational Constant',
    unit: 'N⋅m²/kg²',
    symbol: 'G',
    key: 'GC',
    category: 'fundamental',
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // ELECTROMAGNETIC CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Elementary charge
  static const elementaryCharge = Constant(
    value: 1.602176634e-19,
    name: 'Elementary Charge',
    unit: 'C',
    symbol: 'e',
    key: 'EC',
    category: 'electromagnetic',
  );

  /// Vacuum permittivity (electric constant)
  static const vacuumPermittivity = Constant(
    value: 8.8541878128e-12,
    name: 'Vacuum Permittivity',
    unit: 'F/m',
    symbol: 'ε₀',
    key: 'VP',
    category: 'electromagnetic',
  );

  /// Vacuum permeability (magnetic constant)
  static const vacuumPermeability = Constant(
    value: 1.25663706212e-6,
    name: 'Vacuum Permeability',
    unit: 'H/m',
    symbol: 'μ₀',
    key: 'VPM',
    category: 'electromagnetic',
  );

  /// Coulomb constant (k = 1/4πε₀)
  static const coulomb = Constant(
    value: 8.9875517923e9,
    name: 'Coulomb Constant',
    unit: 'N⋅m²/C²',
    symbol: 'k',
    key: 'CC',
    category: 'electromagnetic',
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // ATOMIC & PARTICLE CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Electron mass
  static const electronMass = Constant(
    value: 9.1093837015e-31,
    name: 'Electron Mass',
    unit: 'kg',
    symbol: 'mₑ',
    key: 'ME',
    category: 'atomic',
  );

  /// Proton mass
  static const protonMass = Constant(
    value: 1.67262192369e-27,
    name: 'Proton Mass',
    unit: 'kg',
    symbol: 'mₚ',
    key: 'MP',
    category: 'atomic',
  );

  /// Neutron mass
  static const neutronMass = Constant(
    value: 1.67492749804e-27,
    name: 'Neutron Mass',
    unit: 'kg',
    symbol: 'mₙ',
    key: 'MN',
    category: 'atomic',
  );

  /// Bohr radius
  static const bohrRadius = Constant(
    value: 5.29177210903e-11,
    name: 'Bohr Radius',
    unit: 'm',
    symbol: 'a₀',
    key: 'BR',
    category: 'atomic',
  );

  /// Fine structure constant
  static const fineStructure = Constant(
    value: 7.2973525693e-3,
    name: 'Fine Structure Constant',
    unit: '',
    symbol: 'α',
    key: 'FSC',
    category: 'atomic',
  );

  /// Rydberg constant
  static const rydberg = Constant(
    value: 10973731.568160,
    name: 'Rydberg Constant',
    unit: '1/m',
    symbol: 'R∞',
    key: 'RYD',
    category: 'atomic',
  );

  /// Bohr Magneton
  static const bohrMagneton = Constant(
    value: 9.2740100783e-24,
    name: 'Bohr Magneton',
    unit: 'J/T',
    symbol: 'μB',
    key: 'BM',
    category: 'atomic',
  );

  /// Nuclear Magneton
  static const nuclearMagneton = Constant(
    value: 5.0507837461e-27,
    name: 'Nuclear Magneton',
    unit: 'J/T',
    symbol: 'μN',
    key: 'NM',
    category: 'atomic',
  );

  /// Proton-Electron Mass Ratio
  static const protonElectronMassRatio = Constant(
    value: 1836.15267343,
    name: 'Proton-Electron Mass Ratio',
    unit: '',
    symbol: 'mp/me',
    key: 'PEM',
    category: 'atomic',
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // ELECTRO-CHEMICAL & QUANTUM CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Faraday constant
  static const faraday = Constant(
    value: 96485.33212,
    name: 'Faraday Constant',
    unit: 'C/mol',
    symbol: 'F',
    key: 'FC',
    category: 'electrochemical',
  );

  /// Magnetic flux quantum
  static const magneticFluxQuantum = Constant(
    value: 2.067833848e-15,
    name: 'Magnetic Flux Quantum',
    unit: 'Wb',
    symbol: 'Φ₀',
    key: 'MFQ',
    category: 'quantum',
  );

  /// Conductance quantum
  static const conductanceQuantum = Constant(
    value: 7.748091729e-5,
    name: 'Conductance Quantum',
    unit: 'S',
    symbol: 'G₀',
    key: 'CQ',
    category: 'quantum',
  );

  /// Josephson constant
  static const josephson = Constant(
    value: 483597.8484e9,
    name: 'Josephson Constant',
    unit: 'Hz/V',
    symbol: 'KJ',
    key: 'JC',
    category: 'quantum',
  );

  /// Von Klitzing constant
  static const vonKlitzing = Constant(
    value: 25812.8074593043,
    name: 'Von Klitzing Constant',
    unit: 'Ω',
    symbol: 'RK',
    key: 'VK',
    category: 'quantum',
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // THERMODYNAMIC CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Wien displacement law constant
  static const wienDisplacement = Constant(
    value: 2.897771955e-3,
    name: 'Wien Displacement Constant',
    unit: 'm⋅K',
    symbol: 'b',
    key: 'WIE',
    category: 'thermodynamic',
  );

  /// First radiation constant
  static const firstRadiation = Constant(
    value: 3.741771852e-16,
    name: 'First Radiation Constant',
    unit: 'W⋅m²',
    symbol: 'c₁',
    key: 'C1',
    category: 'thermodynamic',
  );

  /// Second radiation constant
  static const secondRadiation = Constant(
    value: 1.438776877e-2,
    name: 'Second Radiation Constant',
    unit: 'm⋅K',
    symbol: 'c₂',
    key: 'C2',
    category: 'thermodynamic',
  );

  /// Boltzmann constant
  static const boltzmann = Constant(
    value: 1.380649e-23,
    name: 'Boltzmann Constant',
    unit: 'J/K',
    symbol: 'kB',
    key: 'BC',
    category: 'thermodynamic',
  );

  /// Avogadro number
  static const avogadro = Constant(
    value: 6.02214076e23,
    name: 'Avogadro Number',
    unit: '1/mol',
    symbol: 'NA',
    key: 'AN',
    category: 'thermodynamic',
  );

  /// Universal gas constant
  static const gasConstant = Constant(
    value: 8.314462618,
    name: 'Gas Constant',
    unit: 'J/(mol⋅K)',
    symbol: 'R',
    key: 'RG',
    category: 'thermodynamic',
  );

  /// Standard atmosphere pressure
  static const standardAtmosphere = Constant(
    value: 101325,
    name: 'Standard Atmosphere',
    unit: 'Pa',
    symbol: 'atm',
    key: 'ATM',
    category: 'thermodynamic',
  );

  /// Stefan-Boltzmann constant
  static const stefanBoltzmann = Constant(
    value: 5.670374419e-8,
    name: 'Stefan-Boltzmann Constant',
    unit: 'W/(m²⋅K⁴)',
    symbol: 'σ',
    key: 'SBC',
    category: 'thermodynamic',
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // EARTH & CELESTIAL CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Standard gravity (Earth surface)
  static const standardGravity = Constant(
    value: 9.80665,
    name: 'Standard Gravity',
    unit: 'm/s²',
    symbol: 'g',
    key: 'SG',
    category: 'earth',
  );

  /// Earth mass
  static const earthMass = Constant(
    value: 5.972e24,
    name: 'Earth Mass',
    unit: 'kg',
    symbol: 'M⊕',
    key: 'EM',
    category: 'earth',
  );

  /// Earth radius (mean)
  static const earthRadius = Constant(
    value: 6.371e6,
    name: 'Earth Radius',
    unit: 'm',
    symbol: 'R⊕',
    key: 'ER',
    category: 'earth',
  );

  /// Sun mass
  static const sunMass = Constant(
    value: 1.989e30,
    name: 'Sun Mass',
    unit: 'kg',
    symbol: 'M☉',
    key: 'SM',
    category: 'celestial',
  );

  /// Sun radius
  static const sunRadius = Constant(
    value: 6.96e8,
    name: 'Sun Radius',
    unit: 'm',
    symbol: 'R☉',
    key: 'SR',
    category: 'celestial',
  );

  /// Astronomical unit
  static const astronomicalUnit = Constant(
    value: 1.495978707e11,
    name: 'Astronomical Unit',
    unit: 'm',
    symbol: 'AU',
    key: 'AU',
    category: 'celestial',
  );

  /// Light year
  static const lightYear = Constant(
    value: 9.4607e15,
    name: 'Light Year',
    unit: 'm',
    symbol: 'ly',
    key: 'LY',
    category: 'celestial',
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // ALL CONSTANTS MAP
  // ═══════════════════════════════════════════════════════════════════════════

  /// Map of all constants by their key.
  static const Map<String, Constant> all = {
    // Mathematical
    'PI': pi,
    'EN': e,
    'IN': imaginaryUnit,
    'PHI': goldenRatio,
    'SQRT2': sqrt2,
    // Fundamental
    'SOL': speedOfLight,
    'PC': planck,
    'HBAR': hBar,
    'GC': gravitationalConstant,
    // Electromagnetic
    'EC': elementaryCharge,
    'VP': vacuumPermittivity,
    'VPM': vacuumPermeability,
    'CC': coulomb,
    // Atomic
    'ME': electronMass,
    'MP': protonMass,
    'MN': neutronMass,
    'BR': bohrRadius,
    'FSC': fineStructure,
    'RYD': rydberg,
    'BM': bohrMagneton,
    'NM': nuclearMagneton,
    'PEM': protonElectronMassRatio,
    // Electrochemical & Quantum
    'FC': faraday,
    'MFQ': magneticFluxQuantum,
    'CQ': conductanceQuantum,
    'JC': josephson,
    'VK': vonKlitzing,
    // Thermodynamic
    'BC': boltzmann,
    'AN': avogadro,
    'RG': gasConstant,
    'ATM': standardAtmosphere,
    'SBC': stefanBoltzmann,
    'WIE': wienDisplacement,
    'C1': firstRadiation,
    'C2': secondRadiation,
    // Earth & Celestial
    'SG': standardGravity,
    'EM': earthMass,
    'ER': earthRadius,
    'SM': sunMass,
    'SR': sunRadius,
    'AU': astronomicalUnit,
    'LY': lightYear,
  };

  /// Gets a constant by its key.
  ///
  /// Keys are case-insensitive.
  /// Returns null if not found.
  static Constant? get(String key) {
    final upper = key.toUpperCase();
    return all[upper];
  }

  /// Gets all constants in a specific category.
  ///
  /// Categories: 'mathematical', 'fundamental', 'electromagnetic',
  /// 'atomic', 'thermodynamic', 'earth', 'celestial'
  static List<Constant> byCategory(String category) {
    return all.values.where((c) => c.category == category).toList();
  }

  /// Gets all available category names.
  static List<String> get categories {
    return all.values.map((c) => c.category).toSet().toList()..sort();
  }

  /// Searches constants by name or symbol.
  static List<Constant> search(String query) {
    final lower = query.toLowerCase();
    return all.values.where((c) {
      return c.name.toLowerCase().contains(lower) ||
          c.symbol.toLowerCase().contains(lower) ||
          c.key.toLowerCase().contains(lower);
    }).toList();
  }
}
