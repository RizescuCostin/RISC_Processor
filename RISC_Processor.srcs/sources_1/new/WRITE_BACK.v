`timescale 1ns / 1ps
`include "macros.vh"

module WRITE_BACK (
    input [`I_BITS - 1:0]instr_in,
    input [2:0] dest_in,
    input signed [`D_BITS - 1:0] result_in,
    input signed [`D_BITS - 1:0] data_in,
    output reg [2:0] dest_out,
    output reg signed [`D_BITS - 1:0] result_out
);

    wire [6:0] op_code;
    assign op_code = instr_in[`I_BITS - 1:9];

    always @(*) begin
        dest_out   = 3'b000;
        result_out = {`D_BITS{1'b0}};
        casez (op_code)
            `ADD, `ADDF, `SUB, `SUBF, `AND, `OR, `XOR, `NAND, `NOR,
            `XNOR, `SHIFTR, `SHIFTRA, `SHIFTL, {`LOADC, 2'b??}: begin
                dest_out   = dest_in;
                result_out = result_in;
            end 
            {`LOAD, 2'b??}: begin
                dest_out   = dest_in;
                result_out = data_in;
            end
            default: begin
                dest_out   = 3'b000;
                result_out = {`D_BITS{1'b0}};
            end
        endcase
    end

endmodule