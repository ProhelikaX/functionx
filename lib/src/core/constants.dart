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
    key: 'EULER',
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
    key: 'SPEED_OF_LIGHT',
    category: 'fundamental',
  );

  /// Planck constant
  static const planck = Constant(
    value: 6.62607015e-34,
    name: 'Planck Constant',
    unit: 'J⋅s',
    symbol: 'h',
    key: 'PLANCK',
    category: 'fundamental',
  );

  /// Reduced Planck constant (ħ = h/2π)
  static const hBar = Constant(
    value: 1.054571817e-34,
    name: 'Reduced Planck Constant',
    unit: 'J⋅s',
    symbol: 'ħ',
    key: 'H_BAR',
    category: 'fundamental',
  );

  /// Gravitational constant
  static const gravitationalConstant = Constant(
    value: 6.67430e-11,
    name: 'Gravitational Constant',
    unit: 'N⋅m²/kg²',
    symbol: 'G',
    key: 'G',
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
    key: 'E_CHARGE',
    category: 'electromagnetic',
  );

  /// Vacuum permittivity (electric constant)
  static const vacuumPermittivity = Constant(
    value: 8.8541878128e-12,
    name: 'Vacuum Permittivity',
    unit: 'F/m',
    symbol: 'ε₀',
    key: 'EPSILON_0',
    category: 'electromagnetic',
  );

  /// Vacuum permeability (magnetic constant)
  static const vacuumPermeability = Constant(
    value: 1.25663706212e-6,
    name: 'Vacuum Permeability',
    unit: 'H/m',
    symbol: 'μ₀',
    key: 'MU_0',
    category: 'electromagnetic',
  );

  /// Coulomb constant (k = 1/4πε₀)
  static const coulomb = Constant(
    value: 8.9875517923e9,
    name: 'Coulomb Constant',
    unit: 'N⋅m²/C²',
    symbol: 'k',
    key: 'COULOMB',
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
    key: 'M_ELECTRON',
    category: 'atomic',
  );

  /// Proton mass
  static const protonMass = Constant(
    value: 1.67262192369e-27,
    name: 'Proton Mass',
    unit: 'kg',
    symbol: 'mₚ',
    key: 'M_PROTON',
    category: 'atomic',
  );

  /// Neutron mass
  static const neutronMass = Constant(
    value: 1.67492749804e-27,
    name: 'Neutron Mass',
    unit: 'kg',
    symbol: 'mₙ',
    key: 'M_NEUTRON',
    category: 'atomic',
  );

  /// Bohr radius
  static const bohrRadius = Constant(
    value: 5.29177210903e-11,
    name: 'Bohr Radius',
    unit: 'm',
    symbol: 'a₀',
    key: 'BOHR_RADIUS',
    category: 'atomic',
  );

  /// Fine structure constant
  static const fineStructure = Constant(
    value: 7.2973525693e-3,
    name: 'Fine Structure Constant',
    unit: '',
    symbol: 'α',
    key: 'ALPHA',
    category: 'atomic',
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // THERMODYNAMIC CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Boltzmann constant
  static const boltzmann = Constant(
    value: 1.380649e-23,
    name: 'Boltzmann Constant',
    unit: 'J/K',
    symbol: 'kB',
    key: 'K_B',
    category: 'thermodynamic',
  );

  /// Avogadro number
  static const avogadro = Constant(
    value: 6.02214076e23,
    name: 'Avogadro Number',
    unit: '1/mol',
    symbol: 'NA',
    key: 'N_A',
    category: 'thermodynamic',
  );

  /// Universal gas constant
  static const gasConstant = Constant(
    value: 8.314462618,
    name: 'Gas Constant',
    unit: 'J/(mol⋅K)',
    symbol: 'R',
    key: 'R_GAS',
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
    key: 'STEFAN_BOLTZMANN',
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
    key: 'G_EARTH',
    category: 'earth',
  );

  /// Earth mass
  static const earthMass = Constant(
    value: 5.972e24,
    name: 'Earth Mass',
    unit: 'kg',
    symbol: 'M⊕',
    key: 'M_EARTH',
    category: 'earth',
  );

  /// Earth radius (mean)
  static const earthRadius = Constant(
    value: 6.371e6,
    name: 'Earth Radius',
    unit: 'm',
    symbol: 'R⊕',
    key: 'R_EARTH',
    category: 'earth',
  );

  /// Sun mass
  static const sunMass = Constant(
    value: 1.989e30,
    name: 'Sun Mass',
    unit: 'kg',
    symbol: 'M☉',
    key: 'M_SUN',
    category: 'celestial',
  );

  /// Sun radius
  static const sunRadius = Constant(
    value: 6.96e8,
    name: 'Sun Radius',
    unit: 'm',
    symbol: 'R☉',
    key: 'R_SUN',
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
    key: 'LIGHT_YEAR',
    category: 'celestial',
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // ALL CONSTANTS MAP
  // ═══════════════════════════════════════════════════════════════════════════

  /// Map of all constants by their key.
  static const Map<String, Constant> all = {
    // Mathematical
    'PI': pi,
    'EULER': e,
    'PHI': goldenRatio,
    'SQRT2': sqrt2,
    // Fundamental
    'SPEED_OF_LIGHT': speedOfLight,
    'PLANCK': planck,
    'H_BAR': hBar,
    'G': gravitationalConstant,
    // Electromagnetic
    'E_CHARGE': elementaryCharge,
    'EPSILON_0': vacuumPermittivity,
    'MU_0': vacuumPermeability,
    'COULOMB': coulomb,
    // Atomic
    'M_ELECTRON': electronMass,
    'M_PROTON': protonMass,
    'M_NEUTRON': neutronMass,
    'BOHR_RADIUS': bohrRadius,
    'ALPHA': fineStructure,
    // Thermodynamic
    'K_B': boltzmann,
    'N_A': avogadro,
    'R_GAS': gasConstant,
    'ATM': standardAtmosphere,
    'STEFAN_BOLTZMANN': stefanBoltzmann,
    // Earth & Celestial
    'G_EARTH': standardGravity,
    'M_EARTH': earthMass,
    'R_EARTH': earthRadius,
    'M_SUN': sunMass,
    'R_SUN': sunRadius,
    'AU': astronomicalUnit,
    'LIGHT_YEAR': lightYear,
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
