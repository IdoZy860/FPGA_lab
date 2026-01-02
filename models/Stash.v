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
   
   input clk, reset, sample_in_valid, next_sample;
   input [7:0] sample_in;
   output [7:0] sample_out;
   
   // Local parameters - fix width calculation
   // For pointers counting 0 to DEPTH-1, we need $clog2(DEPTH) bits
   localparam PTR_WIDTH = $clog2(DEPTH);
   
   // For Lim_Inc we need to count 0 to DEPTH-1, then wrap around
   // So L = DEPTH (counts 0 to DEPTH-1, wraps at DEPTH)
   localparam LIM_INC_L = DEPTH;
   
   // Internal registers
   reg [7:0] memory [0:DEPTH-1];  // Storage for samples
   reg [PTR_WIDTH-1:0] write_ptr;  // Pointer to next location to write
   reg [PTR_WIDTH-1:0] read_ptr;   // Pointer to current sample being exposed
   reg [PTR_WIDTH:0] valid_count;  // Number of valid samples (one extra bit)
   
   // Wires for Lim_Inc outputs - match the width of Lim_Inc
   // Lim_Inc with L=DEPTH will have width = $clog2(DEPTH) = PTR_WIDTH
   wire [PTR_WIDTH-1:0] next_write_ptr;
   wire [PTR_WIDTH-1:0] next_read_ptr;
   wire write_ptr_co, read_ptr_co;
   
   // Instantiate Lim_Inc for write pointer
   // We want to count from 0 to DEPTH-1, then wrap to 0
   // So L should be DEPTH (not DEPTH-1)
   Lim_Inc #(.L(LIM_INC_L)) write_ptr_inc (
       .a(write_ptr),
       .ci(sample_in_valid),
       .sum(next_write_ptr),
       .co(write_ptr_co)
   );
   
   // Instantiate Lim_Inc for read pointer
   Lim_Inc #(.L(LIM_INC_L)) read_ptr_inc (
       .a(read_ptr),
       .ci(next_sample && (valid_count > 0)),
       .sum(next_read_ptr),
       .co(read_ptr_co)
   );
   
   // Sample output logic
   // When storing a new sample, show it immediately on sample_out
   // Otherwise, show the sample at read_ptr
   assign sample_out = (sample_in_valid) ? sample_in : 
                      (valid_count == 0) ? 8'b0 : memory[read_ptr];
   
   // Update pointers and memory
   integer i;
   always @(posedge clk) begin
       if (reset) begin
           // Reset all pointers and clear memory
           write_ptr <= 0;
           read_ptr <= 0;
           valid_count <= 0;
           
           // Clear all memory locations
           for (i = 0; i < DEPTH; i = i + 1) begin
               memory[i] <= 8'b0;
           end
       end
       else begin
           // Handle sample storage
           if (sample_in_valid) begin
               // Store the sample at current write pointer
               memory[write_ptr] <= sample_in;
               
               // Update valid count (saturate at DEPTH)
               if (valid_count < DEPTH) begin
                   valid_count <= valid_count + 1;
               end
               
               // When storing a new sample, ALWAYS jump read pointer to it
               // This meets the requirement: "jump to the new sample"
               read_ptr <= write_ptr;
               
               // Update write pointer (will wrap automatically via Lim_Inc)
               write_ptr <= next_write_ptr;
           end
           // Handle next_sample request
           else if (next_sample && (valid_count > 0)) begin
               // Advance read pointer (will wrap automatically via Lim_Inc)
               read_ptr <= next_read_ptr;
           end
       end
   end

endmodule