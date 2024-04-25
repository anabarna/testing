#Shell Script for running lost on ACE to get quaternions 
#Author: Connor Ohlson
#To run script, call the following prompt:
#       /home/root/max/seq/sh/USAFA_ST_run_lost.sh centroid-mag-filter=<value> angular-tolerance=<value>
# 
#           The recommended values are centroid-mag-filter=156 angular-tolerance=0.0615 for pictures
#           taken on orbit, based off of the images taken at USAFA.


#!/bin/bash

# Set cd to the location of lost
cd /home/root/max/usafa_st/lost

for arg in "$@"; do
    case $arg in
        centroid-mag-filter=*)
            centroid_mag_filter="${arg#*=}"
            ;;
        angular-tolerance=*)
            angular_tolerance="${arg#*=}"
            ;;
        *)
            echo "Invalid argument: $arg"
            exit 1
            ;;
    esac
done

# Define the directory containing the PNG files on ACE
png_dir="/home/root/active_spare/usafa_star_tracker/unsent"

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/root/max/usafa_st/lost/lib

# Loop over each PNG file in the directory
for png_file in "$png_dir"/*.png; do
    
    # Run the command for each PNG file with provided arguments
    png_name=$(basename "$png_file" | sed 's:.*/::' | sed 's:png:txt:')
    
    /home/root/max/usafa_st/lost/lost pipeline \
    --png "$png_file" \
    --focal-length 49 \
    --centroid-algo cog \
    --centroid-mag-filter "$centroid_mag_filter" \
    --database /home/root/max/usafa_st/lost/my-database.dat \
    --star-id-algo py \
    --angular-tolerance "$angular_tolerance" \
    --pixel-size 22.2 \
    --false-stars 1000 \
    --max-mismatch-prob 0.0001 \
    --attitude-algo dqm \
    --print-attitude "/home/root/active_spare/usafa_star_tracker/unsent_attitudes/$png_name"
done


