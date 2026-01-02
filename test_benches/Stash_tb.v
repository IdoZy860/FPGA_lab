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
    // FILL HERE
    Stash #(.DEPTH(5)) uut (
        .clk(clk),
        .reset(reset),
        .sample_in(sample_in),
        .sample_in_valid(sample_in_valid),
        .next_sample(next_sample),
        .sample_out(sample_out)
    );
    
    initial begin
        $dumpfile("Stash_tb.vcd");
        $dumpvars(0, Stash_tb);
        $display("=== Starting Stash Test (DEPTH=5) ===");
        
        correct = 1;
        clk = 0; 
        reset = 1; 
        loop_was_skipped = 1;
        
        // FILL HERE
        sample_in = 8'h00;
        sample_in_valid = 0;
        next_sample = 0;
        
        #6
        reset = 0;
        
        $display("Time %0t: Reset released, starting test sequence...", $time);
        
        // Test 7 iterations as specified in template
        for( ini=0; ini<7; ini=ini+1 ) begin
            // FILL HERE - Generate test stimulus
            case (ini)
                0: begin
                    sample_in = 8'd10;
                    sample_in_valid = 1;
                    next_sample = 0;
                    $display("  Storing sample 10...");
                end
                1: begin
                    sample_in = 8'd20;
                    sample_in_valid = 1;
                    next_sample = 0;
                    $display("  Storing sample 20...");
                end
                2: begin
                    sample_in = 8'd30;
                    sample_in_valid = 1;
                    next_sample = 0;
                    $display("  Storing sample 30...");
                end
                3: begin
                    sample_in = 8'd40;
                    sample_in_valid = 1;
                    next_sample = 0;
                    $display("  Storing sample 40...");
                end
                4: begin
                    sample_in = 8'd50;
                    sample_in_valid = 1;
                    next_sample = 0;
                    $display("  Storing sample 50 (buffer full)...");
                end
                5: begin
                    sample_in = 8'd60;
                    sample_in_valid = 1;
                    next_sample = 0;
                    $display("  Storing sample 60 (overwrites oldest)...");
                end
                6: begin
                    sample_in = 8'd0;
                    sample_in_valid = 0;
                    next_sample = 1;
                    $display("  Pressing next_sample to navigate...");
                end
            endcase
            
            #10; // Wait for clock edge
            
            // FILL HERE - Verify output
            case (ini)
                0: begin
                    if (sample_out !== 8'd10) begin
                        $display("  ERROR: Expected 10, got %0d", sample_out);
                        correct = 0;
                    end else begin
                        $display("  OK: sample_out = %0d", sample_out);
                    end
                end
                1: begin
                    if (sample_out !== 8'd20) begin
                        $display("  ERROR: Expected 20, got %0d", sample_out);
                        correct = 0;
                    end else begin
                        $display("  OK: sample_out = %0d", sample_out);
                    end
                end
                2: begin
                    if (sample_out !== 8'd30) begin
                        $display("  ERROR: Expected 30, got %0d", sample_out);
                        correct = 0;
                    end else begin
                        $display("  OK: sample_out = %0d", sample_out);
                    end
                end
                3: begin
                    if (sample_out !== 8'd40) begin
                        $display("  ERROR: Expected 40, got %0d", sample_out);
                        correct = 0;
                    end else begin
                        $display("  OK: sample_out = %0d", sample_out);
                    end
                end
                4: begin
                    if (sample_out !== 8'd50) begin
                        $display("  ERROR: Expected 50, got %0d", sample_out);
                        correct = 0;
                    end else begin
                        $display("  OK: sample_out = %0d", sample_out);
                    end
                end
                5: begin
                    // After storing 60, buffer should be: [60,20,30,40,50]
                    // Read pointer should jump to 60
                    if (sample_out !== 8'd60) begin
                        $display("  ERROR: Expected 60, got %0d", sample_out);
                        correct = 0;
                    end else begin
                        $display("  OK: sample_out = %0d (buffer: [60,20,30,40,50])", sample_out);
                    end
                end
                6: begin
                    // After next_sample, should show 20 (next in buffer)
                    if (sample_out !== 8'd20) begin
                        $display("  ERROR: Expected 20 after next_sample, got %0d", sample_out);
                        correct = 0;
                    end else begin
                        $display("  OK: sample_out = %0d (next_sample working)", sample_out);
                    end
                end
            endcase
            
            loop_was_skipped = 0;
        end
        
        #5
        $display("\n=== Test Summary ===");
        if (correct && ~loop_was_skipped)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");
        $finish;
    end
    
    always #5 clk = ~clk;
    
endmodule