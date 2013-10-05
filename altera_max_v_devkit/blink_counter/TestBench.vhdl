--     TestBench.vhdl - Testbench for HDL Hello World for Max V Development Kit
--     Copyright (C) 2013, Robert Lange <sd2k9@sethdepot.org>
--
--     This program is free software: you can redistribute it and/or modify
--     it under the terms of the GNU General Public License as published by
--     the Free Software Foundation, either version 3 of the License, or
--     (at your option) any later version.
--
--     This program is distributed in the hope that it will be useful,
--     but WITHOUT ANY WARRANTY; without even the implied warranty of
--     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--     GNU General Public License for more details.
--
--     You should have received a copy of the GNU General Public License
--     along with this program.  If not, see <http://www.gnu.org/licenses/>.

-- *** Testbench for BlinkCounter Example

-- *** Includes
library ieee;
use ieee.std_logic_1164.all;


entity Testbench is
	generic
	(
		CLOCK_RATE : time := 100 ns  -- 10 MHz
	);

end entity Testbench;


architecture beh of Testbench is

   -- Signals
	signal clock: std_logic := '0';
	signal rst_n: std_logic := '1';
	signal ledout, led_1: std_logic;

	-- Component of the DUT
	component BlinkCounter is
   -- Generic Map only for RTL simulation  --> HOW TO USE IN BOTH RTL AND GATE?
  	--generic
	--(
	--	COUNT_STEPS : natural := 10*1000*1000  -- 10 MHz
	--);
	port
	(
		clk		     : in std_logic;
		reset_n	     : in std_logic;
		led0, led1	  : out std_logic  -- Clock Signals
	);
   end component BlinkCounter;

begin

	-- Instantiate DUT
	dut: BlinkCounter
		port map
	(
		clk	=> clock,
		reset_n	=> rst_n,
		led0	=> ledout,
		led1	=> led_1
	);

   -- Clock Process
	process is
	begin
	   wait for CLOCK_RATE/2;
		clock <= not clock;
	end process;

	-- RST Process
	process is
	begin
	   rst_n <= '0';  -- Do reset
		wait for 1 ms;
		rst_n <= '1';  -- Release reset
		wait;        -- Done forever
	end process;

end architecture beh;

