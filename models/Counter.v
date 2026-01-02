`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     05/05/2019 00:19 AM
// Design Name:     EE3 lab1
// Module Name:     Counter
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     a counter that advances its reading as long as time_reading 
//                  signal is high and zeroes its reading upon init_regs=1 input.
//                  the time_reading output represents: 
//                  {dekaseconds,seconds}
// Dependencies:    Lim_Inc
//
// Revision         3.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Counter(clk, init_regs, count_enabled, time_reading);

   parameter CLK_FREQ = 100000000; // in Hz
   
   input clk, init_regs, count_enabled;
   output [7:0] time_reading;

   reg [$clog2(CLK_FREQ)-1:0] clk_cnt;
   
   // Calculate widths based on BCD counters (0-9 for ones, 0-5 for tens)
   // For L=10, $clog2(10) = 4 bits (0-9 requires values up to 9, which is 1001)
   // For L=6, $clog2(6) = 3 bits (0-5 requires values up to 5, which is 101)
   localparam ONES_WIDTH = 4;  // 4 bits for 0-9 (BCD ones)
   localparam TENS_WIDTH = 3;  // 3 bits for 0-5 (BCD tens)
   
   reg [ONES_WIDTH-1:0] ones_seconds;    // [3:0] - 4 bits  
   reg [TENS_WIDTH-1:0] tens_seconds;    // [2:0] - 3 bits
   
   // Wires for Lim_Inc outputs
   wire [ONES_WIDTH-1:0] ones_next;
   wire [TENS_WIDTH-1:0] tens_next;
   wire ones_co;
   wire tens_co;
   
   // Wire for one-second enable signal
   wire one_second_enable;
   
   // ============ FIXED: Correct L values for BCD ============
   // Ones seconds counter (0-9) - needs L=10 (counts 0-9, then rolls over)
   Lim_Inc #(.L(10)) ones_inc (
       .a(ones_seconds),
       .ci(one_second_enable && count_enabled),
       .sum(ones_next),
       .co(ones_co)
   );
   
   // Tens seconds counter (0-5) - needs L=6 (counts 0-5, then rolls over)
   Lim_Inc #(.L(6)) tens_inc (
       .a(tens_seconds),
       .ci(one_second_enable && count_enabled && ones_co),
       .sum(tens_next),
       .co(tens_co)
   );
   
   // One-second enable: when clk_cnt reaches CLK_FREQ-1
   assign one_second_enable = (clk_cnt == CLK_FREQ - 1);
   
   // Output time reading: concatenate with proper zero-extension
   // tens_seconds is 3 bits, needs to be zero-extended to 4 bits
   assign time_reading = {
       {1'b0, tens_seconds},  // Zero-extend 3-bit tens to 4 bits
       ones_seconds            // 4-bit ones
   };
   
   //------------- Synchronous ----------------
   always @(posedge clk)
     begin
        // Reset logic
        if (init_regs) begin
            clk_cnt <= 0;
            ones_seconds <= 0;
            tens_seconds <= 0;
        end else begin
            // Clock counter logic
            if (count_enabled) begin
                if (one_second_enable) begin
                    clk_cnt <= 0; // Reset at 1 second
                end else begin
                    clk_cnt <= clk_cnt + 1; // Increment clock counter
                end
            end
            
            // Seconds counters logic - update only when one_second_enable is active
            if (one_second_enable && count_enabled) begin
                ones_seconds <= ones_next;
                tens_seconds <= tens_next;
            end
        end
     end

endmodule