`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     05/05/2019 02:59:38 AM
// Design Name:     EE3 lab1
// Module Name:     Ctl_tb
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool Versions:   Vivado 2016.4
// Description:     test bench for the control.
// Dependencies:    None
//
// Revision: 		3.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Ctl_tb();

    reg clk, reset, trig, split, correct, loop_was_skipped;
    wire init_regs, count_enabled;
    //integer ai,cii;
    
    // Instantiate the UUT (Unit Under Test)
    // FILL HERE
    Ctl uut (
        .clk(clk), .reset(reset), .trig(trig), .split(split),
        .init_regs(init_regs), .count_enabled(count_enabled));
    
    initial begin
        correct = 1;
        clk = 0; 
        reset = 1; 
        trig = 0;
        split = 0;
        #10
        reset = 0; 
        loop_was_skipped=0;
        correct = correct & init_regs & ~count_enabled;
        #20
        // FILL HERE - TEST VARIOUS STATE TRANSITION 
		// AND COMPARE AGAINST EXPECTED OUTPUT SIGNALS
		
		
        trig=1; // start counting
        #10     // waiting to the clock to get this
        trig=0;  // release the button
        #10      // waiting to the clock to get this
        if (init_regs !==0 || count_enabled !==1) begin
            correct=0;   // if we are counting so init_regs must be 0 and count enabled 1
            $display("error, didnt start counting");
        end
        #10
        
        trig=1; // stop counting
        #10
        trig=0;
        #10
        if (init_regs!==0 || count_enabled !==0) begin  // stop counting
            correct=0;
            $display("error, didnt stopped counting");
        end
        #10
        
        trig=1; // start counting again
        #10     // waiting to the clock to get this
        trig=0;  // release the button
        #10      // waiting to the clock to get this
        if (init_regs !==0 || count_enabled !==1) begin
            correct=0;   // if we are counting so init_regs must be 0 and count enabled 1
            $display("error, didnt continute counting");
        end
        #10
        
        split=1; // split when counting
        #10
        split=0;
        #10
        if (count_enabled!==1 || init_regs!==0) begin
            correct=0;
            $display("error, got count: %b,init: %b, expected: count: %b, init: %b",count_enabled,init_regs,1'b1,1'b0);
        end
        #10

        trig=1;  // stop counting when split
        #10
        trig=0;  
        #10;
        if (init_regs!==0 || count_enabled !==0) begin  // stop counting
            correct=0;
            $display("error, didnt stopped when split");
        end
        #10
        
        trig=1;  // start counting again when split
        #10
        trig=0;  
        #10;
        if (init_regs!==0 || count_enabled !==1) begin  
            correct=0;
            $display("error, didnt start when counting");
        end
        #10
        
        split=1;  // split again
        #10;
        split=0;
        #10
        if( init_regs!==0 || count_enabled!==1) begin
            correct = 0;
            $display("error, did not continue from split");
        end
        #10

        trig=1;    // stop counting
        #10
        trig=0;
        #10
        if (init_regs!==0 || count_enabled!==0) begin
            correct = 0;
            $display("error, did not stopped coutning, expected count_enabled:0, got %b",count_enabled);
        end
        #10

//        trig=1;     // start counting
//        #10
//        trig=0;
//        #10
//        if (init_regs!==0 || count_enabled!==1) begin
//            correct = 0;
//            $display("error, did not stopped counting again, expected count_enabled =1, got %b", count_enabled);
//        end
//        #10

        reset=1;       // reset when not counting
        #10
        reset=0;
        #10
        if (init_regs!==1 || count_enabled!==0) begin
            correct = 0;
            $display("error, did not reset when paused");
         end
         #10

         trig=1;       // stop counting from 0
         #10
         trig=0;
         #10
         if (init_regs!==0 || count_enabled!==1) begin
            correct=0;
            $display("error, did not start counting after reset");
         end
         #10

         reset=1;      // reset when counting
         #10
         reset=0;
         #10
         if (init_regs!==1 || count_enabled!==0) begin
            correct=0;
            $display("error, did not reset when counting");
         end
        // end of my code
        #10        
        if (correct)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");
        $finish;
    end
    
    always #5 clk = ~clk;
    
endmodule