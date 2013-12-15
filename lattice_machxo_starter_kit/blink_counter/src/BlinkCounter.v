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


// --------------------------------------------------------------------------------
// *** BlinkCounter Top Module
module BlinkCounter (
   input 	    wire clk, // 24MHz Clock (Pin 55 PClkT2_1)
   input 	    wire btnx, // low active Button (Pin 36), need to configure internal Pull-Up
		          // Async Reset when low (pushed)
   output reg [8:1] ledx  // 8 output LED, low active
);
   parameter InputClock = 24.0;      // Input Clock in MHz
   localparam ClkDivider_DivideBy = 5;     // Divide CLK by 2^5=32
   localparam CounterMaxValue =      // Max counter value, 0.5s for one run
            0.5*(InputClock*10**6)/(1<<ClkDivider_DivideBy);

   // *** Functions
   // Determine register size in bits to store the unsigned value limit within
   function automatic integer regsize (input integer limit);
	   integer l;
   begin
      regsize = 1;   // Initial value
	   l = limit;    // Here too
      while (l > 1) begin
	    regsize = regsize+1;
	    l = l>>1;
      end
      // Done
   end
   endfunction

   // *** Signals
   wire     clkdiv;   // Divided Clock by 2^ClkDivider_DivideBy
   wire	    clk_rstx; // Synchronous low active Reset in clk domain
   wire     rstx;     // Synchronous low active Reset in clkdiv domain, delayed
   wire     led_tick; // 1 clkdiv long tick to increment the LED counter

   // *** Reset Handling
   ResetGeneration ResetGeneration_inst (
			.clk(clk),
		        .clkdiv(clkdiv),
			.async_rstx_in(btnx), // Reset in
		        .clk_rstx(clk_rstx),   // RST in clk domain
		        .clkdiv_rstx(rstx)     // RST in clkdiv domain, filtered
		   );

   // *** Clock Divider
   defparam ClkDivider_inst.DivideBy = ClkDivider_DivideBy;     // Divide by 2^X
   ClkDivider ClkDivider_inst (
		  .clkin(clk),
		  .clkout(clkdiv),
		  .rstx(clk_rstx)   // RST in clk domain
	      );


   // *** Counter to generate update tick every 0.5s
   defparam counter_inst.MinValue = 0;    // Min counter value
   defparam counter_inst.MaxValue = CounterMaxValue; // Max counter value, 0.5s for one run

`ifdef __ICARUS__
   // Icarus Verilog cannot handle constant functions - so fake it
   // TAKE CARE ABOUT MISMATCH!!!
   defparam counter_inst.Size     = 19;  // Bit size of counter
`else
   // Use constant function for Synthesis - TAKE CARE ABOUT MISMATCH!!!
   defparam counter_inst.Size     = regsize(CounterMaxValue);    // Bit size of counter
`endif
   BinaryCounter counter_inst(
	.clk(clkdiv), // CLOCK
        .rstx(rstx), // ASync Low Active Reset (but can be synchronized :-)
        .counter(), // Counter value
        .ovr(led_tick) // Overflow flag, set for one clk tick when the counter overflows
   );


   // *** Update LED
   always @ (posedge clkdiv or negedge rstx) begin: led_update
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


// --------------------------------------------------------------------------------
// *** Reset generation
// Special care must be taken about reset filtering, because Reset also stops
// the Clock divider. To provide also a sync Reset in clkdiv domain it must be
// delayed and re-created.
module ResetGeneration (
   input      wire clk,      // Original clk
   input      wire clkdiv,   // Derived and divided clk
   input 	  wire async_rstx_in, // Asynchronous reset
   output 	  reg  clk_rstx, // RST in clk domain
   output 	  reg  clkdiv_rstx // RST in clkdiv domain, filtered
   );

   // *** Signals
   reg 	[3:1] rstff;    // Reset synchronizer FFs
   reg 	[3:1] rstdivff; // Reset synchronizer FFs for clkdiv

   // *** Sync Reset in clk domain
   always @(posedge clk) begin: reset_clk_sync
      rstff[1] <= async_rstx_in;
      rstff[2] <= rstff[1];
      rstff[3] <= rstff[2];
      clk_rstx <= rstff[1] || rstff[2] || rstff[3];
   end


   // *** Shift clk_rstx into clkdiv domain
   always @(posedge clk) begin: reset_clkdiv_sync
      if (clk_rstx == 0)
	clkdiv_rstx <= 0;
      else if (clkdiv) // Acts as clk enable
	clkdiv_rstx <= clk_rstx;
   end

endmodule // ResetGeneration


// --------------------------------------------------------------------------------
// *** Clock Divider
module ClkDivider (
   input  wire clkin,      // Input CLOCK
   output wire clkout,     // Divided Clock
   input  wire rstx        // ASyncronous Low Active Reset
   );
   parameter DivideBy = 1;   // Divide Clock by 2^DivideBy

   // *** Variables
   genvar gi;       // Generate Loop Variable
   reg [DivideBy:1] divclk_d;   // Output (Data) of the divider stages
   wire [DivideBy:0] divclk_clk_ena;   // Clock Enable Input of the divider stages
                                       // last one unused

   // *** Clock enable first stage
   assign divclk_clk_ena[0] = clkin;

   // *** Divider stages on global clock
   // Maybe a counter-divider would perform better ...
   generate
      for (gi=1; gi<=DivideBy; gi=gi+1)
	begin: divider
	   assign divclk_clk_ena[gi] = divclk_d[gi]; // Clock Enable Input
	   always @ (posedge clkin or negedge rstx) begin
	      if (rstx == 0) begin
		 // Reset the divider
		 divclk_d[gi] <= 0;
	      end
	      else begin
		 // Divide by one, use previous clocks as enable
		 if (&divclk_clk_ena[gi-1:0])
		   divclk_d[gi] <= ~divclk_d[gi];
	      end
	   end
	end    // divider
   endgenerate

   // *** Clock output
   assign clkout = divclk_d[DivideBy];

endmodule // counter



// --------------------------------------------------------------------------------
// *** Counter module
module BinaryCounter ( clk, rstx, counter, ovr );
   parameter integer MinValue = 0;    // Min counter value
   parameter integer MaxValue = 32;   // Max counter value
   parameter integer Size     = 5;    // Bit size of counter

   input  wire clk; // CLOCK
   input  wire rstx; // Sync Low Active Reset
   output reg [Size-1:0] counter; // Counter value
   output reg ovr; // Overflow flag, set for one clk tick when the counter overflows

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
   always @ (posedge clk or negedge rstx) begin
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
