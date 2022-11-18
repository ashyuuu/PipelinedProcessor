`timescale 1ns / 1ps


module mips_32(
    input clk, reset,  
    output[31:0] result
    );
    
// define all the wires here. You need to define more wires than the ones you did in Lab2
wire [9:0] pc_plus4, if_id_pc_plus4;
wire [31:0] instr, if_id_instr, id_ex_instr, ex_mem_instr;
wire [31:0] reg1, reg2, id_ex_reg1, id_ex_reg2;
wire [31:0] imm_value, id_ex_imm_value;
wire [9:0] branch_address, jump_address;
wire branch_taken, jump;
wire [4:0] destination_reg, id_ex_destination_reg;
wire mem_to_reg, id_ex_mem_to_reg, ex_mem_mem_to_reg, mem_wb_mem_to_reg;
wire [1:0] alu_op, id_ex_alu_op;
wire mem_read, id_ex_mem_read, ex_mem_mem_read, mem_write, id_ex_mem_write, ex_mem_mem_write;
wire alu_src, id_ex_alu_src;
wire reg_write, id_ex_reg_write, ex_mem_reg_write, mem_wb_reg_write;
wire [31:0] alu_in2_out, ex_mem_alu_in2_out;
wire [31:0] alu_result, ex_mem_alu_result, mem_wb_alu_result;
wire [31:0] mem_read_data, mem_wb_mem_read_data;
wire [31:0] write_back_data;
wire [4:0] ex_mem_destination_reg, mem_wb_destination_reg;
wire [1:0] Forward_A, Forward_B;
wire DataHazard, IF_Flush;

// Build the pipeline as indicated in the lab manual

///////////////////////////// Instruction Fetch    
    // Complete your code here      
IF_pipe_stage IF(.clk(clk), .reset(reset), 
.en(DataHazard), 
.branch_address(branch_address), 
.jump_address(jump_address), 
.branch_taken(branch_taken),
.jump(jump), 
.pc_plus4(pc_plus4), 
.instr(instr));
       
///////////////////////////// IF/ID registers
    // Complete your code here
pipe_reg_en #(.WIDTH(10)) IFID_pcplus4(.clk(clk), .reset(reset), 
.en(DataHazard), .flush(IF_Flush), .d(pc_plus4), .q(if_id_pc_plus4));

pipe_reg_en #(.WIDTH(32)) IFID_instr(.clk(clk), .reset(reset), 
.en(DataHazard), .flush(IF_Flush), .d(instr), .q(if_id_instr));

///////////////////////////// Instruction Decode 
	// Complete your code here
ID_pipe_stage ID(.clk(clk), .reset(reset), 
.pc_plus4(if_id_pc_plus4), 
.instr(if_id_instr),
.mem_wb_reg_write(mem_wb_reg_write), 
.mem_wb_write_reg_addr(mem_wb_destination_reg),
.mem_wb_write_back_data(write_back_data), 
.Data_Hazard(DataHazard), .Control_Hazard(IF_Flush),
.reg1(reg1), .reg2(reg2), 
.imm_value(imm_value), 
.branch_address(branch_address), .jump_address(jump_address), 
.branch_taken(branch_taken), 
.destination_reg(destination_reg), 
.mem_to_reg(mem_to_reg), .alu_op(alu_op), .mem_read(mem_read), 
.mem_write(mem_write), .alu_src(alu_src), .reg_write(reg_write),  
.jump(jump));

           
///////////////////////////// ID/EX registers 
	// Complete your code here
pipe_reg #(.WIDTH(32)) IDEX_instr(.clk(clk), .reset(reset), .d(if_id_instr), .q(id_ex_instr));
pipe_reg #(.WIDTH(32)) IDEX_reg1(.clk(clk), .reset(reset), .d(reg1), .q(id_ex_reg1));
pipe_reg #(.WIDTH(32)) IDEX_reg2(.clk(clk), .reset(reset), .d(reg2), .q(id_ex_reg2));
pipe_reg #(.WIDTH(32)) IDEX_imm_value(.clk(clk), .reset(reset), .d(imm_value), .q(id_ex_imm_value));
pipe_reg #(.WIDTH(5)) IDEX_destination_reg(.clk(clk), .reset(reset), .d(destination_reg), .q(id_ex_destination_reg));
pipe_reg #(.WIDTH(1)) IDEX_mem_to_reg(.clk(clk), .reset(reset), .d(mem_to_reg), .q(id_ex_mem_to_reg));
pipe_reg #(.WIDTH(1)) IDEX_mem_read(.clk(clk), .reset(reset), .d(mem_read), .q(id_ex_mem_read));
pipe_reg #(.WIDTH(1)) IDEX_mem_write(.clk(clk), .reset(reset), .d(mem_write), .q(id_ex_mem_write));
pipe_reg #(.WIDTH(1)) IDEX_alu_src(.clk(clk), .reset(reset), .d(alu_src), .q(id_ex_alu_src));
pipe_reg #(.WIDTH(1)) IDEX_reg_write(.clk(clk), .reset(reset), .d(reg_write), .q(id_ex_reg_write));
pipe_reg #(.WIDTH(2)) IDEX_alu_op(.clk(clk), .reset(reset), .d(alu_op), .q(id_ex_alu_op));

///////////////////////////// Hazard_detection unit
	// Complete your code here    
Hazard_detection hd(.id_ex_mem_read(id_ex_mem_read), 
.id_ex_destination_reg(id_ex_destination_reg),
.if_id_rs(if_id_instr[25:21]), .if_id_rt(if_id_instr[20:16]), 
.branch_taken(branch_taken), .jump(jump),
.Data_Hazard(DataHazard), .IF_Flush(IF_Flush));
           
///////////////////////////// Execution    
	// Complete your code here
EX_pipe_stage ex(.id_ex_instr(id_ex_instr), 
.reg1(id_ex_reg1), .reg2(id_ex_reg2), 
.id_ex_imm_value(id_ex_imm_value),
.ex_mem_alu_result(ex_mem_alu_result), .mem_wb_write_back_result(write_back_data),
.id_ex_alu_src(id_ex_alu_src), .id_ex_alu_op(id_ex_alu_op), 
.Forward_A(Forward_A), .Forward_B(Forward_B),
.alu_in2_out(alu_in2_out), .alu_result(alu_result));
        
///////////////////////////// Forwarding unit
	// Complete your code here 
EX_Forwarding_unit forward(.ex_mem_reg_write(ex_mem_reg_write), 
.ex_mem_write_reg_addr(ex_mem_destination_reg),
.id_ex_instr_rs(id_ex_instr[25:21]), .id_ex_instr_rt(id_ex_instr[20:16]), 
.mem_wb_reg_write(mem_wb_reg_write), 
.mem_wb_write_reg_addr(mem_wb_destination_reg), 
.Forward_A(Forward_A), .Forward_B(Forward_B));
     
///////////////////////////// EX/MEM registers
	// Complete your code here 
pipe_reg #(.WIDTH(32)) EXMEM_instr(.clk(clk), .reset(reset), .d(id_ex_instr), .q(ex_mem_instr));
pipe_reg #(.WIDTH(5)) EXMEM_destination_reg(.clk(clk), .reset(reset), .d(id_ex_destination_reg), .q(ex_mem_destination_reg));
pipe_reg #(.WIDTH(32)) EXMEM_alu_result(.clk(clk), .reset(reset), .d(alu_result), .q(ex_mem_alu_result));
pipe_reg #(.WIDTH(32)) EXMEM_alu_in2_out(.clk(clk), .reset(reset), .d(alu_in2_out), .q(ex_mem_alu_in2_out));
pipe_reg #(.WIDTH(1)) EXMEM_mem_to_reg(.clk(clk), .reset(reset), .d(id_ex_mem_to_reg), .q(ex_mem_mem_to_reg));
pipe_reg #(.WIDTH(1)) EXMEM_mem_read(.clk(clk), .reset(reset), .d(id_ex_mem_read), .q(ex_mem_mem_read));
pipe_reg #(.WIDTH(1)) EXMEM_mem_write(.clk(clk), .reset(reset), .d(id_ex_mem_write), .q(ex_mem_mem_write));
pipe_reg #(.WIDTH(1)) EXMEM_reg_write(.clk(clk), .reset(reset), .d(id_ex_reg_write), .q(ex_mem_reg_write));
    
///////////////////////////// memory    
	// Complete your code here
data_memory data_mem(.clk(clk), .mem_access_addr(ex_mem_alu_result), .mem_write_data(ex_mem_alu_in2_out), 
.mem_write_en(ex_mem_mem_write), .mem_read_en(ex_mem_mem_read), 
.mem_read_data(mem_read_data));

///////////////////////////// MEM/WB registers  
	// Complete your code here
pipe_reg #(.WIDTH(32)) MEMWB_alu_result(.clk(clk), .reset(reset), .d(ex_mem_alu_result), .q(mem_wb_alu_result));
pipe_reg #(.WIDTH(32)) MEMWB_mem_read_data(.clk(clk), .reset(reset), .d(mem_read_data), .q(mem_wb_mem_read_data));
pipe_reg #(.WIDTH(1)) MEMWB_mem_to_reg(.clk(clk), .reset(reset), .d(ex_mem_mem_to_reg), .q(mem_wb_mem_to_reg));
pipe_reg #(.WIDTH(1)) MEMWB_reg_write(.clk(clk), .reset(reset), .d(ex_mem_reg_write), .q(mem_wb_reg_write));
pipe_reg #(.WIDTH(5)) MEMWB_destination_reg(.clk(clk), .reset(reset), .d(ex_mem_destination_reg), .q(mem_wb_destination_reg));   

///////////////////////////// writeback    
	// Complete your code here
mux2 #(.mux_width(32)) write_back 
    (   .a(mem_wb_alu_result), // unimplemented
        .b(mem_wb_mem_read_data),// unimplemented
        .sel(mem_wb_mem_to_reg), 
        .y(write_back_data));

assign result = write_back_data;    
endmodule
