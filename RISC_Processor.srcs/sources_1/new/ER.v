`timescale 1ns / 1ps
`include "macros.vh"

module ER(
    input clk,
    input rst_n,
    input halt_flag,
    input [`I_BITS - 1:0] instr_in,
    input [2:0] dest_in,
    input signed [`D_BITS - 1:0] result_in,
    
    output reg [`I_BITS - 1:0] instr_out,
    output reg [2:0] dest_out,
    output reg signed [`D_BITS - 1:0] result_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            instr_out <= {`I_BITS{1'b0}};
            dest_out <= 3'b000;
            result_out <= {`D_BITS{1'b0}};
        end 
        else if (!halt_flag) begin
            instr_out <= instr_in;
            dest_out <= dest_in;
            result_out <= result_in;
        end
    end

endmodule