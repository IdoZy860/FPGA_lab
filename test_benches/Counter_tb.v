`timescale 1 ns / 1 ns
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
`timescale 1 ns / 1 ns

module Counter_tb();

    reg clk, init_regs, count_enabled, correct, loop_was_skipped;
    wire [7:0] time_reading;
    wire [3:0] tens_seconds_wire;
    wire [3:0] ones_seconds_wire;
    integer ts, os, sync;
    
    // Variables for expected values
    integer expected_tens, expected_ones;
    integer count_sample, show_sample;
    
    // Instantiate the UUT (Unit Under Test)
    // Use a small CLK_FREQ for testing (e.g., 10 Hz instead of 100 MHz)
    Counter #(10) uut (
        .clk(clk),
        .init_regs(init_regs),
        .count_enabled(count_enabled),
        .time_reading(time_reading)
    );
    
    assign tens_seconds_wire = time_reading[7:4];
    assign ones_seconds_wire = time_reading[3:0];
    
    initial begin 
        #1;
        sync = 0;
        count_sample = 0;
        show_sample = 0;
        correct = 1;
        loop_was_skipped = 1;
        clk = 1;
        init_regs = 1;
        count_enabled = 0;
        #20;
        init_regs = 0;
        count_enabled = 1;
        
        // With CLK_FREQ=10, 1 second = 10 clock cycles = 100ns (since clock period is 10ns)
        for (ts = 0; ts < 1; ts = ts + 1) begin
            for (os = 0; os < 2; os = os + 1) begin
                // Wait for approximately 1 second (100ns for CLK_FREQ=10)
                #(100 + sync);
                
                // After waiting 1 second, check the counter value
                // The expected time should be (os+1) seconds
                expected_tens = (os + 1) / 10;
                expected_ones = (os + 1) % 10;
                
                // Verify the counter value
                if (tens_seconds_wire !== expected_tens || ones_seconds_wire !== expected_ones) begin
                    correct = 0;
                    $display("Error: At time %0d ns, expected %0d%d, got %0d%d", 
                             $time, expected_tens, expected_ones, 
                             tens_seconds_wire, ones_seconds_wire);
                end else begin
                    $display("OK: At time %0d ns, counter shows %0d%d", 
                             $time, tens_seconds_wire, ones_seconds_wire);
                end
                
                sync = sync | 1;
                loop_was_skipped = 0;
            end
        end
        
        #5;
        if (correct && ~loop_was_skipped)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");
        $finish;
    end
    
    always #5 clk = ~clk;  // 10ns period = 100MHz clock
    
endmodule
