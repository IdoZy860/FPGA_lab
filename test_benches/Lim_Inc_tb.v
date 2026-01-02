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
module Lim_Inc_tb();

    // For L=9, N = ceil(log2(9)) = 4 bits
    parameter L = 9;
    parameter N = $clog2(L);  // N = 4
    
    reg [N-1:0] a; 
    reg ci, correct, loop_was_skipped;
    wire [N-1:0] sum;
    wire co;
    
    integer ai, cii;
    integer expected_sum, expected_co;
    
    // Instantiate the UUT (Unit Under Test)
    Lim_Inc #(.L(L)) uut (
        .a(a),
        .ci(ci),
        .sum(sum),
        .co(co)
    );
    
    initial begin
        $dumpfile("Lim_Inc_tb.vcd");
        $dumpvars(0, Lim_Inc_tb);
        correct = 1;
        loop_was_skipped = 1;
        #1
        
        $display("Testing Lim_Inc with L = %0d", L);
        $display("N = ceil(log2(%0d)) = %0d bits", L, N);
        $display("Testing a from 0 to %0d, ci from 0 to 1", (1 << N) - 1);
        
        // Test all combinations of a (0-15) and ci (0-1)
        for (ai = 0; ai < (1 << N); ai = ai + 1) begin
            for (cii = 0; cii <= 1; cii = cii + 1) begin
                a = ai;
                ci = cii;
                loop_was_skipped = 0;
                
                #10; // Wait for propagation
                
                // Calculate expected result based on L=9
                // Note: a + ci >= L => co=1, sum=0
                //       a + ci < L  => co=0, sum=a+ci
                
                expected_sum = ai + cii;
                
                if (expected_sum >= L) begin
                    // Should saturate: sum=0, co=1
                    if (sum !== 0 || co !== 1) begin
                        $display("Error: a=%0d, ci=%0d -> sum=%0d, co=%b, expected sum=0, co=1", 
                                 ai, cii, sum, co);
                        correct = 0;
                    end
                end
                else begin
                    // Normal increment: sum=a+ci, co=0
                    if (sum !== expected_sum || co !== 0) begin
                        $display("Error: a=%0d, ci=%0d -> sum=%0d, co=%b, expected sum=%0d, co=0", 
                                 ai, cii, sum, co, expected_sum);
                        correct = 0;
                    end
                end
            end
        end
        
        #5;
        if (correct && ~loop_was_skipped)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");
        $finish;
    end
endmodule