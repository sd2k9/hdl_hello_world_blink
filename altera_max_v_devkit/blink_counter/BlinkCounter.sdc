# ------------------------------------------
set_time_unit ns
set_decimal_places 3

# ------------------------------------------
#
# 10 MHz Clock
create_clock -period 100.0 -waveform { 0 50.0 } clk -name clk
