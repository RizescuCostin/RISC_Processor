`timescale 1ns / 1ps
`include "macros.vh"

module TOP_tb();
    reg clk;
    reg rst_n;
    
    wire [`I_BITS - 1:0] current_instr;
    wire [`D_BITS - 1:0] dmem_to_proc;
    wire [`D_BITS - 1:0] proc_to_dmem;
    wire [`A_BITS - 1:0] current_pc;
    wire [`A_BITS - 1:0] dmem_addr;
    wire dmem_read_en;
    wire dmem_write_en;

    initial clk = 0;
    always #5 clk = ~clk;

    PROG_MEM prog_mem_inst (
        .addr  (current_pc),
        .instr (current_instr)
    );

    TOP dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .instr   (current_instr),
        .data_in (dmem_to_proc),
        .read    (dmem_read_en),
        .write   (dmem_write_en),
        .pc      (current_pc),
        .addr    (dmem_addr),
        .data_out(proc_to_dmem)
    );

    DATA_MEMORY data_mem_inst (
        .clk     (clk),
        .read    (dmem_read_en),
        .write   (dmem_write_en),
        .addr    (dmem_addr),
        .data_in (proc_to_dmem),
        .data_out(dmem_to_proc)
    );

    initial begin
        rst_n = 0;
        #25 rst_n = 1;
    end
endmodule