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
        when 0 # Aliveness Check
            cmd("MAX_FSX MISC_EVR with STRING 'E_INFO: Seq: PayloadUST, Beginning Mode #{mode}: Aliveness'")
            wait(30)
            cmd("MAX_FSX MISC_EVR with STRING 'E_INFO: Seq: PayloadUST, Completed Mode #{mode}: Aliveness'")
            wait(1)

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
