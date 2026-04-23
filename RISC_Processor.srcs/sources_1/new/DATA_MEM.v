`timescale 1ns / 1ps
`include "macros.vh"

module DATA_MEMORY (
    input clk,
    input read,
    input write,
    input [`A_BITS - 1:0] addr,
    input signed [`D_BITS - 1:0] data_in,
    output reg signed [`D_BITS - 1:0] data_out
);

    localparam MEM_DEPTH = 1 << `A_BITS;
    
    reg [`D_BITS - 1:0] ram [0:MEM_DEPTH - 1];

    always @(posedge clk) begin
        if (write) begin
            ram[addr] <= data_in;
        end
        
        if (read) begin
            data_out <= ram[addr];
        end
    end
    
    
    initial begin
        ram[5] = 32'd1234;
        ram[10] = 32'hABCD;
    end

endmodule