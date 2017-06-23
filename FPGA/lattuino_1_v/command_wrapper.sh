#!/bin/bash
cd gen
xil_filter.pl LATTICE < comunica &
proc_hijo=$!
"$@" > comunica 2>&1
error_comando=$?
wait "$proc_hijo"
cd ..
exit "$error_comando"
