`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     11/11/2018 08:59:38 PM
// Design Name:     EE3 lab1
// Module Name:     CSA_tb
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool Versions:   Vivado 2016.4
// Description:     CSA(3) test bench - Comprehensive testing
// 
// Dependencies:    CSA, FA
// 
// Revision:        2.0
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module CSA_tb();

    // Test parameters
    parameter WIDTH = 3;            // Test 3-bit adder
    parameter TOTAL_TESTS = (1 << WIDTH) * (1 << WIDTH) * 2; // 2^3 * 2^3 * 2 = 512
    
    // Test signals
    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    reg ci;
    wire [WIDTH-1:0] sum;
    wire co;
    
    // Test control
    reg test_passed;
    reg loop_executed;
    integer test_count, error_count;
    integer ai, bi, cii;
    integer expected_sum, expected_co;
    
    // Instantiate Unit Under Test (3-bit Conditional Sum Adder)
    CSA #(.N(WIDTH)) uut (
        .a(a),
        .b(b),
        .ci(ci),
        .sum(sum),
        .co(co)
    );
    
    // Initialize and run tests
    initial begin
        // Initialize test variables
        test_passed = 1;
        loop_executed = 0;
        test_count = 0;
        error_count = 0;
        
        // Setup waveform dumping (optional)
        $dumpfile("csa_simulation.vcd");
        $dumpvars(0, CSA_tb);
        
        // Test header
        $display("\n===========================================");
        $display("Starting CSA(%0d) Test Bench", WIDTH);
        $display("Total test cases: %0d", TOTAL_TESTS);
        $display("===========================================");
        $display("Time\t a\t b\t ci\t sum\t co\t Status");
        $display("---------------------------------------------------");
        
        // Test all possible input combinations
        for (ai = 0; ai < (1 << WIDTH); ai = ai + 1) begin
            for (bi = 0; bi < (1 << WIDTH); bi = bi + 1) begin
                for (cii = 0; cii <= 1; cii = cii + 1) begin
                    // Apply test stimulus
                    a = ai;
                    b = bi;
                    ci = cii;
                    test_count = test_count + 1;
                    
                    // Wait for signals to propagate through CSA tree
                    #20;
                    
                    // Calculate expected result
                    expected_sum = ai + bi + cii;
                    expected_co = (expected_sum >> WIDTH) & 1;
                    expected_sum = expected_sum & ((1 << WIDTH) - 1);
                    
                    // Check result
                    if (sum === expected_sum && co === expected_co) begin
                        $display("%0t\t %d\t %d\t %d\t %d\t %d\t OK", 
                                 $time, ai, bi, cii, sum, co);
                    end
                    else begin
                        $display("%0t\t %d\t %d\t %d\t %d\t %d\t ERROR", 
                                 $time, ai, bi, cii, sum, co);
                        $display("\t\t Expected: sum=%d (%b), co=%d", 
                                 expected_sum, expected_sum, expected_co);
                        test_passed = 0;
                        error_count = error_count + 1;
                    end
                    
                    loop_executed = 1;
                end
            end
        end
        
        // Test summary
        #10;
        $display("\n===========================================");
        $display("TEST COMPLETE");
        $display("-------------------------------------------");
        $display("Total tests executed:   %0d", test_count);
        $display("Tests passed:           %0d", test_count - error_count);
        $display("Tests failed:           %0d", error_count);
        
        if (test_passed && loop_executed) begin
            $display("RESULT: ALL TESTS PASSED ✓");
        end
        else begin
            $display("RESULT: TEST FAILED ✗");
        end
        $display("===========================================\n");
        
        // End simulation
        $finish;
    end
    
    // Optional: Monitor for debugging
    initial begin
        // Uncomment for detailed monitoring
        // $monitor("Time %0t: a=%b b=%b ci=%b sum=%b co=%b", 
        //          $time, a, b, ci, sum, co);
    end
    
endmodule