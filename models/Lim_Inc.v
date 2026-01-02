`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     05/05/2019 00:16 AM
// Design Name:     EE3 lab1
// Module Name:     Lim_Inc
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool Versions:   Vivado 2016.4
// Description:     Incrementor modulo L, where the input a is *saturated* at L 
//                  If a+ci>L, then the output will be s=0,co=1 anyway.
// 
// Dependencies:    CSA
// 
// Revision:        3.0
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Lim_Inc(a, ci, sum, co);
    
    parameter L = 7; // Limit value
    localparam N = $clog2(L);  // N = ceil(log2(L))
    
    input [N-1:0] a;
    input ci;
    output [N-1:0] sum;
    output co;

    wire [N-1:0] sum_temp;
    wire co_temp;
    
    // Convert ci to N-bit vector for CSA
    wire [N-1:0] b_const = {N{1'b0}};
    
    // Use CSA to add a and ci
    CSA #(.N(N)) csa_inst (
        .a(a),
        .b(b_const),  // b is 0
        .ci(ci),
        .sum(sum_temp),
        .co(co_temp)
    );
    
    // Check if result >= L
    // We need to handle both cases: co_temp=1 OR sum_temp >= L
    wire result_ge_L;
    
    // Create an (N+1)-bit value by concatenating co_temp and sum_temp
    // This represents the full result of a + ci
    wire [N:0] full_result = {co_temp, sum_temp};
    
    // Compare with L
    // If full_result >= L, then result_ge_L = 1
    assign result_ge_L = (full_result >= L);
    
    // Output logic
    assign sum = result_ge_L ? {N{1'b0}} : sum_temp;
    assign co = result_ge_L;
    
endmodule