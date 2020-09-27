#!/bin/bash
#
# toggle-display.sh
#
# Iterates through connected monitors in xrander and switched to the next one
# each time it is run.
#

# get info from xrandr
xStatus=`xrandr`
connectedOutputs=$(echo "$xStatus" | grep " connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
primaryedOutputs=$(echo "$xStatus" | grep " connected primary" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
activeOutput=$(echo "$xStatus" | grep -e " connected [^(]" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
connected=$(echo $connectedOutputs | wc -w)
pos=$(echo "$xStatus" | grep " connected primary" | grep -oE "[0-9]+x[0-9]+" | cut -dx -f2)
posh=$(echo "$xStatus" | grep " connected primary" | grep -oE "[0-9]+x[0-9]+" | cut -dx -f1)
# pos=$(echo "$xStatus" | grep "Screen 0:" |grep -oE 'current [0-9]+ x [0-9]+' | tr -d ' ' | awk -F'x' '{print $NF}')
# posh=$(echo "$xStatus" | grep "Screen 0:" |grep -oE 'current [0-9]+ x [0-9]+' | tr 'current' ' ' | tr -d ' ' | awk -F'x' '{print $1}')

# initialize variables
execute="xrandr --output $primaryedOutputs --auto --primary "

for display in $connectedOutputs
do
    if [[ $display == $primaryedOutputs ]]; then
        continue
    fi

    if [[ $1 == "original" ]]; then
        execute=$execute" --output "$display" --off"
    elif [[ $1 == "mirror" ]]; then
        execute=$execute" --output "$display" --auto --same-as "$primaryedOutputs
    elif [[  $1 == "splith" ]]; then
        execute=$execute"--pos 0x"$pos" --output "$display" --auto --pos 0x0"
    elif [[  $1 == "splitr" ]]; then
        execute=$execute"--pos 0x0 --output "$display" --auto --pos "$posh"x0"
    elif [[  $1 == "splitl" ]]; then
        execute=$execute"--pos "$posh"x0 --output "$display" --auto --pos 0x0"
    fi
done
echo $execute
`$execute`
