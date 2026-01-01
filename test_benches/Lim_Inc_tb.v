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

    reg [3:0] a; 
    reg ci, correct, loop_was_skipped;
    wire [3:0] sum;
    wire co;
    
    integer ai,cii;
    
    // Instantiate the UUT (Unit Under Test)
    Lim_Inc #(.L(11)) uut (
        .a(a),
        .ci(ci),
        .sum(sum),
        .co(co)
    );
    
    initial begin
        correct = 1;
        loop_was_skipped = 1;
        #1
        
        // Test all combinations of a (0-15) and ci (0-1)
        for (ai = 0; ai <= 15; ai = ai + 1) begin
            for (cii = 0; cii <= 1; cii = cii + 1) begin
                a = ai;
                ci = cii;
                loop_was_skipped = 0;
                
                #10; // Wait for propagation
                
                // Calculate expected result (a + ci > 11)
                if (a + ci > 11) begin
                    // Should saturate: sum=0, co=1
                    if (sum !== 4'b0 || co !== 1'b1) begin
                        $display("Error: a=%0d, ci=%0d -> sum=%b, co=%b, expected sum=0000, co=1", a, ci, sum, co);
                        correct = 0;
                    end
                end
                else begin
                    // Normal increment: sum=a+ci, co=0
                    if (sum !== (a + ci) || co !== 1'b0) begin
                        $display("Error: a=%0d, ci=%0d -> sum=%b (decimal %0d), co=%b, expected sum=%0d, co=0", 
                                 a, ci, sum, sum, co, a + ci);
                        correct = 0;
                    end
                end
            end
        end
        
        #5
        if (correct && ~loop_was_skipped)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");
        $finish;
    end
endmodule