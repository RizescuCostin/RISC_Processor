`timescale 1ns / 1ps

`include "macros.vh"

module seq_core(
    // general
    input 		rst,   // active 0
    input		clk,
    // program memory
    output reg [`A_BITS-1:0] pc,
    input        [15:0] instruction,
    // data memory
    output reg		read,  // active 1
    output reg		write, // active 1
    output reg [`A_BITS-1:0]	address,
    input [`D_BITS-1:0]	data_in,
    output reg [`D_BITS-1:0]	data_out
);

    reg [`D_BITS-1:0] R [0:7];
    integer i;
    
    always @(*) begin
        read = 1'b0;
        write = 1'b0;
        address = 0;
        data_out = 0;
        case (instruction[15:14])
            `arithmetic_logic: ;
            `data_transfer: begin
                case (instruction[`dt_opcode])
                    `LOAD: begin
                        read = 1'b1;
                        address = R[instruction[`dt_op1]];
                        R[instruction[`dt_op0]] = data_in;
                    end
                    `LOADC: begin
                        R[instruction[`dt_op0]] = {R[instruction[`dt_op0]][`D_BITS-1:8], instruction[`dt_const]};
                    end
                    `STORE: begin
                        write = 1'b1;
                        address = R[instruction[`dt_op0]];
                        data_out = R[instruction[`dt_op1]];
                    end
                endcase
             end
            `branch: ;
            `halt: ;
            default: ;
        endcase
    end
    
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            pc <= 0;
            for (i = 0; i < 8; i = i + 1)
                R[i] <= 0;
            read <= 1'b0;
            write <= 1'b0;
            address <= 0;
            data_out <= 0; 
        end else begin
            case (instruction[`instr_type])
                `arithmetic_logic: begin
                    case (instruction[`alu_opcode])
                        `NOP:       ;
                        `ADD:       R[instruction[`alu_op0]] <= R[instruction[`alu_op1]] + R[instruction[`alu_op2]];
                        `ADDF:      R[instruction[`alu_op0]] <= R[instruction[`alu_op1]] + R[instruction[`alu_op2]];
                        `SUB:       R[instruction[`alu_op0]] <= R[instruction[`alu_op1]] - R[instruction[`alu_op2]];
                        `SUBF:      R[instruction[`alu_op0]] <= R[instruction[`alu_op1]] - R[instruction[`alu_op2]];
                        `AND:       R[instruction[`alu_op0]] <= R[instruction[`alu_op1]] & R[instruction[`alu_op2]];
                        `OR:        R[instruction[`alu_op0]] <= R[instruction[`alu_op1]] | R[instruction[`alu_op2]];
                        `XOR:       R[instruction[`alu_op0]] <= R[instruction[`alu_op1]] ^ R[instruction[`alu_op2]];
                        `NAND:      R[instruction[`alu_op0]] <= ~(R[instruction[`alu_op1]] & R[instruction[`alu_op2]]);
                        `NOR:       R[instruction[`alu_op0]] <= ~(R[instruction[`alu_op1]] | R[instruction[`alu_op2]]);
                        `XNOR:      R[instruction[`alu_op0]] <= ~(R[instruction[`alu_op1]] ^ R[instruction[`alu_op2]]);
                        `SHIFTR:    R[instruction[`alu_op0]] <= R[instruction[`alu_op0]] >> instruction[`val];
                        `SHIFTRA:   R[instruction[`alu_op0]] <= R[instruction[`alu_op0]] >>> instruction[`val];
                        `SHIFTL:    R[instruction[`alu_op0]] <= R[instruction[`alu_op0]] << instruction[`val];
                    endcase
                    pc <= pc + 1;
                end
                `data_transfer: begin
                    pc <= pc + 1;
                end
                `branch: begin            
                    case (instruction[`branch_opcode])
                        `JMP: begin
                            pc <= R[instruction[`jmp_op0]];
                        end
                        `JMPR: begin
                            pc <= pc + instruction[`jmpr_offset];
                        end
                        `JMPcond: begin
                            case (instruction[`jmpc_cond])
                                `N: begin
                                    if (R[instruction[`jmpc_op0]][`D_BITS-1])
                                        pc <= R[instruction[`jmpc_op1]];
                                    else    
                                        pc <= pc + 1;
                                end
                                `NN: begin
                                    if (!R[instruction[`jmpc_op0]][`D_BITS-1])
                                        pc <= R[instruction[`jmpc_op1]];
                                    else
                                        pc <= pc + 1;
                                end
                                `Z: begin
                                    if (R[instruction[`jmpc_op0]] == 0)
                                        pc <= R[instruction[`jmpc_op1]];
                                    else
                                        pc <= pc + 1;
                                end
                                `NZ: begin
                                    if (R[instruction[`jmpc_op0]] != 0)
                                        pc <= R[instruction[`jmpc_op1]];
                                    else
                                        pc <= pc + 1;
                                end
                            endcase
                        end
                        `JMPRcond: begin
                            case (instruction[`jmpc_cond])
                                `N: begin
                                    if (R[instruction[`jmpc_op0]][`D_BITS-1])
                                        pc <= pc + instruction[`jmpc_offset];
                                    else    
                                        pc <= pc + 1;
                                end
                                `NN: begin
                                    if (!R[instruction[`jmpc_op0]][`D_BITS-1])
                                        pc <= pc + instruction[`jmpc_offset];
                                    else
                                        pc <= pc + 1;
                                end
                                `Z: begin
                                    if (R[instruction[`jmpc_op0]] == 0)
                                        pc <= pc + instruction[`jmpc_offset];
                                    else
                                        pc <= pc + 1;
                                end
                                `NZ: begin
                                    if (R[instruction[`jmpc_op0]] != 0)
                                        pc <= pc + instruction[`jmpc_offset];
                                    else
                                        pc <= pc + 1;
                                end
                            endcase
                        end
                    endcase
                end
                `halt: ;
                default: ;
            endcase
        end
    end
endmodule
