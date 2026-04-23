`timescale 1ns / 1ps
`include "macros.vh"

module READ (
    input [`I_BITS - 1:0] instr_in,
    input signed [`D_BITS - 1:0] op0_data_regs,
    input signed [`D_BITS - 1:0] op1_data_regs,
    input signed [`D_BITS - 1:0] op2_data_regs,
    input [2:0] dest_execute,
    input signed [`D_BITS - 1:0] result_execute,
    input [2:0] dest,
    input signed [`D_BITS - 1:0] result,
    
    output reg [`I_BITS - 1:0] instr_out,
    output reg [2:0] op0,
    output reg [2:0] op1,
    output reg [2:0] op2,
    output reg signed [`D_BITS - 1:0] op0_data_out,
    output reg signed [`D_BITS - 1:0] op1_data_out,
    output reg signed [`D_BITS - 1:0] op2_data_out,
    output reg [`VAL-1:0] val,
    output reg signed [`CONST - 1:0] const,
    output reg signed [`OFFSET - 1:0] offset,
    output reg [2:0] cond
);

    wire [6:0] opcode_full;
    assign opcode_full = instr_in[`alu_opcode];

    always @(*) begin
        instr_out = instr_in;
        op0       = 3'b000;
        op1       = 3'b000;
        op2       = 3'b000;
        val       = {`VAL{1'b0}};
        const     = {`CONST{1'b0}};
        offset    = {`OFFSET{1'b0}};
        cond      = 3'b000;

        casez (opcode_full)
            `NOP: begin end

            `ADD, `ADDF, `SUB, `SUBF, `AND, `OR, `XOR, `NAND, `NOR, `XNOR: begin
                op0 = instr_in[`alu_op0];
                op1 = instr_in[`alu_op1];
                op2 = instr_in[`alu_op2];
            end
            
            `SHIFTR, `SHIFTRA, `SHIFTL: begin
                op0 = instr_in[`alu_op0];
                val = instr_in[`val];
            end
            
            {`LOAD, 2'b??}, {`STORE, 2'b??}: begin
                op0 = instr_in[`dt_op0];
                op1 = instr_in[`dt_op1];
            end
            
            {`LOADC, 2'b??}: begin
                op0   = instr_in[`dt_op0];
                const = instr_in[`dt_const];
            end
            
            {`JMP, 3'b???}: begin
                op0 = instr_in[`jmp_op0];
            end
            
            {`JMPR, 3'b???}: begin
                offset = instr_in[`jmpr_offset];
            end
            
            {`JMPcond, 3'b???}: begin
                cond = instr_in[`jmpc_cond];
                op0  = instr_in[`jmpc_op0];
                op1  = instr_in[`jmpc_op1];
            end
            
            {`JMPRcond, 3'b???}: begin
                cond   = instr_in[`jmpc_cond];
                op0    = instr_in[`jmpc_op0];
                offset = instr_in[`jmpc_offset];
            end

            {`HALT, 3'b???}: begin
            end

            default: ; 
        endcase

        if (opcode_full != `NOP && op0 == dest_execute && dest_execute != 3'b000)
            op0_data_out = result_execute;
        else if (opcode_full != `NOP && op0 == dest && dest != 3'b000)
            op0_data_out = result;
        else
            op0_data_out = op0_data_regs;

        if (opcode_full != `NOP && op1 == dest_execute && dest_execute != 3'b000)
            op1_data_out = result_execute;
        else if (opcode_full != `NOP && op1 == dest && dest != 3'b000)
            op1_data_out = result;
        else
            op1_data_out = op1_data_regs;

        if (opcode_full != `NOP && op2 == dest_execute && dest_execute != 3'b000)
            op2_data_out = result_execute;
        else if (opcode_full != `NOP && op2 == dest && dest != 3'b000)
            op2_data_out = result;
        else
            op2_data_out = op2_data_regs;
    end

endmodule