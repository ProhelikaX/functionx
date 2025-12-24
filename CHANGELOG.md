# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-12-24

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
