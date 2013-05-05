--     TestBench_post_conf.vhdl - Configuration for POST Testbench
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

-- *** Configuration for Post (Gatelevel) Simulation just connects everything as it is
--     No special changes are required


-- *** Includes
library ieee;
use ieee.std_logic_1164.all;

-- BlinkCounter
configuration BlinkCounter_post of BlinkCounter is
  for Structure                               -- architecture
  end for;
end BlinkCounter_post;

-- Testbench
configuration Testbench_post of TestBench is
  for beh                               -- architecture
    for All : BlinkCounter
      use configuration work.BlinkCounter_post;
    end for;
  end for;
end TestBench_post;
