# 16-Tap FIR Filter FPGA Accelerator

## 📌 Overview
This repository contains the RTL design and verification of a 16-tap Finite Impulse Response (FIR) filter implemented on an FPGA. The project explores the classical VLSI design trade-off between **Area** and **Throughput** by developing two distinct hardware architectures using Fixed-Point arithmetic (Q15 format).

## 🏗️ Architectures Explored
1. **Folded MAC Architecture (Area Optimized):** Utilizes resource sharing with only 1 Multiplier and 1 Adder controlled by a Finite State Machine (FSM). Designed for resource-constrained IoT applications.
2. **Pipelined Architecture (Throughput Optimized):** Employs an array of parallel multipliers and an adder tree, heavily pipelined to achieve 1 sample/cycle throughput. Designed for high-bandwidth applications like 5G base stations.

## 📊 Synthesis Results (Vivado)
| Architecture | DSP Blocks | Slice LUTs | Fmax (MHz) | Throughput |
| :--- | :--- | :--- | :--- | :--- |
| **Folded** | 1 | 109 | 118.83 | 1 sample / 8 cycles |
| **Pipelined** | 8 | 366 | 211.55 | 1 sample / 1 cycle |

*(Note: Data verified via ModelSim and MATLAB spectral analysis with 0.0000 dB deviation).*

## 📁 Repository Structure
* `/src` - Verilog RTL source code for both architectures.
* `/sim` - Testbenches and simulation files.
* `/docs` - Project report and architecture diagrams.
* `/matlab` - Scripts for coefficient generation (Floating to Q15) and FFT analysis.

