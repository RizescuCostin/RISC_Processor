`timescale 1ns / 1ps
`include "macros.vh"

module REGS(
    input clk,
    input rst,
    
    input [2:0] src_addr_0,      
    input [2:0] src_addr_1,      
    input [2:0] dest_addr_wb,   
    input [`D_BITS-1:0] write_data,
    input write_en_wb,           
    
    output [`D_BITS-1:0] reg_data_0,
    output [`D_BITS-1:0] reg_data_1,
    
    input [6:0] opcode_ex,
    input [2:0] dest_addr_ex,
    
    output reg stall
    );
    
    reg [`D_BITS-1:0] registers [7:0];
    reg [1:0] stall_count;

    assign reg_data_0 = (src_addr_0 == `R0) ? `D_BITS'b0 : 
                        (write_en_wb && (src_addr_0 == dest_addr_wb)) ? write_data : registers[src_addr_0];

    assign reg_data_1 = (src_addr_1 == `R0) ? `D_BITS'b0 : 
                        (write_en_wb && (src_addr_1 == dest_addr_wb)) ? write_data : registers[src_addr_1];

    integer i;
    always @(posedge clk) begin
        if(!rst) begin
            for(i = 0; i < 8; i = i + 1) begin
                registers[i] <= `D_BITS'b0; 
            end
        end else if (write_en_wb && dest_addr_wb != `R0) begin
            registers[dest_addr_wb] <= write_data;
        end
    end
    always @(posedge clk) begin
        if (!rst) begin
            stall_count <= 2'b0;
        end else if (stall_count > 0) begin
            stall_count <= stall_count - 1'b1;
        end else begin
            if (opcode_ex == 7'h24) begin 
                if ((dest_addr_ex == src_addr_0 || dest_addr_ex == src_addr_1) && dest_addr_ex != `R0) begin
                    stall_count <= 2'd1;
                end
            end
        end
    end

    always @(*) begin
        stall = (stall_count > 0);
    end

endmodule