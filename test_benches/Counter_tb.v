`timescale 1ns/1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     00:00:00  AM 05/05/2019 
// Design Name:     EE3 lab1
// Module Name:     Counter_tb
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     test bench for Counter module
// Dependencies:    Counter
//
// Revision:        3.0
// Revision:        3.1 - changed  9999999 to 99999999 for a proper, 1sec delay, 
//                        in the inner test loop.
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Counter_tb();

    reg clk, init_regs, count_enabled, correct, loop_was_skipped;
    wire [7:0] time_reading;
    wire [3:0] tens_seconds_wire;
    wire [3:0] ones_seconds_wire;
    
    integer expected_tens, expected_ones;
    integer seconds_count;
    
    // Instantiate the UUT (Unit Under Test)
    // Using CLK_FREQ = 10 for faster simulation (1Hz = 10 clock cycles)
    Counter #(.CLK_FREQ(10)) uut (
        .clk(clk),
        .init_regs(init_regs),
        .count_enabled(count_enabled),
        .time_reading(time_reading)
    );
    
    assign tens_seconds_wire = time_reading[7:4];
    assign ones_seconds_wire = time_reading[3:0];
    
    initial begin 
        $dumpfile("Counter_tb.vcd");
        $dumpvars(0, Counter_tb);
        correct = 1;
        loop_was_skipped = 1;
        
        // Initialize
        clk = 0;
        init_regs = 1;
        count_enabled = 0;
        
        // Check initial value (should be 00)
        #15;
        if (tens_seconds_wire !== 0 || ones_seconds_wire !== 0) begin
            correct = 0;
            $display("ERROR: Initial value should be 00, got %0d%0d", 
                     tens_seconds_wire, ones_seconds_wire);
        end
        
        // Reset pulse and enable counting
        #5;
        init_regs = 0;
        count_enabled = 1;
        
        // Test for 120 seconds (2 minutes) to verify rollover
        // Start with seconds_count = 1 because after 1 second we expect 01
        for (seconds_count = 1; seconds_count <= 120; seconds_count = seconds_count + 1) begin
            // Wait for 1 second (10 clock cycles = 100ns)
            #100;
            
            loop_was_skipped = 0;
            
            // Calculate expected values (seconds 0-59, then rollover)
            // seconds_count represents the number of seconds passed since enable
            expected_tens = (seconds_count % 60) / 10;
            expected_ones = (seconds_count % 60) % 10;
            
            // Display current counter value
            $display("Time: %0d ns, Counter: %0d%0d, Expected: %0d%0d", 
                     $time, tens_seconds_wire, ones_seconds_wire,
                     expected_tens, expected_ones);
            
            // Verify the counter value
            if (tens_seconds_wire !== expected_tens || ones_seconds_wire !== expected_ones) begin
                correct = 0;
                $display("ERROR: At time %0d ns, expected %0d%0d, got %0d%0d", 
                         $time, expected_tens, expected_ones, 
                         tens_seconds_wire, ones_seconds_wire);
            end
        end
        
        // Test complete
        #5;
        if (correct && ~loop_was_skipped)
            $display("\nTest Passed - %m");
        else
            $display("\nTest Failed - %m");
        $finish;
    end
    
    // Generate 100MHz clock (10ns period)
    always #5 clk = ~clk;
    
endmodule