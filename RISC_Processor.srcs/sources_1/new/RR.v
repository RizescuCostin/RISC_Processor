`timescale 1ns / 1ps
`include "macros.vh"

module RR(
    input clk,
    input rst_n,
    input load_flag,
    input halt_flag,
    input jmp_flag,
    input jmpr_flag,
    input valid_jmp,
    input [`I_BITS - 1:0] instr_in,
    input signed [`D_BITS - 1:0] op0_data_in,
    input signed [`D_BITS - 1:0] op1_data_in,
    input signed [`D_BITS - 1:0] op2_data_in,
    input [`VAL - 1:0] val_in,
    input signed [`CONST - 1:0] const_in,
    input signed [`OFFSET - 1:0] offset_in,
    input [2:0] cond_in,

    output reg [`I_BITS - 1:0] instr_out,
    output reg signed [`D_BITS - 1:0] op0_data_out,
    output reg signed [`D_BITS - 1:0] op1_data_out,
    output reg signed [`D_BITS - 1:0] op2_data_out,
    output reg [`VAL - 1:0] val_out,  
    output reg signed [`CONST - 1:0] const_out,
    output reg signed [`OFFSET - 1:0] offset_out,
    output reg [2:0] cond_out
);

    wire flush;
    wire stall;

    assign flush = !rst_n || load_flag || (valid_jmp && (jmp_flag || jmpr_flag));
    
    assign stall = halt_flag;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            instr_out <= {`I_BITS{1'b0}};
            op0_data_out <= {`D_BITS{1'b0}};
            op1_data_out <= {`D_BITS{1'b0}};
            op2_data_out <= {`D_BITS{1'b0}};
            val_out <= {`VAL{1'b0}};
            const_out <= {`CONST{1'b0}};
            offset_out <= {`OFFSET{1'b0}};
            cond_out <= 3'b000;
        end 
        else if (flush) begin
            instr_out <= {`I_BITS{1'b0}};
            op0_data_out <= {`D_BITS{1'b0}};
            op1_data_out <= {`D_BITS{1'b0}};
            op2_data_out <= {`D_BITS{1'b0}};
            val_out <= {`VAL{1'b0}};
            const_out <= {`CONST{1'b0}};
            offset_out <= {`OFFSET{1'b0}};
            cond_out <= 3'b000;
        end 
        else if (!stall) begin
            instr_out <= instr_in;
            op0_data_out <= op0_data_in;
            op1_data_out <= op1_data_in;
            op2_data_out <= op2_data_in;
            val_out <= val_in;
            const_out <= const_in;
            offset_out <= offset_in;
            cond_out <= cond_in;
        end
    end

endmodule