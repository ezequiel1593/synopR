## Test environments
* local Windows 11 install, R 4.5.2
* win-builder (devel)

## Resubmission / Major Update
* This is a new major release (0.3.0 -> 1.0.0).

### Key changes:
* **Dependency-free**: The package has been modified to use only Base R, removing all external dependencies for better long-term stability and easier installation.
* **Vectorization**: Restructured core parsing functions to be fully vectorized, significantly improving performance for large data sets.
* **New features**: Added support for extensive meteorological variables. New functions to download data.
* **Documentation**: Added a comprehensive vignette describing all 63 output columns, their physical units and details.

## Test results
* 0 errors, 0 warnings, 0 note

## Notes
* Possibly misspelled words in DESCRIPTION: 'Ogimet'.
  This is the name of a meteorological data source used by the package and is a correct term in this context. It has been added to the package WORDLIST.
