`timescale 1ns / 1ps
`include "Macros.vh"

module FETCH (
    input clk,
    input rst_n,
    input [`I_BITS - 1:0] instr_in,
    input load_flag,
    input halt_flag,
    input jmp_flag,
    input jmpr_flag,
    input valid_jmp,
    input signed [`A_BITS - 1:0] new_pc,
    output reg signed [`A_BITS - 1:0] pc,
    output [`I_BITS - 1:0] instr_out
);

    wire jump_active;
    assign jump_active = (jmp_flag || jmpr_flag) && valid_jmp;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= {`A_BITS{1'b0}};
        end else begin
            if (load_flag || halt_flag) begin
                pc <= pc;
            end else if (jump_active) begin
                if (jmpr_flag) begin
                    pc <= pc + new_pc;
                end else begin
                    pc <= new_pc;
                end
            end else begin
                pc <= pc + 1'b1;
            end
        end
    end

    assign instr_out = jump_active ? {`I_BITS{1'b0}} : instr_in;

endmodule