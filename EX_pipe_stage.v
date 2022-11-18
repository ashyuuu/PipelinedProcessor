`timescale 1ns / 1ps

module EX_pipe_stage(
    input [31:0] id_ex_instr,
    input [31:0] reg1, reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
    );
    wire [3:0] ALU_Control_Wire;
    wire [31:0] temp_reg1;
    wire [31:0] temp_reg2;
    wire [31:0] temp_alu;
    wire [31:0] alu_r;
    wire zero;
//    wire zero;
//    assign zero = 1'b0;
    // Write your code here
    ALUControl aluc(.ALUOp(id_ex_alu_op), .Function(id_ex_instr[5:0]), .ALU_Control(ALU_Control_Wire));
    mux4 #(.mux_width(32)) reg1_mux 
    (   .a(reg1),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .d(32'b0),
        .sel(Forward_A), 
        .y(temp_reg1));
    
    mux4 #(.mux_width(32)) reg2_mux 
    (   .a(reg2),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .d(32'b0),
        .sel(Forward_B), 
        .y(temp_reg2));  
        
    assign alu_in2_out = temp_reg2;     
    assign alu_result = alu_r;
    
    mux2 #(.mux_width(32)) reg2_alu_mux 
    (   .a(temp_reg2),
        .b(id_ex_imm_value),
        .sel(id_ex_alu_src), 
        .y(temp_alu));  
    
    ALU my_alu (.a(temp_reg1), .b(temp_alu), .alu_control(ALU_Control_Wire), .zero(zero), .alu_result(alu_r));
endmodule
