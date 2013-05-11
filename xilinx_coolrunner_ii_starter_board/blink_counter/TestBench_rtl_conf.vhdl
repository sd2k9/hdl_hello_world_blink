--     TestBench_rtl_conf.vhdl - Configuration for RTL Testbench
--     for HDL Hello World for Coolrunner II Starter Board
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

-- *** Configuration for RTL Simulation needs to make some adjustments
--     The additional (unused and in POST optimized away) ports must be mapped


-- BlinkCounter
configuration BlinkCounter_rtl of BlinkCounter is
  for rtl                               -- architectur
    for all : binary_counter
      use entity work.binary_counter(rtl);
    end for;
  end for;
end BlinkCounter_rtl;

-- Testbench
configuration TestBench_rtl of TestBench is
  for beh                               -- architecture
    for All : BlinkCounter
      use configuration work.BlinkCounter_rtl
      port map (
		   -- map all default ports
			clk     => clk,
			reset_n => reset_n,
			led_n   => led_n,
			disp_ena_n => disp_ena_n,
			disp_seg_n => disp_seg_n,
			-- Not used ports: Optimized away in POST, therefore removed in TestBench
         btn1       => 'X',
         sw0        => 'X',
         sw1        => 'X'
      );
    end for;
  end for;
end TestBench_rtl;
