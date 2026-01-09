`timescale 1ns/10ps

module Debouncer_tb();

    // Testbench parameters
    parameter CLK_PERIOD = 20;  // 50 MHz clock
    
    // Signals
    reg clk;
    reg input_unstable;
    wire output_stable;
    
    // Instantiate the Debouncer module
    Debouncer uut (
        .clk(clk),
        .input_unstable(input_unstable),
        .output_stable(output_stable)
    );
    
    // Clock generation
    always begin
        clk = 1'b0;
        #(CLK_PERIOD/2);
        clk = 1'b1;
        #(CLK_PERIOD/2);
    end
    
    // Simple test sequence
    initial begin
        // Initialize
        input_unstable = 1'b0;
        
        // Wait a bit
        #100;
        
        // Test 1: Short bounce (should NOT trigger output)
        $display("Test 1: Short bounce (should NOT trigger)");
        input_unstable = 1'b1;
        #100;  // 5 clock cycles at 20ns period
        input_unstable = 1'b0;
        #500;
        
        // Test 2: Long enough press (SHOULD trigger output)
        $display("Test 2: Long press (SHOULD trigger)");
        input_unstable = 1'b1;
        #2000;  // 100 clock cycles - enough to fill 7-bit counter
        input_unstable = 1'b0;
        #500;
        
        // Test 3: Another long press
        $display("Test 3: Another long press");
        input_unstable = 1'b1;
        #2000;
        input_unstable = 1'b0;
        #500;
        
        $display("Test completed!");
        $finish;
    end
    
    // Monitor signals
    initial begin
        $monitor("Time = %0t ns, Clk=%b, In=%b, Out=%b", 
                 $time, clk, input_unstable, output_stable);
    end
    
    // Save waveform file
    initial begin
        $dumpfile("debouncer.vcd");
        $dumpvars(0, Debouncer_tb);
    end

endmodule