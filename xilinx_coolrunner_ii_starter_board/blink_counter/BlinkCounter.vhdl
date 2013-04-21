--     BlinkCounter.vhdl - HDL Hello World for Xilinx Coolrunner II Starter Board
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

-- Example: Blink the LED in one second takt


-- *** Toplevel
library ieee;
use ieee.std_logic_1164.all;

entity BlinkCounter is
	generic
	(
		COUNT_STEPS : natural := 8*1000*1000  -- 8 MHz
	);

	port
	(
		clk	     : in std_ulogic;  -- Clock Signals
		reset_n	  : in std_ulogic;  -- low active reset
		led        : out std_ulogic_vector(3 downto 0);  -- 4 User LEDs
                                                                -- (high active)
		-- Other ports of Reference Board - not used
		btn1       : in std_ulogic;  -- 2nd Push Button (low active)
                sw0, sw1   : in std_ulogic;  -- slide buttons
                -- 7 Segment Display - all low active; see Reference Manual
		disp_ena_n : out std_ulogic_vector(1 to 4);  -- 4 Digit Enabler
		disp_seg_n : out std_ulogic_vector(1 to 8)  -- 7.1 Segments
	);

end entity BlinkCounter;



architecture rtl of BlinkCounter is

   -- Signals
	signal cout: integer range 0 to COUNT_STEPS;
	signal reset: std_ulogic;     -- high active reset

	-- Component of the counter
	component binary_counter is
	generic
	(
		MIN_COUNT : natural := 0;
		MAX_COUNT : natural := 255
	);
	port
	(
		clk		  : in std_ulogic;
		reset	     : in std_ulogic;   -- high active reset
		enable	  : in std_ulogic;
		q		     : out integer range MIN_COUNT to MAX_COUNT
	);

   end component;

begin

   -- Instantiate Counter
	cnt : binary_counter
	generic map
	(
		MAX_COUNT => COUNT_STEPS
	)
	port map 
	(
		clk => clk,
		reset => reset,
		enable => '1',
		q => cout
	);

	-- Form LED Output Signal
	process (clk)
		variable   outval		   : std_ulogic;
	begin
		if (rising_edge(clk)) then

			if reset_n = '0' then
				-- Reset the output
				outval := '1';
			elsif  cout = 1 then
			   -- We're inverting at this stage
            outval := not outval;
			else -- Keep value
			   outval := outval;
			end if;
		end if;
		-- Output the variable
		led(0) <= outval;
	end process;

	-- Other LED is always off
	led(3 downto 1) <= "000";

   -- 7 Segment output also disabled
   disp_ena_n <= (others => '1');
   disp_seg_n <= (others => '1');
	
	-- Invert Reset for counter block
	reset <= not reset_n;

end architecture rtl;


-- *** Counter
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity binary_counter is

	generic
	(
		MIN_COUNT : natural := 0;
		MAX_COUNT : natural := 255
	);

	port
	(
		clk		  : in std_ulogic;
		reset	     : in std_ulogic;  -- low active reset
		enable	  : in std_ulogic;
		q		     : out integer range MIN_COUNT to MAX_COUNT
	);
end entity binary_counter;

architecture rtl of binary_counter is
begin

	process (clk)
		variable   cnt		   : integer range MIN_COUNT to MAX_COUNT;
	begin
		if (rising_edge(clk)) then

			if reset = '1' then
				-- Reset the counter to 0
				cnt := MIN_COUNT;

			elsif enable = '1' then
				-- Increment the counter if counting is enabled, wrap around when running over
				if cnt = MAX_COUNT then
					cnt := MIN_COUNT;
				 else
					cnt := cnt + 1;
				end if;

			end if;
		end if;

		-- Output the current count
		q <= cnt;
	end process;

end architecture rtl;
