    `timescale 1ns / 1ps
    `include "macros.vh"
    
    module PROG_MEM(
        input   [`A_BITS-1:0] addr,
        output  [`I_BITS-1:0] instr
        );
        
        reg [`I_BITS-1:0] memory [0:2 ** `A_BITS-1];
        
        assign instr = memory[addr];
        integer k;
        initial begin
            memory[1]  = {`LOADC, `R1, 8'd10};    // R1 = 10
            memory[2]  = {`LOADC, `R2, 8'd20};    // R2 = 20
            memory[3]  = {`ADD,   `R3, `R1, `R2}; // R3 = R1 + R2 = 30
            memory[4]  = {`SUB,   `R4, `R3, `R1}; // R4 = R3 - R1 = 20 (tests forwarding from R3)
            memory[5]  = {`AND,   `R5, `R4, `R2}; // R5 = R4 & R2 = 20 (forwarding R4)
        
            memory[6]  = {`LOADC, `R6, 8'd5};     // R6 = 5
            memory[7]  = {`LOAD,  `R7, 5'b0, `R6}; // Load memory[R6] into R7 (tests load stall)
            
            memory[8]  = {`SUB,   `R1, `R1, `R1}; // R1 = R1 - R1 = 0 (sets Z)
            memory[9]  = {`JMPcond, `Z, `R0, `R0}; // If Z (R1==0), jump to memory[12]
            memory[10] = {`LOADC, `R1, 8'd99};     // Should be skipped if jump works
            memory[11] = {`NOP, 12'b0};             // NOP filler
        
            memory[12] = {`LOADC, `R2, 8'd42};     // Target of conditional jump (R2 = 42)
        
            memory[13] = {`JMP, `R2};             // Jump to memory[16]
            memory[14] = {`LOADC, `R3, 8'd77};     // Should be skipped
            memory[15] = {`NOP, 12'b0};             // Filler
        
            memory[16] = {`LOADC, `R4, 8'd123};    // Target of absolute jump
 
            memory[30] = {`HALT, 12'b0};           // Stop execution
        end
    endmodule
