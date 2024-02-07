#Shell Script for running Acquisition.exe on ACE for taking pictures with USAFA ST
#Author: Zack Dunn

#Navigate to correct folder for picture storage
cd /home/root/active_spare/usafa_star_tracker/not_sent/

#Run Acquisition (should put 10 pictures in the not_sent folder)
echo \"\\r\" | /opt/spinnaker/bin/Acquisition
