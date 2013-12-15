/*
HDL Hello World for Lattice  MachXO Starter Kit
Testbench.v - Testbench
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


// *** Testbench for the counter
module TestBench () ;
// *** Signals
wire [8:1] LED, LEDx;  // LED, low active and inverted (high-active)
reg        CLK = 0;
tri1       BUTTONx;  // Push Button low active, acts as Reset
reg        BUTTONx_driver = 1'bz;  // Driver for BUTTONx

// *** DUT Instance
BlinkCounter DUT_inst (
   .clk(CLK),      // 24MHz Clock (Pin 55 PClkT2_1)
   .btnx(BUTTONx), // low active Button (Pin 36), need to configure internal Pull-Up
                   // Reset when low (pushed)
   .ledx(LEDx)     // 8 output LED, low active
);

// *** Generate 24MHz Clock
always begin: clk_gen
   #(0.5*1e9/24e6) CLK <= ~CLK;  // Invert every half period
end

// *** Invert LED output for convenience
assign LED = ~LEDx;

// *** Do reset at the beginning
initial begin
   // Simulate GSR Pulse on Device Startup
   BUTTONx_driver <= 1'b0;  // Reset
   #1_000;     // wait 1 us
   BUTTONx_driver <= 1'bz;  // Initial: Released
   #5_000_000;     // wait 5 ms
   BUTTONx_driver <= 1'b0;  // Reset
   #5_000_000;     // wait 10 ms
   BUTTONx_driver <= 1'bz;  // Release and GO
   // Okay, try another reset for fun :-)
   #1_111_111;     // wait 1.1111 ms
   BUTTONx_driver <= 1'b0;  // Reset
   #1_000_000;     // wait 1 ms
   BUTTONx_driver <= 1'bz;  // Release and GO
end
assign BUTTONx = BUTTONx_driver;

// *** Run for 1.1s as first trial
initial begin
   #1_100_000_000;    // 1.1s
   // #20_000_000;    // 20 ms
   $finish;
end

// *** Dump waveform values for simulation
initial begin
   $dumpfile("TestBench.dump.lxt");   // Name of dump file
   $dumpvars(0, TestBench);   // Dump all hierarchy
   // $dumpvars;              // Same as above
end


endmodule // TestBench
