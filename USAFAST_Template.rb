#  =================================================== 
#
#        ***** Event
#            - Star Tracker Task at DD Mmm HH:MM:SS Z
#	            
#  ===================================================	

# Set Variables
start_time = DateTime.strptime("MM/DD/YYYY HH:MM:SS.000", date_format).to_time.to_i #strptime(Date, Format)
mode = **
duration = **    # For mode 2 (standard pictures) 30 seconds is plenty of time

#Set Slew Variables
task_duration = duration     # Duration plus slew time
slew_mode = **             # Desired Orientation of satellite during event. #Quaterion pointing case (inertial hold)
target = **			     # Target location number. If not used, send with 0  
slewincompletiontime = start_time - 600 # Slew in 10 mins before start time
slewoutcompletiontime = start_time + task_duration + 360           # Slew out after event

# Only if needed, otherwise leave equal to [q0, q1, q2, q3] = [0.0, 0.0, 0.0, 1.0].
# If needed, do not use more than 6 places behind decimal, this is needed for slew_mode = 7
q0 = 0.0
q1 = 0.0
q2 = 0.0
q3 = 1.0

wait_expression("Time.now.to_i >= #{slewincompletiontime-600}",wait_time) 
# Send EVR's
cmd("MAX_FSX MISC_EVR with STRING 'E_INFO: Seq: PayloadUSAFAST, SEQUENCE BEGINNING'")
wait(1)
cmd("MAX_FSX MISC_EVR with STRING 'E_INFO: Seq: PayloadUSAFAST, Start Time: #{start_time}, USAFAST Mode: #{mode}, Task Duration: #{task_duration}'")
wait(1)

#loop to start slew if slewing
if slew_mode != 0
    cmd("MAX_FSX MISC_EVR with STRING 'E_INFO: Seq: PayloadUSAFAST, SlewIn Completion Time: #{slewincompletiontime}, SlewOut Completion Time: #{slewoutcompletiontime}'")
    wait(1)
    # Start Master ADCS
    cmd("MAX_FSX FJ_START_REL with Seconds 0, File Master_ADCS.fj, Args '#{slewincompletiontime},#{slew_mode},#{target},#{q0},#{q1},#{q2},#{q3}'")
end

#Wait for start time of event
wait_expression("Time.now.to_i >= #{start_time-300}", wait_time) # Timeout variable set to wait 1 year.

#Start payload event
cmd("MAX_FSX SM_START_REL with SECONDS 0, FILE_NAME PayloadUSAFAST.rb, ARGS '#{start_time} #{mode} #{duration}'")

#Slew back to Sun Track if slewing
if slew_mode != 0
    wait_expression("Time.now.to_i >= #{slewoutcompletiontime-360}",wait_time) 
    cmd("MAX_FSX FJ_START_REL with Seconds 0, File Master_ADCS.fj, Args '#{slewoutcompletiontime},1,0,0,0,0,0'")
end

# ****End of Event****
