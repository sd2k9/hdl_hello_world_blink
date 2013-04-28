onerror {resume}
wave add /
wave add /dut/clk
wave add /dut/clk_div_by16
wave add -radix unsigned /dut/cnt/q
run 1500 ms;
