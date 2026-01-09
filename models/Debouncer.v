`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     05/05/2019 02:59:38 AM
// Design Name:     EE3 lab1
// Module Name:     Debouncer
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices: 
// Tool versions: 
// Description:     receives an unstable (toggling) digital signal as an input
//                  outputs a single cycle high (1) pulse upon receiving 2**(COUNTER_BITS-1) more ones than zeros.
//                  This creates a hysteresis phenomenon, robust to toggling.
//              
//                  This module should be used to process a normally-off signal and to catch its long lasting "1" period and
//                  shrinking them into a single cycle "1".
//
// Dependencies:    None
//
// Revision:        3.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Debouncer(clk, input_unstable, output_stable);

   input clk, input_unstable;
   output reg output_stable;
   
   parameter COUNTER_BITS = 7;
   
   reg [COUNTER_BITS-1:0] counter = 0; // Initialize to 0
   reg counter_was_full = 0;           // Initialize to 0
   
   always @(posedge clk)
     begin
        // Store previous state of counter
        counter_was_full <= (counter == {COUNTER_BITS{1'b1}});
        
        // Update counter based on input
        if (input_unstable == 1)
            counter <= (counter < {COUNTER_BITS{1'b1}}) ? counter + 1 : counter;
        else
            counter <= (counter > {COUNTER_BITS{1'b0}}) ? counter - 1 : counter;
            
        // Generate single-cycle pulse when counter becomes full
        if ((counter == {COUNTER_BITS{1'b1}}) && !counter_was_full)
            output_stable <= 1'b1;
        else
            output_stable <= 1'b0;
     end
       
endmodule