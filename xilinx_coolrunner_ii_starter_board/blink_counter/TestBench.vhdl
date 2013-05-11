--     TestBench.vhdl - Testbench for HDL Hello World for Coolrunner II Starter Board
--     Copyright (C) 2013, Robert Lange <robert.lange@s1999.tu-chemnitz.de>
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
	signal ledout:   std_ulogic;               -- The blinking led
	signal led_open: std_ulogic_vector(3 downto 1); -- Not used LED outputs

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
      led_n(3) => led_open(3),  -- single indices because std_logic<->std_ulogic conversion is possible
		led_n(2) => led_open(2),  -- but not for *_vector
		led_n(1) => led_open(1),
		led_n(0) => ledout,        -- this one we really use
      -- Not used ports: Optimized away in POST, therefore removed here
      -- RTL relies on configuration port mapping
      --  btn1       => 'X',
      -- sw0        => 'X',
      -- sw1        => 'X',
      disp_ena_n => open,
      disp_seg_n => open);

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

