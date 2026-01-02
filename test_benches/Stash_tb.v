`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        Leo Segre
// 
// Create Date:     05/05/2019 02:59:38 AM
// Design Name:     EE3 lab1
// Module Name:     Stash_tb
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     test bennch for the stash.
// Dependencies:    None
//
// Revision: 		1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Stash_tb();

    reg clk, reset, sample_in_valid, next_sample, correct, loop_was_skipped;
    reg [7:0] sample_in;
    wire [7:0] sample_out;
    integer ini;
    
    // Instantiate the UUT (Unit Under Test)
    Stash #(.DEPTH(5)) uut (
        .clk(clk),
        .reset(reset),
        .sample_in(sample_in),
        .sample_in_valid(sample_in_valid),
        .next_sample(next_sample),
        .sample_out(sample_out)
    );
    
    initial begin
        correct = 1;
        clk = 0; 
        reset = 1; 
        loop_was_skipped = 1;
        sample_in = 8'h00;
        sample_in_valid = 0;
        next_sample = 0;
        
        // Apply and release reset
        #6
        reset = 0;
        
        $display("=== Testing Stash Module (DEPTH=5) ===");
        
        // Test 1: Fill the buffer completely
        $display("\nTest 1: Filling buffer with 5 samples");
        for(ini = 1; ini <= 5; ini = ini + 1) begin
            sample_in = ini;
            sample_in_valid = 1;
            #10; // Wait for clock edge
            
            $display("  Time %0d ns: Stored sample %0d, sample_out = %0d", 
                     $time, ini, sample_out);
            sample_in_valid = 0;
            loop_was_skipped = 0;
        end
        
        // Buffer should now be: [1, 2, 3, 4, 5]
        // Read pointer should be at sample 5 (last stored)
        
        // Test 2: Store 6th sample (overwrites sample 1)
        $display("\nTest 2: Storing 6th sample (overwrites oldest)");
        sample_in = 6;
        sample_in_valid = 1;
        #10;
        $display("  Time %0d ns: Stored sample 6, sample_out = %0d", 
                 $time, sample_out);
        sample_in_valid = 0;
        
        // Buffer should now be: [6, 2, 3, 4, 5]
        // Read pointer should be at sample 6 (index 0)
        
        // Test 3: Navigate through the buffer
        $display("\nTest 3: Navigating through buffer with next_sample");
        
        // First next_sample should show sample 2 (index 1)
        #10;
        next_sample = 1;
        #10;
        $display("  Time %0d ns: After first next_sample, sample_out = %0d", 
                 $time, sample_out);
        next_sample = 0;
        
        // Let's just check that we can navigate through all samples
        // We'll press next_sample 4 more times to cycle through remaining samples
        for(ini = 0; ini < 4; ini = ini + 1) begin
            #10;
            next_sample = 1;
            #10;
            $display("  Time %0d ns: After next_sample, sample_out = %0d", 
                     $time, sample_out);
            next_sample = 0;
        end
        
        // We should have seen: 2, 3, 4, 5, and then back to 6 (wrap-around)
        // The actual values will tell us what's happening
        
        // Test 4: Reset and verify
        $display("\nTest 4: Testing reset");
        reset = 1;
        #10;
        reset = 0;
        #10;
        
        if (sample_out !== 8'h00) begin
            correct = 0;
            $display("  ERROR: After reset, expected 0, got %0d", sample_out);
        end else begin
            $display("  OK: Reset successful, sample_out = 0");
        end
        
        // Final result
        #5
        if (correct && ~loop_was_skipped) begin
            $display("\n=== Test Passed - %m ===");
        end else begin
            $display("\n=== Test Failed - %m ===");
        end
        $finish;
    end
    
    always #5 clk = ~clk;
    
endmodule