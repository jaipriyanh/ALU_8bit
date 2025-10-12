<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
This project is an **Arithmetic Logic Unit (ALU)** written in VHDL.  
It takes two 8-bit signed numbers (`op1_i` and `op2_i`) and performs one of several operations based on a 4-bit code (`opcode_i`).  
The output is given through `result_o`, and two flags indicate special conditions:
- **`zero_o`** → 1 if the result is zero  
- **`carry_o`** → 1 if there is an overflow during addition or subtraction  

### Supported Operations
| Opcode | Operation | Description |
|---------|------------|-------------|
| 0001 | Addition | `result_o = op1_i + op2_i` |
| 0010 | Subtraction | `result_o = op1_i - op2_i` |
| 0011 | Multiplication | `result_o = op1_i * op2_i` (truncated to 8 bits) |
| 0100 | Division | `result_o = op1_i / op2_i` (0 if `op2_i` = 0) |
| 0101 | AND | `result_o = op1_i AND op2_i` |
| 0110 | OR | `result_o = op1_i OR op2_i` |
| 0111 | XOR | `result_o = op1_i XOR op2_i` |

The ALU works on a **clock** signal and uses an **active-low reset (`res_ni`)**.  
When reset is active, all outputs become zero.  
On each rising edge of the clock, the ALU performs the selected operation and updates the result.
## How to test

todo

## External hardware

todo
