`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     11/10/2018 08:59:38 PM
// Design Name:     EE3 lab1
// Module Name:     CSA
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool Versions:   Vivado 2016.4
// Description:     Variable length binary adder. The parameter N determines
//                  the bit width of the operands. Implemented according to 
//                  Conditional Sum Adder.
// 
// Dependencies:    FA
// 
// Revision:        2.0
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module CSA(a, b, ci, sum, co);

    parameter N=4;
    parameter K = N >> 1; // divide by 2 to two halfs
    
    input [N-1:0] a;
    input [N-1:0] b;
    input ci;
    output [N-1:0] sum;
    output co;
    
    // here we start the generate block as required
    
    generate
        if (N==1) begin: base  // base case simple FA
            FA myFA(
                .a(a[0]), .b(b[0]), .ci(ci), .sum(sum[0]), .co(co));
           end
                                
         else begin: rec_step
	       localparam N_HIGH = N - K;   // calculate the bits of the high size
	       
	       wire co_low; // this is for the co output of the low half to get in the high half
	       wire [N_HIGH-1:0] sum_high_0, sum_high_1;
	       wire co_high_0, co_high_1;
	       
	       // low N , this part do not depend on the carry from the high
	       
	       CSA #(.N(K)) low_half (
	           .a(a[K-1:0]),
	           .b(b[K-1:0]),
	           .ci(ci),
	           .sum(sum[K-1:0]),
	           .co(co_low)
	           );
	           
	       // HIGH N for cin=0
	       
	       CSA #(.N(N_HIGH)) high_half_zerocase (
	           .a(a[N-1:K]),
	           .b(b[N-1:K]),
	           .ci(1'b0), // in this case cin=0
	           .sum(sum_high_0),
	           .co(co_high_0)
	           );
	          
	       // HIGH N for cin=1
	       
	       CSA #(.N(N_HIGH)) high_half_onecase (
	           .a(a[N-1:K]),
	           .b(b[N-1:K]),
	           .ci(1'b1), // in this case cin=1
	           .sum(sum_high_1),
	           .co(co_high_1)
	           ); 
	           
	        // now mux its time to choose the correct carry
	        
	        assign sum[N-1:K] = co_low ? sum_high_1 : sum_high_0;
	        assign co = co_low ? co_high_1 : co_high_0;
           end
           endgenerate
    
endmodule