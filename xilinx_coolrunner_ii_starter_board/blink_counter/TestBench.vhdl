--     TestBench.vhdl - Testbench for HDL Hello World for Coolrunner II Starter Board
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
		CLOCK_RATE : time := 125 ns  -- 8 MHz
	);

end entity Testbench;


architecture beh of Testbench is

   -- Signals
	signal clock:    std_ulogic := '0';
	signal rst_n:    std_ulogic;
	signal ledout_n:   std_logic_vector(3 downto 0);            -- The blinking leds
        -- The blinking leds, inverted (1: on, 0: off)
	signal ledout_show:   std_ulogic_vector(3 downto 0);

	-- Component of the DUT
        component BlinkCounter
          -- Use default
          -- generic (
          --   COUNT_STEPS : natural);
          port (
            clk        : in  std_logic;
            reset_n    : in  std_logic;
            led_n      : out std_logic_vector(3 downto 0);
            -- Optimized away in POST, therefore removed here
            -- RTL relies on configuration port mapping
            -- btn1       : in  std_ulogic;
            -- sw0, sw1   : in  std_ulogic;
            disp_ena_n : out std_logic_vector(1 to 4);
            disp_seg_n : out std_logic_vector(1 to 8));
        end component BlinkCounter;

begin

	-- Instantiate DUT
  dut: BlinkCounter
      -- Use default
      -- generic map (
      -- COUNT_STEPS => COUNT_STEPS)
    port map (
      clk        => clock,
      reset_n    => rst_n,
      led_n => ledout_n,
      -- Not used ports: Optimized away in POST, therefore removed here
      -- RTL relies on configuration port mapping
      --  btn1       => 'X',
      -- sw0        => 'X',
      -- sw1        => 'X',
      disp_ena_n => open,
      disp_seg_n => open);
  -- inverted for display
  ledout_show <= To_StdULogicVector(not ledout_n);

   -- Clock Process
	process is
	begin
	   wait for CLOCK_RATE/2;
		clock <= not clock;
	end process;

	-- RST Process
	process is
	begin
  	   wait for 150 ns;
	   rst_n <= '0';  -- Do reset
	   wait for 1 ms;
	   rst_n <= '1';  -- Release reset
	   wait;        -- Done forever
	end process;

end architecture beh;

