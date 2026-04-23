    `timescale 1ns / 1ps
    `include "macros.vh"
    
    module REGS(
    input clk,
    input rst_n,
    input [2:0] op0,
    input [2:0] op1,
    input [2:0] op2,
    input [2:0] dest,
    input signed [`D_BITS - 1:0] result,
    output signed [`D_BITS - 1:0] op0_data,
    output signed [`D_BITS - 1:0] op1_data,
    output signed [`D_BITS - 1:0] op2_data
);

    reg [`D_BITS - 1:0] R [0:7];
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 8; i = i + 1) begin
                R[i] <= {`D_BITS{1'b0}};
            end
        end else begin
            if (dest != `R0)
                R[dest] <= result;
        end
    end

    assign op0_data = R[op0];
    assign op1_data = R[op1];
    assign op2_data = R[op2];

endmodule
