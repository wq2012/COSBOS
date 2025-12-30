# COSBOS: COlor-Sensor-Based Occupancy Sensing

[![View COSBOS: COlor-Sensor-Based Occupancy Sensing on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/48428-cosbos-color-sensor-based-occupancy-sensing)
[![Octave application](https://github.com/wq2012/COSBOS/actions/workflows/octave.yml/badge.svg)](https://github.com/wq2012/COSBOS/actions/workflows/octave.yml)

![logo](resources/logo.png)

COSBOS is a high-performance MATLAB/Octave toolbox for occupancy sensing using color sensors. It implements advanced Light Transport Matrix (LTM) recovery techniques and occupancy models, optimized for speed and reliability.

---

## Table of Contents
- [Project Overview](#project-overview)
- [Installation and Setup](#installation-and-setup)
- [Key Features](#key-features)
- [Modules](#modules)
  - [LTM Recovery](#ltm-recovery)
  - [Blockage Model](#blockage-model)
  - [Reflection Model](#reflection-model)
- [Running Demos](#running-demos)
- [Unit Testing](#unit-testing)
- [Citation](#citation)

---

## Project Overview
Color sensors can be used as low-cost, privacy-preserving alternatives to cameras for occupancy sensing. By measuring changes in the Light Transport Matrix (LTM) of a room, we can infer the presence and location of occupants. COSBOS provides the tools to:
1. Recover the LTM from sensor measurements.
2. Model occupancy using light blockage (for wall-mounted sensors).
3. Model occupancy using light reflection (for ceiling-mounted sensors).

## Installation and Setup
1. Clone the repository: `git clone https://github.com/wq2012/COSBOS.git`
2. Ensure you have MATLAB or Octave installed.
3. If using the Blockage Model, you need to compile the C++ MEX files:
   - Go to `BlockageModel/` and run `compile.m` in MATLAB/Octave.
   - Requires a C++ compiler (e.g., GCC, Clang, or MSVC).

## Key Features
- **High Performance**: Vectorized computations and optimized C++ MEX implementations.
- **Robust Modularity**: Module-specific configuration files (e.g., `coordinates_blockage.m`) to prevent name collisions.
- **Absolute Path Support**: All demos and tests are designed to run from any directory without path issues.
- **Clean Output**: Silenced runtime warnings and polished logs.

## Modules

### LTM Recovery
Located in `LTM_Recovery/`. Solves $Y = AX$ for the mapping $A$.
- `solve_A_fullrank.m`: Standard pseudo-inverse solution.
- `solve_A_Fnorm.m`: Stable low-rank approximation via SVD.
- `solve_A_0norm.m`: Sparse recovery using Orthogonal Matching Pursuit (OMP).
- `solve_A_1norm.m`: Sparse recovery using primal-dual interior point methods.

### Blockage Model
Located in `BlockageModel/`. For wall-mounted sensors.
- Uses `coordinates_blockage.m` for spatial configuration.
- `hashGaussians.cpp`: Optimized MEX code for distance hashing (no heap allocation in hot loops).
- `volumeFromHashing.cpp`: Fast volume rendering via optimized internal matrix management.

### Reflection Model
Located in `ReflectionModel/`. For ceiling-mounted sensors.
- Uses `coordinates_reflection.m` for spatial configuration.
- `getReflectionKernel.m`: Fully vectorized implementation for near-instant kernel generation.

## Running Demos
Each module includes a robust demo script:
- `LTM_Recovery/demo_LTM.m`: Demonstrates LTM recovery techniques.
- `BlockageModel/demo_Blockage.m`: Renders a 3D occupancy volume.
- `ReflectionModel/demo_Reflection.m`: Generates a floor-plane occupancy map.

## Unit Testing
Run the master test script from the project root:
```matlab
addpath('tests');
run_tests;
```
This verifies LTM recovery accuracy, MEX script correctness, and model performance.

## Citation
If you use this work in your research, please cite:
```bibtex
@article{wang2014cosbos,
  title={COSBOS: COlor-sensor-based occupancy sensing},
  author={Wang, Quan and Kim, Jaeseok and Shao, Richard and Ji, Qiang and Hella, Karl R},
  journal={Journal of Solid State Lighting},
  volume={1},
  number={1},
  pages={1--16},
  year={2014},
  publisher={SpringerOpen}
}
```
