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

(* Pulse Timer *)
pulse_Timer(IN := NOT pulse_Timer.Q, PT := T#1s);
pulse_TimerOneSec := pulse_Timer.Q;

(* Cycle Counter *)
cycle_SmallCycle(CU := state_EndCycle, PV := 6);
cycle_LargeCycle(CU := cycle_SmallCycle.Q, PV := 5);

cycle_SmallCycle_Value := cycle_SmallCycle.CV;
cycle_LargeCycle_Value := cycle_LargeCycle.CV;

(* Timer from Start to Finish *)
timer_TimeElapsed(IN := state_MachineRunning OR state_IsPaused, PT := T#24h);
timer_TimeElapsed_Value := timer_TimeElapsed.ET;

IF state_EndCycle AND state_MachineRunning THEN
    cycle_LastCycleTimeElapsed := timer_TimeElapsed_Value;
    timer_TimeElapsed_Value := T#0s;
    state_EndCycle := FALSE;
    state_MachineRunning := FALSE;
END_IF

(* Button Function *)
IF button_EmergencyStop THEN
    state_IsPaused := TRUE;
    state_MachineRunning := FALSE;
    state_EmergencyStop := TRUE;
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

(* Maintenance *)
IF maintenance_ManualMode AND (state_StateOfOp = 0) AND NOT state_EmergencyStop THEN
    maintenance_ManualModeActive := TRUE;
END_IF

(* Main function *)
IF state_IsPaused OR state_EmergencyStop THEN
    IF state_IsPaused AND NOT state_EmergencyStop THEN
        string_Normal := 'MÁY ĐANG TẠM DỪNG';
    ELSIF state_EmergencyStop THEN
        output_Alarm := TRUE;
        string_Alarm := 'MÁY ĐANG DỪNG KHẨN CẤP - NHẤN "Reset" ĐỂ TIẾP TỤC';
    END_IF

    output_OilPump := FALSE;
    output_Motor := FALSE;
    output_DrainValve := FALSE;
    output_SteamValve := 0.0;

    PID_Heating(SetPoint := input_SetTankTemp, 
                ProcessValue := sensor_TankCurrentTemp,
                Kp := PID_Heating_Kp,
                Ti := PID_Heating_Ti,
                Td := PID_Heating_Td,
                CycleTime := 1.0,
                Enable := FALSE);
    PID_Cooking(SetPoint := input_SetTankTemp,
                ProcessValue := sensor_TankCurrentTemp,
                Kp := PID_Cooking_Kp,
                Ti := PID_Cooking_Ti,
                Td := PID_Cooking_Td,
                CycleTime := 1.0,
                Enable := FALSE);
    PID_Output := 0.0;
ELSIF maintenance_ManualModeActive THEN
    string_Normal := 'CHẾ ĐỘ BẢO TRÌ (MANUAL) - ĐANG ĐIỀU KHIỂN TAY';
    
    IF maintenance_ManualOilPump AND maintenance_ManualDrainValve THEN
        output_OilPump := FALSE;
        output_DrainValve := FALSE;
        output_Alarm := TRUE;
        string_Alarm := 'MANUAL: KHÔNG THỂ BƠM DẦU VÀ XẢ ĐÁY CÙNG LÚC';
    ELSE
        output_OilPump := maintenance_ManualOilPump;
        output_DrainValve := maintenance_ManualDrainValve;
    END_IF

    IF maintenance_ManualMotor AND (sensor_TankCurrentLevel > safety_MinLevelForMotor) THEN
        output_Motor := TRUE;
    END_IF
    output_SteamValve := maintenance_ManualSteamValve;

    PID_Heating(SetPoint := input_SetTankTemp,
                ProcessValue := sensor_TankCurrentTemp,
                Kp := PID_Heating_Kp,
                Ti := PID_Heating_Ti,
                Td := PID_Heating_Td,
                CycleTime := 1.0,
                Enable := FALSE);
    PID_Cooking(SetPoint := input_SetTankTemp,
                ProcessValue := sensor_TankCurrentTemp,
                Kp := PID_Cooking_Kp,
                Ti := PID_Cooking_Ti,
                Td := PID_Cooking_Td,
                CycleTime := 1.0,
                Enable := FALSE);
    PID_Output := 0.0;
ELSE
    CASE state_StateOfOp OF
        0: (* Idle state *)
            string_Normal := 'ĐANG TRONG CHẾ ĐỘ CHỜ';

            output_OilPump := FALSE;
            output_Motor := FALSE;
            output_DrainValve := FALSE;
            output_SteamValve := 0.0;

            PID_Heating(SetPoint := input_SetTankTemp, 
                        ProcessValue := sensor_TankCurrentTemp,
                        Kp := PID_Heating_Kp,
                        Ti := PID_Heating_Ti,
                        Td := PID_Heating_Td,
                        CycleTime := 1.0,
                        Enable := FALSE);
            PID_Cooking(SetPoint := input_SetTankTemp,
                        ProcessValue := sensor_TankCurrentTemp,
                        Kp := PID_Cooking_Kp,
                        Ti := PID_Cooking_Ti,
                        Td := PID_Cooking_Td,
                        CycleTime := 1.0,
                        Enable := FALSE);
            PID_Output := 0.0;
        
            timer_WaitTimeBetweenOp(IN := FALSE);
            timer_DrainWaitTime(IN := FALSE);
            timer_TimeElapsed(IN := FALSE);
            timer_TimeElapsed_Value := T#0s;

            timer_State1Timeout(IN := FALSE);
            timer_State4Timeout(IN := FALSE);
            timer_State6Timeout(IN := FALSE);
            time_IngredientWaitTimeout(IN := FALSE);
            safety_Alarm1StateTimeout := FALSE;
            safety_Alarm4StateTimeout := FALSE;
            safety_Alarm6StateTimeout := FALSE;
            safety_AlarmIngredientTimeout := FALSE;

            IF button_Start AND NOT state_EmergencyStop THEN
                state_StateOfOp := 1;
            END_IF

        1: (* Pump oil *)
            timer_State1Timeout(IN := TRUE, PT := safety_State1TimeoutSet);
            IF timer_State1Timeout.Q THEN
                safety_AlarmState1Timeout := TRUE;
                state_EmergencyStop := TRUE;
                output_Alarm := TRUE;
                string_Alarm := 'CHỜ NHẬN SỐT QUÁ LÂU - KIỂM TRA BỒN NẤU / ĐƯỜNG ỐNG DẪN';
            END_IF

            IF sensor_TankCurrentLevel < input_SetOilLevel THEN
                string_Normal := 'ĐANG TRONG QUÁ TRÌNH BƠM DẦU';
                output_OilPump := TRUE;
            ELSE
                string_Normal := 'HOÀN THÀNH QUÁ TRÌNH BƠM DẦU';
                output_OilPump := FALSE;
                state_Wait := TRUE;
                timer_WaitTimeBetweenOp(IN := state_Wait, PT := input_SetWaitTimeBetweenOP);
                IF timer_WaitTimeBetweenOp.Q THEN
                    state_Wait := FALSE;
                    timer_WaitTimeBetweenOp(IN := state_Wait);
                    state_StateOfOp := 2;
                END_IF
            END_IF

        2: (* Wait for ingredient *)
            string_Normal := 'ĐANG CHỜ THÊM NGUYÊN LIỆU';
            
            timer_IngredientWaitTimeout(IN := TRUE, PT := safety_IngredientWaitTimeoutSet);
            IF timer_IngredientWaitTimeout.Q THEN
                safety_AlarmIngredientTimeout := TRUE;
                output_Alarm := TRUE;
                string_Alarm := 'QUÁ THỜI GIAN CHỜ NGUYÊN LIỆU';
            END_IF

            IF button_ConfirmIngredient THEN
                state_StateOfOp := 3;
            END_IF

        3: (* Check ingredient level *)
            IF sensor_TankCurrentLevel >= input_SetIngredientLevel THEN
                string_Normal := 'ĐÃ ĐỦ LƯỢNG NGUYÊN LIỆU';
                state_Wait := TRUE;
                timer_WaitTimeBetweenOp(IN := state_Wait, PT := input_SetWaitTimeBetweenOp);
                IF timer_WaitTimeBetweenOp.Q THEN
                    state_Wait := FALSE;
                    timer_WaitTimeBetweenOp(IN := state_Wait);
                    state_StateOfOp := 4;
                END_IF
            ELSE
                string_Normal := 'CHƯA ĐỦ LƯỢNG NGUYÊN LIỆU';
                state_Wait := TRUE;
                timer_WaitTimeBetweenOp(IN := state_Wait, PT := input_SetWaitTimeBetweenOp);
                IF timer_WaitTimeBetweenOp.Q THEN
                    state_Wait := FALSE;
                    timer_WaitTimeBetweenOp(IN := state_Wait);
                    state_StateOfOp := 2;
                END_IF
            END_IF

        4: (* Heating *)
            string_Normal := 'BẮT ĐẦU QUÁ TRÌNH GIA NHIỆT';
            output_Motor := sensor_TankCurrentLevel > safety_MinLevelForMotor;

            timer_State4Timeout(IN := TRUE, PT := safety_State4TimeoutSet);
            IF timer_State4Timeout.Q THEN
                safety_AlarmState4Timeout := TRUE;
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
                string_Normal := 'HOÀN TẤT QUÁ TRÌNH GIA NHIỆT';
                state_Wait := TRUE;
                timer_WaitTimeBetweenOp(IN := state_Wait, PT := input_SetWaitTimeBetweenOp);
                IF timer_WaitTimeBetweenOp.Q THEN
                    state_Wait := FALSE;
                    timer_WaitTimeBetweenOp(IN := state_Wait);
                    state_StateOfOp := 5;
                END_IF
            END_IF

        5: (* Cooking *)
        string_Normal := 'ĐANG TRONG QUÁ TRÌNH NẤU';

        output_Motor := sensor_TankCurrentLevel > safety_MinLevelForMotor;

        IF pulse_TimerOneSec THEN
            PID_Cooking(SetPoint := input_SetTankTemp,
                        ProcessValue := sensor_TankCurrentTemp,
                        Kp := PID_Cooking_Kp,
                        Ti := PID_Cooking_Ti,
                        Td := PID_Cooking_Td,
                        CycleTime := 1.0,
                        Enable := TRUE,
                        OutMin := 0.0,
                        OutMax := 100.0);
            pulse_CookTimeElapsed := pulse_CookTimeElapsed + T#1s;
        END_IF
        PID_Output := PID_Cooking.Out;
        output_SteamValve := PID_Output;

        IF pulse_CookTimeElapsed >= input_SetCookTime THEN
            output_SteamValve := 0.0;
            string_Normal := 'HOÀN TẤT QUÁ TRÌNH NẤU';
            state_Wait := TRUE;
            timer_WaitTimeBetweenOp(IN := state_Wait, PT := input_SetWaitTimeBetweenOp);
            IF timer_WaitTimeBetweenOp.Q THEN
                state_Wait := FALSE;
                timer_WaitTimeBetweenOp(IN := state_Wait);
                state_StateOfOp := 6;
            END_IF
        END_IF

    6: (* Draining *)
        string_Normal := 'ĐANG TRONG QUÁ TRÌNH XẢ THÀNH PHẨM';
        output_DrainValve := TRUE;

        timer_State6Timeout(IN := TRUE, PT := safety_State6TimeoutSet);
        IF timer_State6Timeout.Q THEN
            safety_AlarmState6Timeout := TRUE;
            state_EmergencyStop := TRUE;
            output_Alarm := TRUE;
            string_Alarm := 'QUÁ THỜI GIAN XẢ - KIỂM TRA ĐƯỜNG ỐNG DẪN';
        END_IF

        IF sensor_TankCurrentLevel <= 5 THEN
            timer_DrainWaitTime(IN := TRUE, PT := input_SetDrainWaitTime);
            IF timer_DrainWaitTime.Q THEN
                timer_DrainWaitTime(IN:= FALSE);
                output_DrainValve := FALSE;
                output_Motor := FALSE;
                state_EndCycle := TRUE;
                state_StateOfOp := 0;
            END_IF
        END_IF
    END_CASE
END_IF

(* Simulate *)
IF simulate_SimMode THEN
    simulate_TankLevelSim(OilPumpActive := output_OilPump,
                          IngredientTrigger := button_ConfirmIngredient,
                          DrainValveActive := output_DrainValve,
                          Execute := pulse_TimerOneSec,
                          Reset := simulate_SimReset,
                          OilFillRate := simulate_TankLevelSim_OilFillRate,
                          IngredientAmount := simulate_TankLevelSim_IngredientAmount,
                          DrainRate := simulate_TankLevelSim_DrainRate);
    sensor_TankCurrentLevel := simulate_TankLevelSim.SimulatedLevel;

    simulate_TankTempSim(SteamValveInput := output_SteamValve,
                         AmbientTemp := simulate_TankTempSim_AmbientTemp,
                         MaxHeatingPerSec := simulate_TankTempSim_MaxHeatRate,
                         HeatLossCoeff := simulate_TankTempSim_HeatLostCoeff,
                         Execute := pulse_TimerOneSec,
                         Reset := simulate_SimReset);
    sensor_TankCurrentTemp := simulate_TankTempSim.SimulatedTemp;
END_IF

