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
   input 	    clk,  // 24MHz Clock (Pin 55 PClkT2_1)
   input    	    btnx, // low active Button (Pin 36), need to configure internal Pull-Up
   output reg [8:1] ledx  // 8 output LED, low active
);
   parameter InputClock = 24.0;      // Input Clock in MHz

   // ... 

endmodule // BlinkCounter


// *** Clock Divider
module ClkDivider (/*AUTOARG*/ ) ;
   // ...
endmodule // counter


// *** Counter module
module BinaryCounter (/*AUTOARG*/ ) ;
   // ...
endmodule // counter


// *** Undefine all macros
/*AUTOUNDEF*/
