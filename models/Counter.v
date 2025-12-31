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
   
   // ============ ADD THIS CODE HERE ============
   // Calculate widths based on Lim_Inc parameters
   localparam ONES_WIDTH = $clog2(9+1); // 4 bits for 0-9
   localparam TENS_WIDTH = $clog2(5+1); // 3 bits for 0-5
   
   reg [ONES_WIDTH-1:0] ones_seconds;    // [3:0] - 4 bits  
   reg [TENS_WIDTH-1:0] tens_seconds;    // [2:0] - 3 bits
   // ============================================
   
   // Wires for Lim_Inc outputs
   wire [ONES_WIDTH-1:0] ones_next;
   wire [TENS_WIDTH-1:0] tens_next;
   wire ones_co;
   wire tens_co;
   
   // Wire for one-second enable signal
   wire one_second_enable;
   
   // FILL HERE THE LIMITED-COUNTER INSTANCES
   // Ones seconds counter (0-9)
   Lim_Inc #(9) ones_inc (
       .a(ones_seconds),
       .ci(one_second_enable && count_enabled),
       .sum(ones_next),
       .co(ones_co)
   );
   
   // Tens seconds counter (0-5)
   Lim_Inc #(5) tens_inc (
       .a(tens_seconds),
       .ci(one_second_enable && count_enabled && ones_co),
       .sum(tens_next),
       .co(tens_co)
   );
   
   // One-second enable: when clk_cnt reaches CLK_FREQ-1
   assign one_second_enable = (clk_cnt == CLK_FREQ - 1);
   
   // ============ UPDATE THIS LINE ============
   // Output time reading: zero-extend to 4 bits each
   assign time_reading = {
       {4-TENS_WIDTH{1'b0}}, tens_seconds,  // Zero-extend 3 bits to 4 bits
       ones_seconds                         // Already 4 bits
   };
   // ==========================================
   
   //------------- Synchronous ----------------
   always @(posedge clk)
     begin
        // FILL HERE THE ADVANCING OF THE REGISTERS AS A FUNCTION OF init_regs, count_enabled
        if (init_regs) begin
            // Reset all counters
            clk_cnt <= 0;
            ones_seconds <= 0;
            tens_seconds <= 0;
        end else begin
            // Clock counter logic
            if (count_enabled) begin
                if (clk_cnt == CLK_FREQ - 1) begin
                    clk_cnt <= 0; // Reset at 1 second
                end else begin
                    clk_cnt <= clk_cnt + 1; // Increment clock counter
                end
            end
            
            // Seconds counters logic
            if (one_second_enable && count_enabled) begin
                // Update ones seconds with the output from Lim_Inc
                ones_seconds <= ones_next;
                
                // Update tens seconds with the output from Lim_Inc
                tens_seconds <= tens_next;
            end
        end
     end

endmodule
