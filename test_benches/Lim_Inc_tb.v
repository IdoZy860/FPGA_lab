`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     05/05/2019 00:16 AM
// Design Name:     EE3 lab1
// Module Name:     Lim_Inc_tb
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool Versions:   Vivado 2016.4
// Description:     Limited incrementor test bench
// 
// Dependencies:    Lim_Inc
// 
// Revision:        3.0
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/10ps

module Lim_Inc_tb();

    // Testbench signals
    reg [3:0] a;
    reg ci;
    reg correct;
    reg loop_was_skipped;
    wire [3:0] sum;
    wire co;
    
    integer ai, cii;
    
    // Instantiate the Unit Under Test (UUT)
    Lim_Inc #(7) uut (
        .a(a),
        .ci(ci),
        .sum(sum),
        .co(co)
    );
    
    // Initialize signals
    initial begin
        correct = 1;
        loop_was_skipped = 1;
        a = 0;
        ci = 0;
        
        #10;  // Initial delay
        
        // Test all combinations of a=0..15 and ci=0..1
        for (ai = 0; ai < 16; ai = ai + 1) begin
            for (cii = 0; cii <= 1; cii = cii + 1) begin
                a = ai;
                ci = cii;
                loop_was_skipped = 0;
                
                #10;  // Wait for output to stabilize
                
                // Check if output is correct
                if (a + ci > 7) begin
                    // Should saturate to 0 with co=1
                    if (sum !== 0 || co !== 1) begin
                        correct = 0;
                        $display("FAIL: a=%0d, ci=%0d: expected sum=0, co=1, got sum=%0d, co=%0d", 
                                 a, ci, sum, co);
                    end
                end else begin
                    // Normal operation
                    if (sum !== (a + ci) || co !== 0) begin
                        correct = 0;
                        $display("FAIL: a=%0d, ci=%0d: expected sum=%0d, co=0, got sum=%0d, co=%0d", 
                                 a, ci, a + ci, sum, co);
                    end
                end
            end
        end
        
        #10;
        
        // Display test result
        if (correct && ~loop_was_skipped) begin
            $display("Test Passed - %m");
        end else begin
            $display("Test Failed - %m");
        end
        
        $finish;
    end
    
endmodule