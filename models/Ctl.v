`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     05/05/2019 08:59:38 PM
// Design Name:     EE3 lab1
// Module Name:     Ctl
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool Versions:   Vivado 2016.4
// Description:     Control module that receives reset,trig and split inputs from the buttons
//                  outputs the init_regs and count_enabled level signals that should govern the 
//                  operation of the Counter module.
// Dependencies:    None
//
// Revision:  	    3.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Ctl(clk, reset, trig, split, init_regs, count_enabled);
   input clk, reset, trig, split;
   output init_regs, count_enabled;
   
   //-------------Internal Constants--------------------------

   localparam SIZE = 3;
   localparam IDLE  = 3'b001, COUNTING = 3'b010, PAUSED = 3'b100 ;
   reg [SIZE-1:0]   state;

   //-------------Transition Function (Delta) ----------------
   always @(posedge clk)
     begin
        if (reset)
          state <= IDLE;
        else
           // FILL HERE STATE TRANSITIONS - DONE
            case (state)
                IDLE: begin
                    if (trig)  // reset=0, if reset=1 so we are in the first if
                        state<=COUNTING;
                    else
                        state<=IDLE;
                end
                 COUNTING: begin
                    if (trig)
                        state<=PAUSED;
                    else
                        state<=COUNTING;
                 end
                 PAUSED: begin
                    if(trig)
                        state<=COUNTING;
                    else if (split)
                        state<=IDLE;
                   else
                        state<=PAUSED;
                   end
              default: state<=IDLE;
       endcase
     end  

   //-------------Output Function (Lambda) ----------------

assign init_regs = (state == IDLE);
assign count_enabled = (state == COUNTING && !trig) || (state == PAUSED && trig);

endmodule

