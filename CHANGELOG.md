# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [1.2.0] - 2025-12-25

### Changed
- **BREAKING**: Removed all implicit multiplication support. The parser now requires explicit operators (e.g., `m*a` instead of `ma`).
- **BREAKING**: Strict constant lookup. Constants must be referenced by their explicit keys (e.g., `SOL`, `GC`, `SG`) to be automatically prefilled. Ambiguous symbols like `c`, `g`, `h` are now treated strictly as variables.
- Refactored `PhysicsConstant` to `NaturalConstant` to better reflect the domain-agnostic nature of the constants.
- Removed "repair phase" and implicit cleaning logic from variable extraction to ensure 100% predictable parsing.

### Fixed
- Fixed issue where variable aliases (e.g., `g` vs `SG`) caused duplicate rows in the solver UI.
- Fixed `getPrefilledValues` heuristics to be deterministic and strict.

## [1.1.0] - 2025-12-25

### Added
- **Enhanced Greek Letter Support**: Improved parsing of LaTeX Greek commands (e.g., `\alpha`, `\Phi_0`, `\Delta E`)
- **Automatic Physics Constants**: Solver now automatically identifies and substitutes physics constants mentioned by their symbols or keys
- **Subscript Support**: Improved handling of variable subscripts in both plain text (`x_1`) and LaTeX (`x_{1}`)

### Changed
- Improved numerical solver's accuracy for high-sensitivity physics equations (like Rydberg formula)
- Unified math symbol rendering (π, ∞, etc.) to use standard LaTeX commands consistently
- Refined variable extraction to correctly exclude math and physics constants from "unknowns"

### Fixed
- Resolved `NaN` results in complex arithmetic involving the imaginary unit `i`
- Improved convergence of Newton's method with expanded search ranges and better starting points

## [1.0.0] - 2024-12-24

### Added
- `ExpressionParser` - New clean API for parsing expressions and extracting variables
- `Evaluator` - New class for expression evaluation with variable substitution
- `Solver` - New equation solver with algebraic and numerical methods
- `Cas` - Computer Algebra System for differentiation and integration
- `ExpressionGrammar` - PetitParser grammar for explicit algebraic notation
- Comprehensive documentation and examples

### Changed
- **BREAKING**: Complete API reorganization with cleaner, more intuitive classes
- Moved to explicit operator notation (e.g., `2*x` instead of `2x`)
- Improved error handling with descriptive error messages

### Deprecated
- `MathEquationParser` - Use `ExpressionParser` + `Evaluator` instead
- `AlgebraicEquationParser` - Use `Solver` instead
- `CasParser` - Use `Cas` instead

### Fixed
- Single-letter variables no longer incorrectly match physics constants
- Better handling of mathematical constants (pi, e, infinity)
