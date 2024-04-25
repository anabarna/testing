#Shell Script for running Acquisition.exe on ACE for taking pictures with USAFA ST
#Author: Connor Ohlson
#To run script, call the following prompt
#       /home/root/max/seq/sh/USAFA_ST_take_pictures.sh exposure=2005 gain=15
#           The recommended values are exposure= gain=  

# Parse Arguments
for arg in "$@"; do
    case $arg in
        exposure=*)
            exposure="${arg#*=}"
            ;;
        gain=*)
            gain="${arg#*=}"
            ;;
        *)
            echo "Invalid argument: $arg"
            exit 1
            ;;
    esac
done

# Navigate to correct folder for picture storage
cd /home/root/active_spare/usafa_star_tracker/unsent

# Run Exposure (should put 1 picture in the unsent folder)
echo "\"\\r\"" | /opt/spinnaker/bin/Exposure_v3 "$exposure" "$gain"
