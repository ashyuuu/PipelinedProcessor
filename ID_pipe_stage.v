`timescale 1ns / 1ps


module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write,
    input  [4:0] mem_wb_write_reg_addr,
    input  [31:0] mem_wb_write_back_data,
    input  Data_Hazard,
    input  Control_Hazard,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
    //wire temp;
    wire branch, w_branch_taken;
    //wire [11:0] ins;
    wire reg_dst;
    wire mem_r, mem_w, alu_s, reg_w, mem_2_reg; 
    wire [1:0] alu_o;
    wire det;
    wire [31:0] n_reg1, n_reg2;
    wire [31:0] n_imm_v, shifted_addr;
    wire [25:0] w_j_addr;
    
    // write your code here 
    // Remember that we test if the branch is taken or not in the decode stage. 
    //reg [31:0] reg_array [31:0]; 	
    assign det = ~Data_Hazard | Control_Hazard;
    
    register_file reg_file (
    .clk(clk),  
    .reset(reset),  
    .reg_write_en(mem_wb_reg_write),  
    .reg_write_dest(mem_wb_write_reg_addr),  
    .reg_write_data(mem_wb_write_back_data),  
    .reg_read_addr_1(instr[25:21]), 
    .reg_read_addr_2(instr[20:16]), 
    .reg_read_data_1(n_reg1),
    .reg_read_data_2(n_reg2)); 
    //end
    // assign temp = ((n_reg1 ^ n_reg2 )==32 'b0) ? 1'b1: 1'b0;//
    assign branch_taken = w_branch_taken;
    assign w_branch_taken = branch & (((n_reg1 ^ n_reg2) == 32'd0) ? 1'b1:1'b0);
    assign w_j_addr = instr[25:0]  << 2;
    assign jump_address = w_j_addr[9:0];
    
    assign reg1 = n_reg1;
    assign reg2 = n_reg2;
    assign imm_value = n_imm_v;
    
    sign_extend sign_ex_inst (
        .sign_ex_in(instr[15:0]),
        .sign_ex_out(n_imm_v));
    assign shifted_addr = imm_value<<2;
    assign branch_address = pc_plus4+shifted_addr[9:0];
    
    mux2 #(.mux_width(5)) reg_mux 
    (   .a(instr[20:16]),
        .b(instr[15:11]),
        .sel(reg_dst),
        .y(destination_reg));

    assign jump_address = instr[25:0] << 2;
    
    mux2 #(.mux_width(1)) reg_w_mux 
    (   .a(reg_w),
        .b(1'b0),
        .sel(det), 
        .y(reg_write));
    
    mux2 #(.mux_width(1)) mem_r_mux 
    (   .a(mem_r),
        .b(1'b0),
        .sel(det), 
        .y(mem_read));
    
    mux2 #(.mux_width(1)) mem_w_mux 
    (   .a(mem_w),
        .b(1'b0),
        .sel(det), 
        .y(mem_write));
    
    mux2 #(.mux_width(2)) alu_o_mux 
    (   .a(alu_o),
        .b(2'b00),
        .sel(det), 
        .y(alu_op));
    
    mux2 #(.mux_width(1)) alu_s_mux 
    (   .a(alu_s),
        .b(1'b0),
        .sel(det), 
        .y(alu_src));
    
    mux2 #(.mux_width(1)) mem_2_reg_mux 
    (   .a(mem_2_reg),
        .b(1'b0),
        .sel(det), 
        .y(mem_to_reg));
    
    control ctrl(.reset(reset) ,
        .opcode(instr[31:26]),
        .reg_dst(reg_dst), 
        .mem_to_reg(mem_2_reg),
        .alu_op(alu_o),
        .mem_read(mem_r), 
        .mem_write(mem_w),
        .alu_src(alu_s), 
        .reg_write(reg_w), 
        .branch(branch), 
        .jump(jump)
    );
endmodule
