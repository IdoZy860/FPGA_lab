`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        Leo Segre
// 
// Create Date:     05/05/2019 00:19 AM
// Design Name:     EE3 lab1
// Module Name:     Stash
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     a Stash that stores all the samples in order upon sample_in and sample_in_valid.
//                  It exposes the chosen sample by sample_out and the exposed sample can be changed by next_sample. 
// Dependencies:    Lim_Inc
//
// Revision         1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Stash(clk, reset, sample_in, sample_in_valid, next_sample, sample_out);

   parameter DEPTH = 5;
   localparam ADDR_WIDTH=$clog2(DEPTH);
   input clk, reset, sample_in_valid, next_sample;
   input [7:0] sample_in;
   output [7:0] sample_out;
   
   reg[ADDR_WIDTH-1:0] cur_address;
   wire[ADDR_WIDTH-1:0] next_address;
   wire overflow;
   
   reg[7:0] stash_mem [DEPTH-1:0]; // makes DEPTH time 8 bit registers
   integer i;
   
   Lim_Inc #(.L(DEPTH)) PointerCounter (  
    .a(cur_address), .ci(next_sample), .sum(next_address), .co(overflow));
    
    always @(posedge clk or posedge reset) begin
           if (reset) begin
                cur_address<=0;
                for (i=0;i<DEPTH;i=i+1) begin
                    stash_mem[i]<=0;
                end
            end
            else begin
                if (next_sample) begin
                    cur_address<=next_address;
                end
                if (sample_in_valid) begin
                    for (i=DEPTH-1;i>0;i=i-1) begin
                        stash_mem[i]<=stash_mem[i-1];
                    end
                    stash_mem[0]<=sample_in;
                end
            end
            end
                assign sample_out = sample_in_valid? sample_in : stash_mem[cur_address];
endmodule