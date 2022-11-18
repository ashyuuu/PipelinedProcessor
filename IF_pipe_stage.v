`timescale 1ns / 1ps


module IF_pipe_stage(
    input clk, reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
    );

// write your code here
reg [9:0] pc = 0;
wire [9:0] n_pc;
wire [9:0] temp;
wire [9:0] temp_pc4;


always @(posedge clk or posedge reset) begin
    if(reset)   
       pc <= 10'b0000000000;  
    else if (en) 
       pc <= n_pc;
end
assign temp_pc4 = pc + 10'b0000000100;
assign pc_plus4 = temp_pc4;
mux2 #(.mux_width(10)) branch_mux 
    (   .a(temp_pc4),
        .b(branch_address),
        .sel(branch_taken),
        .y(temp));  
        
     mux2 #(.mux_width(10)) jump_mux 
    (   .a(temp),
        .b(jump_address),
        .sel(jump),
        .y(n_pc)); 
        
     instruction_mem inst_mem (
        .read_addr(pc),
        .data(instr));
endmodule
