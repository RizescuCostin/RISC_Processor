//Sizes
`define D_BITS 32
`define A_BITS 10
`define I_BITS 16
`define CONST 8
`define OFFSET 6
`define VAL 6

//Registers
`define R0 3'd0
`define R1 3'd1
`define R2 3'd2
`define R3 3'd3
`define R4 3'd4
`define R5 3'd5
`define R6 3'd6
`define R7 3'd7

//Instructions
`define NOP         7'b0000000
`define ADD         7'b0000001
`define ADDF        7'b0000010
`define SUB         7'b0000011
`define SUBF        7'b0000100
`define AND         7'b0000101
`define OR          7'b0000110
`define XOR         7'b0000111
`define NAND        7'b0001000
`define NOR         7'b0001001
`define XNOR        7'b0001010
`define SHIFTR      7'b0001011
`define SHIFTRA     7'b0001100
`define SHIFTL      7'b0001101

`define LOAD        5'b01000
`define LOADC       5'b01001
`define STORE       5'b01010

`define JMP         4'b1000
`define JMPR        4'b1001
`define JMPcond     4'b1010
`define JMPRcond    4'b1011

`define HALT        4'b1111

//Conditions

`define N       3'b000
`define NN      3'b001
`define Z       3'b010
`define NZ      3'b011

//opcodes

`define instr_type      15:14
`define alu_opcode      15:9
`define dt_opcode       15:11
`define branch_opcode   15:12
`define halt_opcode     15:12

//instr types

`define arithmetic_logic    2'b00
`define data_transfer       2'b01
`define branch              2'b10
`define halt                2'b11

//operands

`define alu_op0         8:6
`define alu_op1         5:3
`define alu_op2         2:0
`define val             5:0

`define dt_op0          10:8
`define dt_op1          2:0
`define dt_const        7:0

`define jmp_op0              2:0
`define jmpr_offset          5:0
`define jmpc_cond            11:9
`define jmpc_op0             8:6
`define jmpc_op1             2:0
`define jmpc_offset          5:0

