/*
HDL Hello World for Lattice  MachXO Starter Kit
BlinkCounter.v - Toplevel and Sub-Modules
Copyright (C) 2013, Robert Lange <sd2k9@sethdepot.org>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

Example: Blink the LED in one second takt
*/

// *** Default settings
`include "defaults.vi"


// *** BlinkCounter Top Module
module BlinkCounter (
   input 	    clk, // 24MHz Clock (Pin 55 PClkT2_1)
   input 	    btnx, // low active Button (Pin 36), need to configure internal Pull-Up
		          // Async Reset when low (pushed)
   output reg [8:1] ledx  // 8 output LED, low active
);
   parameter InputClock = 24.0;      // Input Clock in MHz
   localparam ClkDivider_DivideBy = 5;     // Divide CLK by 2^5=32

   // *** Functions
   // Determine register size in bits to store the unsigned value limit within
   function automatic integer regsize (input integer limit);
      regsize = 1;   // Initial value
      while (limit > 1) begin
	 regsize++;
	 limit = limit>>1;
      end
      return regsize;   // Done
   endfunction

   // *** Signals
   wire 	    clkdiv;   // Divided Clock by 2^ClkDivider_DivideBy
   reg 		    rstff1, rstff2;   // Reset synchronizer FFs
   reg 		    rstx;     // Synchronous low active Reset in clkdiv domain
   wire 	    led_tick; // 1 clkdiv long tick to increment the LED counter

   // *** Clock Divider
   defparam ClkDivider_inst.DivideBy = ClkDivider_DivideBy;     // Divide by 2^X
   ClkDivider ClkDivider_inst(
		  .clkin(clk),
		  .clkout(clkdiv),
		  .async_rstx(btnx)
	      );


   // *** Sync Reset in clkdiv domain
   always @(posedge clkdiv) begin: reset_sync
      rstff1 <= btnx;
      rstff2 <= rstff1;
      rstx <= rstff1 || rstff2;
   end

   // *** Counter to generate update tick every 0.5s
   defparam counter_inst.MinValue = 0;    // Min counter value
   defparam counter_inst.MaxValue =      // Max counter value, 0.5s for one run
	   0.5*(InputClock*10**6)/(1<<ClkDivider_DivideBy)
   defparam counter_inst.Size     = regsize(counter_inst.MaxValue);    // Bit size of counter
   BinaryCounter counter_inst(
	.clk(clkdiv), // CLOCK
        .rstx(rstx), // Sync Low Active Reset
        .counter(), // Counter value
        .ovr(led_tick) // Overflow flag, set for one clk tick when the counter overflows
   );


   // *** Update LED
   always @ (posedge clkdiv) begin; led_update
      if (rstx == 0) begin
	 // Reset - All off
	 ledx <= 8'hFF;
       end
       else begin
	// Decrement by one for each tick (because inverted)
	if (led_tick)
	  ledx <= ledx-1;
      end
   end

endmodule // BlinkCounter


// *** Clock Divider
module ClkDivider (
   input  clkin,      // Input CLOCK
   output clkout,     // Divided Clock
   input  async_rstx  // ASync Low Active Reset
   );
   parameter DivideBy = 1;   // Divide Clock by 2^DivideBy

   // *** Variables
   genvar gi;       // Generate Loop Variable
   reg [DivideBy:0] divclk;   // Clock of the divider stages

   // *** Clock input
   assign divclk[0] = clkin;

   // *** Divider stages
   generate
      for (gi=1; gi<=DivideBy; gi=gi+1)
	begin: divider
	   always @ (posedge divclk[gi-1] or negedge async_rstx) begin
	      if (async_rstx == 0) begin
		 // Reset the divider
		 divclk[gi] <= 0;
	      end
	      else begin
		 // Divide by one
		 divclk[gi] <= not divclk[gi1];
	      end
	   end
	end    // divider
   endgenerate

   // *** Clock output
   assign clkout = divclk[DivideBy];

endmodule // counter


// *** Counter module
module BinaryCounter (
   input  clk, // CLOCK
   input  rstx, // Sync Low Active Reset
   output reg [Size-1:0] counter, // Counter value
   output reg ovr // Overflow flag, set for one clk tick when the counter overflows
   );
   parameter integer MinValue = 0;    // Min counter value
   parameter integer MaxValue = 32;   // Max counter value
   parameter integer Size     = 5;    // Bit size of counter

   // *** Do some assertion checks
   initial begin
      // Size is big enough for max value
      if (MaxValue > ((1<<Size)-1) ) begin
	 $display("Error! Parameter Size is too small to contain the MaxValue counter value! Gimme more bits!");
	 $stop;
      end
      // max > min
      if (MaxValue <= MinValue) begin
	 $display("Error! Parameter MaxValue must be larger than MinValue! Check your code, man!");
	 $stop;
      end
   end

   // *** This is the counter
   always @ (posedge clk) begin
      if (rstx == 0) begin
	 // Init conditions
	 ovr <= 0;
	 counter <= MinValue;
      end else begin
	 ovr <= 0;    // Overflow default unset
	 if (counter == MaxValue) begin
	    // Wrap around and set overflow
	    ovr <= 1;
	    counter <= MinValue;
	 end else
	   // Increment
	   counter <= counter + 1;
      end
   end
endmodule // counter


// *** Undefine all macros
/*AUTOUNDEF*/
