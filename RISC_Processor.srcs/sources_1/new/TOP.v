`timescale 1ns / 1ps
`include "macros.vh"

module TOP(
    input clk,
    input rst_n,
    input [`I_BITS - 1:0] instr,
    input signed [`D_BITS - 1:0] data_in,
    output read,
    output write,
    output signed [`A_BITS - 1:0] pc,
    output [`A_BITS - 1:0] addr,
    output signed [`D_BITS - 1:0] data_out
);

    wire load_flag;
    wire halt_flag;
    wire jmp_flag;
    wire jmpr_flag;
    wire valid_jmp;
    wire signed [`A_BITS - 1:0] new_pc;

    assign read = load_flag;

    wire [`I_BITS - 1:0] instr_fetch_to_ir;

    FETCH fetch_inst (
        .clk            (clk),
        .rst_n          (rst_n),
        .instr_in       (instr),
        .load_flag      (load_flag),
        .halt_flag      (halt_flag),
        .jmp_flag       (jmp_flag),
        .jmpr_flag      (jmpr_flag),
        .valid_jmp      (valid_jmp),
        .new_pc         (new_pc),
        .pc             (pc),
        .instr_out      (instr_fetch_to_ir)
    );

    wire [`I_BITS - 1:0] instr_ir_to_read;

    IR ir_inst (
        .clk            (clk),
        .rst_n          (rst_n),
        .load_flag      (load_flag),
        .halt_flag      (halt_flag),
        .jmp_flag       (jmp_flag),
        .jmpr_flag      (jmpr_flag),
        .valid_jmp      (valid_jmp),
        .instr_in       (instr_fetch_to_ir),
        .instr_out      (instr_ir_to_read)
    );

    wire signed [`D_BITS - 1:0] rf_op0_data, rf_op1_data, rf_op2_data;
    wire [2:0]  op0_idx, op1_idx, op2_idx;
    wire [2:0]  dest_execute, dest_wb;
    wire signed [`D_BITS - 1:0] res_execute, res_wb;
    
    wire signed [`D_BITS- 1:0] rd_op0_out, rd_op1_out, rd_op2_out;
    wire [`I_BITS - 1:0] instr_read_out;
    wire [`VAL - 1:0] val_bus;
    wire signed [`CONST - 1:0] const_bus;
    wire signed [`OFFSET - 1:0] offset_bus;
    wire [2:0] cond_bus;

    READ read_inst (
        .instr_in       (instr_ir_to_read),
        .op0_data_regs  (rf_op0_data),
        .op1_data_regs  (rf_op1_data),
        .op2_data_regs  (rf_op2_data),
        .dest_execute   (dest_execute),
        .result_execute (res_execute),
        .dest           (dest_wb),
        .result         (res_wb),
        .instr_out      (instr_read_out),
        .op0            (op0_idx),
        .op1            (op1_idx),
        .op2            (op2_idx),
        .op0_data_out   (rd_op0_out),
        .op1_data_out   (rd_op1_out),
        .op2_data_out   (rd_op2_out),
        .val            (val_bus),
        .const          (const_bus),
        .offset         (offset_bus),
        .cond           (cond_bus)
    );

    REGS regs_inst (
        .clk      (clk),
        .rst_n    (rst_n),
        .op0      (op0_idx),
        .op1      (op1_idx),
        .op2      (op2_idx),
        .dest     (dest_wb),
        .result   (res_wb),
        .op0_data (rf_op0_data),
        .op1_data (rf_op1_data),
        .op2_data (rf_op2_data)
    );

    wire [`I_BITS - 1:0] instr_rr_out;
    wire signed [`D_BITS - 1:0] rr_op0, rr_op1, rr_op2;
    wire [`VAL - 1:0] rr_val;
    wire signed [`CONST - 1:0] rr_const;
    wire signed [`OFFSET - 1:0] rr_offset;
    wire [2:0] rr_cond;

    RR rr_inst (
        .clk            (clk),
        .rst_n          (rst_n),
        .load_flag      (load_flag),
        .halt_flag      (halt_flag),
        .jmp_flag       (jmp_flag),
        .jmpr_flag      (jmpr_flag),
        .valid_jmp      (valid_jmp),
        .instr_in       (instr_read_out),
        .op0_data_in    (rd_op0_out),
        .op1_data_in    (rd_op1_out),
        .op2_data_in    (rd_op2_out),
        .val_in         (val_bus),
        .const_in       (const_bus),
        .offset_in      (offset_bus),
        .cond_in        (cond_bus),
        .instr_out      (instr_rr_out),
        .op0_data_out   (rr_op0),
        .op1_data_out   (rr_op1),
        .op2_data_out   (rr_op2),
        .val_out        (rr_val),
        .const_out      (rr_const),
        .offset_out     (rr_offset),
        .cond_out       (rr_cond)
    );

    wire [`I_BITS - 1:0] instr_exec_out;

    EXECUTE execute_inst (
        .instr_in       (instr_rr_out),
        .op0_data       (rr_op0),
        .op1_data       (rr_op1),
        .op2_data       (rr_op2),
        .val            (rr_val),
        .const          (rr_const),
        .offset         (rr_offset),
        .cond           (rr_cond),
        .instr_out      (instr_exec_out),
        .write          (write),
        .load_flag      (load_flag),
        .halt_flag      (halt_flag),
        .jmp_flag       (jmp_flag),
        .jmpr_flag      (jmpr_flag),
        .valid_jmp      (valid_jmp),
        .addr           (addr),
        .data_out       (data_out),
        .dest           (dest_execute),
        .result         (res_execute),
        .new_pc         (new_pc)
    );

    wire [`I_BITS - 1:0] instr_er_out;
    wire [2:0] er_dest;
    wire signed [`D_BITS - 1:0] er_result;

    ER er_reg (
        .clk            (clk),
        .rst_n          (rst_n),
        .halt_flag      (halt_flag),
        .instr_in       (instr_exec_out),
        .dest_in        (dest_execute),
        .result_in      (res_execute),
        .instr_out      (instr_er_out),
        .dest_out       (er_dest),
        .result_out     (er_result)
    );

    WRITE_BACK wb_inst (
        .instr_in       (instr_er_out),
        .dest_in        (er_dest),
        .result_in      (er_result),
        .data_in        (data_in),
        .dest_out       (dest_wb),
        .result_out     (res_wb)
    );

endmodule
