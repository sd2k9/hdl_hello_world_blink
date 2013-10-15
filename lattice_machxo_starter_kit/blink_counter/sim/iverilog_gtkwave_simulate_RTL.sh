#!/bin/bash
# Compile design with iverilog for simulation with GTKwave
# Architecture: RTL

iverilog -I ../src -o TestBench.RTL.vvp -s TestBench \
    ../src/TestBench.v     ../src/BlinkCounter.v
    # -v

ERR=$?
if [ $ERR -ne 0 ]; then
    echo "iverilog failed with exit code $ERR"
    exit 1
fi

vvp -v TestBench.RTL.vvp -lxt
ERR=$?
if [ $ERR -ne 0 ]; then
    echo "vvp failed with exit code $ERR"
    exit 1
fi

echo
echo "Done!"
echo
echo "Start simulation with"
echo "gtkwave TestBench.dump.lxt"
echo
