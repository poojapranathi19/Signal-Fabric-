# Signal-Fabric-
Designing a DSP48E1 - Style Slice in Verilog
## Overview

This project implements a simplified DSP48E1-style DSP slice using Verilog HDL. The design follows a modular approach and combines multiple hardware blocks into a pipelined DSP architecture controlled by a Finite State Machine (FSM).

## Design and Integration Flow

The project was developed using a bottom-up design approach, where each module was first implemented and verified individually before being integrated into the complete DSP slice.

### Step 1: Datapath Integration

The first stage involved combining the following modules into a single datapath (corresponding to Step 6 of the design plan):

- Input Register Bank
- Pre-Adder
- Multiplier
- Operand Multiplexer
- ALU
- Output Register

At this stage, the control signals (`ce_*`, `inmode`, `opmode`, and `alu_sel`) were driven directly from the testbench instead of an FSM. This allowed each stage of the datapath to be tested independently and ensured that data flowed correctly through the pipeline.

### Step 2: Datapath Verification

A dedicated testbench was written to verify the integrated data path. The following test cases were performed:

- Single MACC (Multiply-Accumulate) operation
- Chained MACC operations
- Three consecutive chained MACC operations
- Operations using both positive and negative operands

These tests confirmed that the pre-adder, multiplier, ALU, and output register operated correctly and that the pipeline produced the expected results.

### Step 3: Slice Controller FSM

Once the datapath was verified, the Slice Controller FSM was developed separately.

A separate testbench was created for the FSM to verify:

- Correct state transitions (IDLE → LOAD → MULT → ALU_OP → OUTPUT)
- Generation of clock enable (`ce_*`) signals
- Timing of the `busy` and `result_valid` signals
- Correct pipelining of the control signals (`inmode`, `opmode`, and `alu_sel`)

Testing the FSM independently ensured that the control logic functioned correctly before connecting it to the datapath.

### Step 4: Final Integration

After both the datapath and controller were verified individually, they were integrated into the final top-level module, `dsp_slice_top`.

In the final design, the user only provides:

- `cmd`
- `start`
- Input operands (A, B, C, and D)

The FSM automatically generates all required internal control signals, eliminating the need for manual control from the testbench.

### Step 5: Final Testbench

A final system-level testbench was written for `dsp_slice_top` to verify the complete design. The testbench applies different commands and input values while monitoring the `busy`, `result_valid`, and result outputs.

This confirms that the integrated DSP slice correctly executes operations from start to finish and that the pipelined controller and datapath operate together as intended.

## Pipeline Operation

The DSP slice uses a four-stage pipeline, allowing each stage to perform a different part of the computation.

Since the design is pipelined, different operations can occupy different stages simultaneously, improving throughput. While one operation is being multiplied, another can be loading its inputs, and a previous operation can already be producing its output. This overlapping execution enables efficient processing of consecutive DSP operations.

## Project Objective

The objective of this project is to understand the architecture of a DSP48E1 slice by implementing its main functional blocks and integrating them into a complete pipelined design.

## Authors

- Pooja Pranathi
- Prathamesh Raje
- Theertha Deepthi Kumar
