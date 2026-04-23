`timescale 1ns / 1ps
`include "macros.vh"

module EXECUTE(
    input  [`I_BITS - 1:0] instr_in,
    input  signed [`D_BITS - 1:0] op0_data,
    input  signed [`D_BITS - 1:0] op1_data,
    input  signed [`D_BITS - 1:0] op2_data,
    input  [`VAL - 1:0] val,
    input  signed [`CONST - 1:0]  const,
    input  signed [`OFFSET - 1:0] offset,
    input  [2:0] cond,
    
    output reg [`I_BITS - 1:0] instr_out,
    output reg write,
    output reg load_flag,
    output reg halt_flag,
    output reg jmp_flag,
    output reg jmpr_flag,
    output reg valid_jmp,
    output reg [`A_BITS - 1:0] addr,
    output reg signed [`D_BITS - 1:0] data_out,
    output reg [2:0] dest,
    output reg signed [`D_BITS - 1:0] result,
    output reg signed [`A_BITS - 1:0] new_pc
);

    reg condition_met;
    wire [6:0] current_opcode;
    assign current_opcode = instr_in[`I_BITS - 1:9];

    always @(*) begin
        instr_out = instr_in;
        write     = 1'b0;
        load_flag = 1'b0;
        halt_flag = 1'b0;
        jmp_flag  = 1'b0;
        jmpr_flag = 1'b0;
        valid_jmp = 1'b0;
        addr = {`A_BITS{1'b0}};
        data_out = {`D_BITS{1'b0}};
        dest = 3'b000;
        result = {`D_BITS{1'b0}};
        new_pc = {`A_BITS{1'b0}};
        
        case (cond)
            `N : condition_met = (op0_data < 0);
            `NN: condition_met = (op0_data >= 0);
            `Z : condition_met = (op0_data == 0);
            `NZ: condition_met = (op0_data != 0);
            default: condition_met = 1'b0;
        endcase

        casez (current_opcode)
            `NOP: ;
         
            `ADD, `ADDF: begin
                dest   = instr_in[`alu_op0];
                result = op1_data + op2_data;
            end
            
            `SUB, `SUBF: begin
                dest   = instr_in[`alu_op0];
                result = op1_data - op2_data;
            end
            
            `AND: begin
                dest   = instr_in[`alu_op0];
                result = op1_data & op2_data;
            end
            
            `OR: begin
                dest   = instr_in[`alu_op0];
                result = op1_data | op2_data;
            end
            
            `XOR: begin
                dest   = instr_in[`alu_op0];
                result = op1_data ^ op2_data;
            end
            
            `NAND: begin
                dest   = instr_in[`alu_op0];
                result = ~(op1_data & op2_data);
            end
            
            `NOR: begin
                dest   = instr_in[`alu_op0];
                result = ~(op1_data | op2_data);
            end
            
            `XNOR: begin
                dest   = instr_in[`alu_op0];
                result = ~(op1_data ^ op2_data);
            end
            
            `SHIFTR: begin
                dest   = instr_in[`alu_op0];
                result = op0_data >> val;
            end
            
            `SHIFTRA: begin
                dest   = instr_in[`alu_op0];
                result = op0_data >>> val;
            end
            
            `SHIFTL: begin
                dest   = instr_in[`alu_op0];
                result = op0_data << val;
            end
            
            {`LOAD, 2'b??}: begin
                load_flag = 1'b1;
                dest      = instr_in[`dt_op0];
                addr      = op1_data[`A_BITS - 1:0];
            end
            
            {`LOADC, 2'b??}: begin
                dest   = instr_in[`dt_op0];
                result = {op0_data[`D_BITS - 1:8], const};
            end
            
            {`STORE, 2'b??}: begin
                write    = 1'b1;
                addr     = op0_data[`A_BITS - 1:0];
                data_out = op1_data;
            end
            
            {`JMP, 3'b???}: begin
                jmp_flag  = 1'b1;
                valid_jmp = 1'b1;
                new_pc    = op0_data;
            end
            
            {`JMPR, 3'b???}: begin
                jmpr_flag = 1'b1;
                valid_jmp = 1'b1;
                new_pc    = offset - 2;
            end
            
            {`JMPcond, 3'b???}: begin
                jmp_flag  = 1'b1;
                valid_jmp = condition_met;
                new_pc    = op1_data;
            end
            
            {`JMPRcond, 3'b???}: begin
                jmpr_flag = 1'b1;
                valid_jmp = condition_met;
                new_pc    = offset - 2;
            end
            
            {`HALT, 3'b???}: begin
                halt_flag = 1'b1;
            end
            
            default: ;
        endcase
    end

endmodule