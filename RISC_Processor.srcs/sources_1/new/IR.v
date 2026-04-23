`timescale 1ns / 1ps

`include "macros.vh"

module IR (
    input clk,
    input rst_n,
    input load_flag,
    input halt_flag,
    input jmp_flag,
    input jmpr_flag,
    input valid_jmp,
    input [`I_BITS - 1:0] instr_in,
    output reg [`I_BITS - 1:0] instr_out
);

    wire flush_pipeline;
    assign flush_pipeline = (valid_jmp && (jmp_flag || jmpr_flag));
    wire update;
    assign update = !(load_flag || halt_flag);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            instr_out <= {`I_BITS{1'b0}};
        end else begin
            if (flush_pipeline) begin
                instr_out <= {`I_BITS{1'b0}};
            end else if (update) begin
                instr_out <= instr_in;
            end
        end
    end

endmodule
