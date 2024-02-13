#Author: Ashley Nies, Nya Oster & Anastasia Barnett 
#References: 
# ============================================================================
#
#   DESCRIPTION: Script for using PayloadUST.rb
#
#   Modes:
#       0 - Aliveness Check
#       1 - Functional
#       2 - Take one photo 
# ============================================================================


def PayloadUST(start_time, mode, duration = nil)

#new function we added, is that right?
def get_sn()
  dut = ENV['DUT']
  if dut == 'FSX_ATB'
      device_sn = '21458177'
  elsif dut == 'FSX_FM'
    device_sn = '20323101'
  end
  return device_sn
end
  
    begin

        # Turn up APID rates
        cmd("MAX_FSX MISC_EVR with STRING 'E_INFO: Seq: PayloadUST, Turning up relative APID rates to 0.025 Hz.'")
        cmd("MAX_FSX MISC_CONFIG_PARSE with STRING 'rec_packet_med_rate_active.set_apid_freq(7302, 0.025);'") # DICE
        cmd("MAX_FSX MISC_CONFIG_PARSE with STRING 'rec_packet_med_rate_active.set_apid_freq(7303, 0.025);'") # DICE_CAL
        cmd("MAX_FSX MISC_CONFIG_PARSE with STRING 'rec_packet_med_rate_active.set_apid_freq(322, 0.025);'") # UST
        wait(1)

        # Power on DIAMOND MCU
        cmd("MAX_FSX MISC_EVR with STRING 'E_INFO: Seq: PayloadUST, Powering on DIAMOND MCU.'")
        cmd("MAX_FSX DICE_SET_PIN with INDEX 'USAFA_STAR_TRACKER_EN', VALUE 1")
        wait_check("MAX_FSX DICE DICE_USAFA_STAR_TRACKER_EN == 1", 60)
        #wait_check_tolerance("MAX_FSX DICE_CAL DICE_ADC_I_SNS_MCU_USAFA_STAR_TRACKER_CAL", TOLERANCE, EXPECT, 60)
        wait(1)

        if mode == 0 || mode == 1 || mode == 2

        cmd("MAX_FSX MISC_EVR with STRING 'E_INFO: Seq: PayloadUST, Waiting for start time'")
        wait_expression("Time.now.to_i >= #{start_time}",3154e5) # timeout set to wait 10 year.
        end
          
        case mode
        when 0 || 1 # Aliveness Check
            cmd("MAX_FSX MISC_EVR with STRING 'E_INFO: Seq: PayloadUST, Beginning Mode #{mode}: Aliveness'")
            wait(30)
            cmd("MAX_FSX MISC_EVR with STRING 'E_INFO: Seq: PayloadUST, Completed Mode #{mode}: Aliveness'")
            wait(1)
#new stuff      
        when 2 #taking 5 photos and sending to GS
          def test_case_02_Basic_Take_Photo
            cmd("MAX_FSX MISC_EVR with STRING 'E_INFO: Seq: PayloadUST, Beginning Mode #{mode}: Take Photo'") #diff color mode on nya and anyas
            #need to add some sort of verification then send this EVR
            cmd("MAX_FSX MISC_EVR with STRING 'E_INFO: Seq: PayloadUST, Running Mode #{mode}: Connected to Camera'")
            #probably need some wait time
            wait(1) 

            # have correct camera settings (EXPOSURE) (tony)  #still waiting on this
            cmd("MAX_FSX MISC_EVR with STRING 'E_INFO: Seq: PayloadUST, Running Mode #{mode}: Correct Camera Configuration'")
            wait(1)

            
            # Take pictures
            cmd("MAX_FSX FJ_START_REL with FUNCTION_CODE 399769600, SECONDS 0, FILE 'usafa_st.fj', ARGS 'TAKE'")
            if not_sent_count > 4 #is this right?? 
            # Wait for at least 4 pictures
              wait_check("MAX_FSX RF_USAFA_ST_REC_FL_TLM RF_USAFA_ST_NOT_SENT_COUNT > 4", 30)
            #if not greater than 4, add EVR? or something else?
            else
              wait_check("MAX_FSX RF_USAFA_ST_REC_FL_TLM RF_USAFA_ST_NOT_SENT_COUNT > 4", 30)
              puts 'There are not at least 4 pictures in the not_sent folder'
          end
          
          def test_case_03_download_photos
             
             device_sn = get_sn()
             #Name of file to down load
             file_names_array = [ 'Acquisition-' + device_sn + '-0.jpg',
                  'Acquisition-' + device_sn + '-1.jpg',
                  'Acquisition-' + device_sn + '-2.jpg',
                  'Acquisition-' + device_sn + '-3.jpg',
                  'Acquisition-' + device_sn + '-4.jpg',
                  'Acquisition-' + device_sn + '-5.jpg',
                  'Acquisition-' + device_sn + '-6.jpg',
                  'Acquisition-' + device_sn + '-7.jpg',
                  'Acquisition-' + device_sn + '-8.jpg',
                  'Acquisition-' + device_sn + '-9.jpg']
            #is the above just like spot to put pics? do we need to add more than 9? or is it okay if we dont fill them all?
             startingNumFailed = tlm("FILE_ULDL OVERALL_FILE_STATUS NUM_FAILED")
             usafa_st_base_path = '/home/root/active_spare/usafa_star_tracker/not_sent/'

           not_sent_count = tlm("MAX_FSX RF_USAFA_ST_REC_FL_TLM RF_USAFA_ST_NOT_SENT_COUNT")
           if not_sent_count > 4
             num_of_photos = download_an_array_of_files(file_names_array, usafa_st_base_path)

             # If this fails, then something went wrong downloading the files
             check_expression("tlm('FILE_ULDL OVERALL_FILE_STATUS NUM_FAILED') == #{startingNumFailed} ")
             puts "number of photos downloaded #{num_of_photos}"

             # Move pictures to the sent folder, and check success
             puts("Moving pictures to sent folder...")
             cmd("MAX_FSX FJ_START_REL with FUNCTION_CODE 399769600, SECONDS 0, FILE 'usafa_st.fj', ARGS 'MOVE'")
             wait_check("MAX_FSX RF_USAFA_ST_REC_FL_TLM RF_USAFA_ST_NOT_SENT_COUNT == 0", 180)
             wait_check("MAX_FSX RF_USAFA_ST_REC_FL_TLM RF_USAFA_ST_SENT_COUNT > 4", 30)
             
          else
            wait_check("MAX_FSX RF_USAFA_ST_REC_FL_TLM RF_USAFA_ST_NOT_SENT_COUNT > 4", 30)
            puts 'There are not at least 4 pictures in the not_sent folder' #should this be there are at least 4 photos in not_sent?
          end               
          cmd("MAX_FSX MISC_EVR with STRING 'E_INFO: Seq: PayloadUST, Completed Mode #{mode}: Take Photo'")
          wait(1)
          end
        end


    rescue Exception => e
        # Must raise an exception here to cause a non-zero exit code to move logs to anomaly
        raise "Exception during mode #{mode}: #{e.message} at #{e.backtrace}"
    
    ensure
        cmd("MAX_FSX MISC_EVR with STRING 'E_INFO: Seq: PayloadUST, Beginning cleanup procedures'")
        wait(1)
  
        # Power off UST
        cmd("MAX_FSX MISC_EVR with STRING 'E_INFO: Seq: PayloadUST, Powering off UST'")
        cmd("MAX_FSX DICE_SET_PIN with INDEX 'USAFA_STAR_TRACKER_EN', VALUE 0")
        wait_check("MAX_FSX DICE DICE_USAFA_STAR_TRACKER_EN == 0", 60)
        wait(1)

        # Turn down APID rates
        cmd("MAX_FSX MISC_EVR with STRING 'E_INFO: Seq: PayloadUST, Turning down relative APID rates'")
        cmd("MAX_FSX MISC_CONFIG_PARSE with STRING 'rec_packet_med_rate_active.set_apid_freq(322, 0.0);'") # UST
        cmd("MAX_FSX MISC_CONFIG_PARSE with STRING 'rec_packet_med_rate_active.set_apid_freq(7302, 0.0015);'") # DICE
        cmd("MAX_FSX MISC_CONFIG_PARSE with STRING 'rec_packet_med_rate_active.set_apid_freq(7303, 0.025);'") # DICE_CAL
        wait(1)  
  
        cmd("MAX_FSX MISC_EVR with STRING 'E_INFO: Seq: PayloadUST, Completed cleanup procedures'")
        wait(5)
        cmd("MAX_FSX MISC_EVR with STRING 'E_INFO: Seq: PayloadUST, SEQUENCE COMPLETE'")
    end
  end

# If start is started as an SM_START_REL, this section gets executed
if __FILE__==$0
    start_time = $args[0].to_i
    mode = $args[1].to_i
    duration = $args[2].to_i
    PayloadUST(start_time, mode, duration)
end



