(* Safety *)
IF sensor_TankCurrentTemp < safety_TempSensorMin OR sensor_TankCurrentTemp > safety_TempSensorMax THEN
    safety_AlarmTempSensorFault := TRUE;
END_IF

IF sensor_TankCurrentLevel < safety_LevelSensorMin OR sensor_TankCurrentLevel > safety_LevelSensormax THEN
    safety_AlarmLevelSensorFault := TRUE;
END_IF

IF sensor_TankCurrentTemp > (input_SetTankTemp + safety_OverTempMargin) THEN
    safety_AlarmOverTemp := TRUE;
END_IF

IF sensor_TankCurrentLevel > input_SetMaxTankLevel THEN
    safety_AlarmOverflow := sensor_TankCurrentLevel > input_SetMaxTankLevel;
END_IF

IF safety_AlarmOverTemp OR safety_AlarmOverflow OR safety_AlarmTempSensorFault OR safety_AlarmLevelSensorFault THEN
    safety_AnyCriticalAlarm := TRUE;
END_IF

IF safety_AnyCriticalAlarm THEN
    state_EmergencyStop := TRUE;
    output_Alarm := TRUE;
    IF safety_AlarmOverTemp THEN
        string_Alarm := 'QUÁ NHIỆT - VAN HƠI ĐÓNG KHẨN CẤP';
    ELSIF safety_AlarmOverflow THEN
        string_Alarm := 'TRÀN MỰC BỒN - ĐÃ ĐÓNG VAN NHẬN SỐT KHẨN CẤP';
    ELSIF safety_AlarmTempSensorFault THEN
        string_Alarm := 'CẢM BIẾN NHIỆT ĐỘ LỖI';
    ELSIF safety_AlarmLevelSensorFault THEN
        string_Alarm := 'CẢM BIẾN MỰC BỒN LỖI';
    END_IF
END_IF

(* Other signal *)
IF sensor_TankCurrentLevel >= (input_SetMaxTankLevel - 20.0) THEN
    output_TankFull := TRUE;
END_IF

IF state_StateOfOp = 3 AND NOT safety_AnyCriticalAlarm AND NOT state_EmergencyStop AND (sensor_TankCurrentTemp >= input_SetTankTemp - 5.0) AND (sensor_TankCurrentLevel >= input_SetMinTankLevel) THEN
    output_TankReady := TRUE;
END_IF

(* Pulse Timer *)
pulse_Timer(IN := NOT pulse_Timer.Q, PT := T#1s);
pulse_TimerOneSec := pulse_Timer.Q;

(* Log *)
timer_HourPulse(IN := NOT timer_HourPulse.Q, PT := log_IntervalSet);
log_HourPulse := timer_HourPulse.Q;

IF log_HourPulse THEN
    log_LevelHistory[log_LevelHistoryIndex] := sensor_TankCurrentLevel;
    log_LevelHistoryIndex := log_LevelHistoryIndex + 1;
    IF log_LevelHistoryIndex > 23 THEN
        log_LevelHistoryIndex := 0;
    END_IF
END_IF

(* Timer from start to finish *)
timer_TimeElapsed(IN := state_MachineRunning OR state_IsPaused, PT := T#24h);
timer_TimeElapsed_Value := timer_TimeElapsed.ET;

(* Button function *)
IF button_EmergencyStop THEN
    state_EmergencyStop := TRUE;
    state_IsPaused := TRUE;
    state_MachineRunning := FALSE;
END_IF

IF button_Stop AND NOT state_EmergencyStop THEN
    state_IsPaused := TRUE;
    state_MachineRunning := FALSE;
END_IF

IF button_Start AND NOT state_EmergencyStop THEN
    state_IsPaused := FALSE;
    state_MachineRunning := TRUE;
END_IF

IF button_Reset AND state_EmergencyStop AND NOT safety_AnyCriticalAlarm THEN
    state_IsPaused := FALSE;
    state_EmergencyStop := FALSE;
    output_Alarm := FALSE;
    string_Alarm := '';
    state_StateOfOp := 0;
END_IF


IF button_Shutdown THEN
    state_ShutdownRequested := TRUE;
END_IF

(* Maintenance *)
IF maintenance_ManualMode AND (state_StateOfOp = 0) AND NOT state_EmergencyStop THEN
    maintenance_ManualModeActive := TRUE;
END_IF

(* Main *)
IF state_IsPaused OR state_EmergencyStop THEN
    IF state_IsPaused AND NOT state_EmergencyStop THEN
        string_Normal := 'MÁY ĐANG TẠM DỪNG';
    ELSIF state_EmergencyStop THEN
        output_Alarm := TRUE;
        IF NOT safety_AnyCriticalAlarm THEN
            string_Alarm := 'MÁY ĐANG DỪNG KHẨN CẤP - NHẤN "Reset" ĐỂ TIẾP TỤC';
        END_IF
    END_IF

    output_XOValve := FALSE;
    output_DischargeValve := FALSE;
    output_DrainValve := FALSE;
    output_Motor := FALSE;
    output_SteamValve := 0.0;

    PID_Heating(SetPoint := input_SetTankTemp,
                ProcessValue := sensor_TankCurrentTemp,
                Kp := PID_Heating_Kp,
                Ti := PID_Heating_Ti,
                Td := PID_Heating_Td,
                CycleTime := 1.0,
                Enable := FALSE);
    PID_Holding(SetPoint := input_SetTankTemp,
                ProcessValue := sensor_TankCurrentTemp,
                Kp := PID_Holding_Kp,
                Ti := PID_Holding_Ti,
                Td := PID_Holding_Td,
                CycleTime := 1.0,
                Enable := FALSE);
    PID_Output := 0.0;

ELSIF maintenance_ManualModeActive THEN
    string_Normal := 'CHẾ ĐỘ BẢO TRÌ (MANUAL) - ĐANG ĐIỀU KHIỂN TAY';

    IF maintenance_ManualXOValve AND maintenance_ManualDrainValve THEN
        output_XOValve := FALSE;
        output_DrainValve := FALSE;
        output_Alarm := TRUE;
        string_Alarm := 'MANUAL: KHÔNG THỂ NHẬN SỐT VÀ XẢ ĐÁY CÙNG LÚC';
    ELSE
        output_XOValve := maintenance_ManualXOValve;
        output_DrainValve := maintenance_ManualDrainValve;
    END_IF

    output_DischargeValve := maintenance_ManualDischargeValve;
    IF maintenance_ManualMotor AND (sensor_TankCurrentLevel > safety_MinLevelForMotor) THEN
        output_Motor := TRUE;
    END_IF
    output_SteamValve := maintenance_ManualSteamValve;

    PID_Heating(SetPoint := input_SetTankTemp,
                ProcessValue := sensor_TankCurrentTemp,
                Kp := PID_Heating_Kp,
                Ti := PID_Heating_Ti,
                Td := PID_Heating_Td,
                CycleTime := 1.0, Enable := FALSE);
    PID_Holding(SetPoint := input_SetTankTemp,
                ProcessValue := sensor_TankCurrentTemp,
                Kp := PID_Holding_Kp,
                Ti := PID_Holding_Ti,
                Td := PID_Holding_Td,
                CycleTime := 1.0,
                Enable := FALSE);
    PID_Output := 0.0;
ELSE
    CASE state_StateOfOp OF
        0: (* Idle *)
            string_Normal := 'ĐANG TRONG CHẾ ĐỘ CHỜ';

            output_XOValve := FALSE;
            output_DischargeValve := FALSE;
            output_DrainValve := FALSE;
            output_Motor := FALSE;
            output_SteamValve := 0.0;

            PID_Heating(SetPoint := input_SetTankTemp,
                        ProcessValue := sensor_TankCurrentTemp,
                        Kp := PID_Heating_Kp,
                        Ti := PID_Heating_Ti,
                        Td := PID_Heating_Td,
                        CycleTime := 1.0, Enable := FALSE);
            PID_Holding(SetPoint := input_SetTankTemp,
                        ProcessValue := sensor_TankCurrentTemp,
                        Kp := PID_Holding_Kp,
                        Ti := PID_Holding_Ti,
                        Td := PID_Holding_Td,
                        CycleTime := 1.0,
                        Enable := FALSE);
            PID_Output := 0.0;

            timer_WaitTimeBetweenOp(IN := FALSE);
            timer_DrainWaitTime(IN := FALSE);
            timer_TimeElapsed(IN := FALSE);
            timer_TimeElapsed_Value := T#0s;

            timer_FillTimeout(IN := FALSE);
            timer_HeatingTimeout(IN := FALSE);
            timer_ShutdownDrainTimeout(IN := FALSE);
            safety_AlarmFillTimeout := FALSE;
            safety_AlarmHeatingTimeout := FALSE;
            safety_AlarmShutdownDrainTimeout := FALSE;

            state_ShutdownRequested := FALSE;
            state_AgitateActive := FALSE;
            timer_AgitateInterval(IN := FALSE);
            timer_AgitateDuration(IN := FALSE);

            FOR log_ClearIndex := 0 TO 23 DO
                log_LevelHistory[log_ClearIndex] := 0.0;
            END_FOR
            log_LevelHistoryIndex := 0;
            timer_HourPulse(IN := FALSE);

            IF button_Start AND NOT state_EmergencyStop THEN
                state_StateOfOp := 1;
            END_IF
        1: (* Fill to min *)
            string_Normal := 'ĐANG NHẬN SỐT XO - CHỜ ĐỦ MỨC TỐI THIỂU';

            timer_FillTimeout(IN := TRUE, PT := safety_FillTimeoutSet);
            IF timer_FillTimeout.Q THEN
                safety_AlarmFillTimeout := TRUE;
                state_EmergencyStop := TRUE;
                output_Alarm := TRUE;
                string_Alarm := 'CHỜ NHẬN SỐT QUÁ LÂU - KIỂM TRA BỒN NẤU / ĐƯỜNG ỐNG DẪN';
            END_IF

            output_XOValve := TRUE;
            output_DischargeValve := FALSE;

            IF sensor_TankCurrentLevel >= input_SetMinTankLevel THEN
                timer_FillTimeout(IN := FALSE);
                safety_AlarmFillTimeout := FALSE;

                string_Normal := 'ĐÃ ĐỦ MỨC TỐI THIỂU';
                state_Wait := TRUE;
                timer_WaitTimeBetweenOp(IN := state_Wait, PT := input_SetWaitTimeBetweenOp);
                IF timer_WaitTimeBetweenOp.Q THEN
                    state_Wait := FALSE;
                    timer_WaitTimeBetweenOp(IN := state_Wait);
                    state_StateOfOp := 2;
                END_IF
            END_IF

        2: (* Heating *)
            string_Normal := 'ĐANG GIA NHIỆT';
            IF sensor_TankCurrentLevel > safety_MinLevelForMotor THEN
                output_Motor := TRUE;
            END_IF
            IF sensor_TankCurrentLevel < input_SetFillLowLevel THEN
                output_XOValve := TRUE;
            END_IF

            timer_HeatingTimeout(IN := TRUE, PT := safety_HeatingTimeoutSet);
            IF timer_HeatingTimeout.Q THEN
                safety_AlarmHeatingTimeout := TRUE;
                state_EmergencyStop := TRUE;
                output_Alarm := TRUE;
                string_Alarm := 'GIA NHIỆT QUÁ LÂU - KIỂM TRA NGUỒN HƠI';
            END_IF

            IF pulse_TimerOneSec THEN
                PID_Heating(SetPoint := input_SetTankTemp,
                            ProcessValue := sensor_TankCurrentTemp,
                            Kp := PID_Heating_Kp,
                            Ti := PID_Heating_Ti,
                            Td := PID_Heating_Td,
                            CycleTime := 1.0,
                            Enable := TRUE,
                            OutMin := 0.0,
                            OutMax := 100.0);
            END_IF
            PID_Output := PID_Heating.Out;
            output_SteamValve := PID_Output;

            IF sensor_TankCurrentTemp >= input_SetTankTemp THEN
                timer_HeatingTimeout(IN := FALSE);
                safety_AlarmHeatingTimeout := FALSE;

                string_Normal := 'HOÀN TẤT GIA NHIỆT - CHUYỂN SANG GIỮ NHIỆT';
                state_Wait := TRUE;
                timer_WaitTimeBetweenOp(IN := state_Wait, PT := input_SetWaitTimeBetweenOp);
                IF timer_WaitTimeBetweenOp.Q THEN
                    state_Wait := FALSE;
                    timer_WaitTimeBetweenOp(IN := state_Wait);
                    state_StateOfOp := 3;
                END_IF
            END_IF
        3: (* *)
            string_Normal := 'ĐANG VẬN HÀNH LIÊN TỤC - CẤP CHO ĐÓNG GÓI';
            IF sensor_TankCurrentLevel <= input_SetFillLowLevel THEN
                output_XOValve := TRUE;
            ELSIF sensor_TankCurrentLevel >= input_SetFillHighLevel THEN
                output_XOValve := FALSE;
            END_IF

            IF pulse_TimerOneSec THEN
                PID_Holding(SetPoint := input_SetTankTemp,
                            ProcessValue := sensor_TankCurrentTemp,
                            Kp := PID_Holding_Kp,
                            Ti := PID_Holding_Ti,
                            Td := PID_Holding_Td,
                            CycleTime := 1.0,
                            Enable := TRUE,
                            OutMin := 0.0,
                            OutMax := 100.0);
            END_IF
            PID_Output := PID_Holding.Out;
            output_SteamValve := PID_Output;

            IF sensor_TankCurrentLevel <= safety_MinLevelForDischarge THEN
                safety_AlarmLowLevel := TRUE;
                output_DischargeValve := FALSE;
                output_Alarm := TRUE;
                string_Alarm := 'MỰC BỒN THẤP - ĐÃ NGƯNG CẤP CHO MÁY ĐÓNG GÓI';
            ELSE
                safety_AlarmLowLevel := FALSE;
                output_DischargeValve := sensor_PackagingReady;
            END_IF

            IF input_ContinuousAgitation THEN
                IF sensor_TankCurrentLevel > safety_MinLevelForMotor THEN
                    output_Motor := TRUE;
                END_IF
            ELSE
                IF NOT state_AgitateActive THEN
                    timer_AgitateInterval(IN := TRUE, PT := input_SetAgitateInterval);
                    IF timer_AgitateInterval.Q THEN
                        timer_AgitateInterval(IN := FALSE);
                        state_AgitateActive := TRUE;
                    END_IF
                ELSE
                    timer_AgitateDuration(IN := TRUE, PT := input_SetAgitateDuration);
                    IF timer_AgitateDuration.Q THEN
                        timer_AgitateDuration(IN := FALSE);
                        state_AgitateActive := FALSE;
                    END_IF
                END_IF
                IF state_AgitateActive AND (sensor_TankCurrentLevel > safety_MinLevelForMotor) THEN
                    output_Motor := TRUE;
                END_IF
            END_IF

            IF state_ShutdownRequested THEN
                state_StateOfOp := 4;
            END_IF

        4: (* CIP *)
            string_Normal := 'ĐANG XẢ BỒN';

            output_XOValve := FALSE;
            output_DischargeValve := FALSE;
            output_Motor := FALSE;
            output_SteamValve := 0.0;
            output_DrainValve := TRUE;
 
            PID_Holding(SetPoint := input_SetTankTemp,
                        ProcessValue := sensor_TankCurrentTemp,
                        Kp := PID_Holding_Kp,
                        Ti := PID_Holding_Ti,
                        Td := PID_Holding_Td,
                        CycleTime := 1.0,
                        Enable := FALSE);
 
            timer_ShutdownDrainTimeout(IN := TRUE, PT := safety_ShutdownDrainTimeoutSet);
            IF timer_ShutdownDrainTimeout.Q THEN
                safety_AlarmShutdownDrainTimeout := TRUE;
                output_Alarm := TRUE;
                string_Alarm := 'XẢ QUÁ LÂU - KIỂM TRA VAN XẢ';
            END_IF
 
            IF sensor_TankCurrentLevel <= 5.0 THEN
                timer_DrainWaitTime(IN := TRUE, PT := input_SetDrainWaitTime);
                IF timer_DrainWaitTime.Q THEN
                    timer_DrainWaitTime(IN := FALSE);
                    timer_ShutdownDrainTimeout(IN := FALSE);
                    safety_AlarmShutdownDrainTimeout := FALSE;
                    output_DrainValve := FALSE;
                    state_ShutdownRequested := FALSE;
                    state_StateOfOp := 0;
                END_IF
            END_IF
    END_CASE
END_IF

IF simulate_SimMode THEN
    IF state_StateOfOp = 1 THEN
        simulate_LevelSim(XOValveActive := output_XOValve,
                          XOFillRate := simulate_LevelSim_XOFillRate,
                          DischargeValveActive := output_DischargeValve,
                          DischargeRate := simulate_LevelSim_DischargeRate,
                          DrainValveActive := output_DrainValve,
                          DrainRate := simulate_LevelSim_DrainRate,
                          Execute := pulse_TimerOneSec,
                          Reset := simulate_SimReset,
                          InitialLevel := simulate_LevelSim_InitialLevel);
        sensor_TankCurrentLevel := simulate_LevelSim.SimulatedLevel;
    ELSE
        sensor_TankCurrentLevel := simulate_LevelSim.SimulatedLevel;
    END_IF

    simulate_TempSim(SteamValveInput := output_SteamValve,
                     AmbientTemp := simulate_TempSim_AmbientTemp,
                     MaxHeatingPerSec := simulate_TempSim_MaxHeatRate,
                     HeatLossCoeff := simulate_TempSim_HeatLossCoeff,
                     Execute := pulse_TimerOneSec,
                     Reset := simulate_SimReset);
    sensor_TankCurrentTemp := simulate_TempSim.SimulatedTemp;
END_IF