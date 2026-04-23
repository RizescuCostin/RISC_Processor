`timescale 1ns / 1ps

`include "macros.vh"

module seq_core_tb();

reg clk, rst;
wire [`A_BITS-1:0] pc;
reg [15:0] instruction;
wire read, write;
wire [`A_BITS-1:0] address;
reg [`D_BITS-1:0] data_in;
wire [`D_BITS-1:0] data_out;

seq_core dut(
    .rst(rst),
    .clk(clk),
    .pc(pc),
    .instruction(instruction),
    .read(read),
    .write(write),
    .address(address),
    .data_in(data_in),
    .data_out(data_out)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

initial begin
    #1 rst = 1'b0;
    
    #10 rst = 1'b1; data_in = 16'd53;
    
    //DATA TRANSFERS
    instruction = {`LOAD, `R0, 5'b0, `R1};              //R0 = 53
    #10
    instruction = {`LOADC, `R1, 8'd17};                 //R1 = 17
    #10
    instruction = {`STORE, `R6, 5'b0, `R1};             //data_out = 17
    #10
    
    //ARITHMETIC AND LOGIC
    instruction = {`ADD, `R2, `R1, `R0};                //R2 = 70
    #10
    instruction = {`ADDF, `R3, `R1, `R2};               //R3 = 87
    #10
    instruction = {`SUB, `R2, `R3, `R0};                //R2 = 34
    #10
    instruction = {`SUBF, `R4, `R3, `R1};               //R4 = 70
    #10
    instruction = {`AND, `R1, `R2, `R3};                //R1 = 2
    #10
    instruction = {`OR, `R2, `R3, `R2};                 //R2 = 119
    #10
    instruction = {`XOR, `R5, `R2, `R1};                //R5 = 117
    #10
    instruction = {`NAND, `R1, `R2, `R3};               //R1 = ft mare
    #10
    instruction = {`NOR, `R3, `R5, `R2};                //R3 = ft mare
    #10
    instruction = {`XNOR, `R4, `R1, `R2};               //R4 = 32
    #10
    instruction = {`SHIFTR, `R4, 6'd2};                 //R4 = 8
    #10
    instruction = {`SHIFTRA, `R4, 6'd1};                //R4 = 4
    #10
    instruction = {`SHIFTL, `R4, 6'd4};                 //R4 = 64
    #10
    instruction = {`NOP, 9'b0};                 
    #10
    
    //BRANCHES
    rst = 1'b0;
    #10 rst = 1'b1;
    
    instruction = {`LOADC, `R0, 8'd5};                  //R0 = 5
    #10
    instruction = {`LOADC, `R1, 8'd10};                 //R1 = 10
    #10
    instruction = {`LOADC, `R2, 8'd0};                  //R2 = 0
    #10
    instruction = {`JMP, 9'b0 , `R1};                   //pc = 10
    #10
    instruction = {`JMPR,  6'd0 , 6'd5};                //pc = 15
    #10
    instruction = {`JMPcond, `Z, `R2, 3'd0, `R1};       //pc = 10
    #10
    instruction = {`JMPcond, `NZ, `R2, 3'd0, `R0};      //pc = 11
    #10
    instruction = {`JMPRcond, `N, `R1, 6'd7};            //pc = 12
    #10
    instruction = {`JMPRcond, `NN, `R1, 6'd7};           //pc = 19
    #10
    instruction = {`HALT, 12'b0};
    #10
    
    $finish;
end


endmodule
