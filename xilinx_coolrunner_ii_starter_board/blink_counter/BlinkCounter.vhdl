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
use ieee.numeric_std.all;      -- +
library UNISIM;
--use UNISIM.vcomponents.CLK_DIV16;
--use UNISIM.vcomponents.all;

entity BlinkCounter is
	generic
	(
          COUNT_STEPS : natural := 8*1000*1000  -- 8 MHz
          -- Devel Speed Up: 1024
          -- COUNT_STEPS : natural := 1024
	);

	port
	(
		clk	     : in std_logic;  -- Clock Signals
		reset_n	  : in std_logic;  -- low active reset
		led_n      : out std_logic_vector(3 downto 0);  -- 4 User LEDs (low active)
		-- Other ports of Reference Board - not used
		btn1       : in std_logic;  -- 2nd Push Button (low active)
                sw0, sw1   : in std_logic;  -- slide buttons
                -- 7 Segment Display - all low active; see Reference Manual
		disp_ena_n : out std_logic_vector(1 to 4);  -- 4 Digit Enabler
		disp_seg_n : out std_logic_vector(1 to 8)  -- 7.1 Segments
	);

end entity BlinkCounter;



architecture rtl of BlinkCounter is

   -- Signals
	signal cout: integer range 0 to COUNT_STEPS/16;     -- divided by 16 because we use clock divider
	signal reset: std_ulogic;         -- high active reset
	signal clk_div_by16: std_ulogic;  -- CLK divided by 16 with CPLD CLKDIV block
        signal ladder : unsigned(3 downto 0) := "0000";  -- LEDs as binary ladder
        signal one_step_up : std_ulogic := '0';  -- one clock impulse high for counting up
  
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
   end component binary_counter;


begin

  -- Provide divided CLK (Xilinx CPLD Macro)
  -- CLK_DIV16: Simple clock Divide by 16
  --             CoolRunner-II
  -- Xilinx HDL Language Template, version 14.5
  -- clk_div16_inst : entity UNISIM.clk_div16
  clk_div16_inst : component UNISIM.vcomponents.CLK_DIV16
    port map (
      CLKDV => clk_div_by16,    -- Divided clock output
      CLKIN => clk              -- Clock input
   );
  --clk_div_by16 <= clk;

  -- Instantiate Counter
  cnt : component binary_counter
    generic map
    (
      MAX_COUNT => COUNT_STEPS/16     -- divided by 16 because we use clock divider
      )
    port map
    (
      clk => clk_div_by16,   -- use divided clock
      reset => reset,
      enable => '1',
      q => cout
      );

  -- Form LED Output Signal
  process (clk_div_by16)
  begin
    if rising_edge(clk_div_by16) then
      if reset_n = '0' or one_step_up = '1' then
        -- Reset the output former on reset or after counting one up
        one_step_up <= '0';
      elsif  cout = 1 then
        -- Next step!
        one_step_up <= '1';
      else -- Keep value
        one_step_up <= one_step_up;
      end if;
    end if;
  end process;

  -- Other LEDs are laddered-up
  process (clk_div_by16)
  begin
    if (rising_edge(clk_div_by16)) then
      if reset = '1' then
        -- Reset the counter to 0
        ladder <= (others => '0');
      elsif one_step_up = '1' then
        -- Increment the counter for every change
        ladder <= ladder + 1;
      end if;
    end if;
  end process;
  led_n <=  Std_Logic_Vector(not ladder);  -- assign and invert

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
