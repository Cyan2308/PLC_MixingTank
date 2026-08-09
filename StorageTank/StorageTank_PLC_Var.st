PROGRAM PLC_PRG
VAR
    (* Input Buttons *)
    button_Start : BOOL := FALSE;
    button_Stop : BOOL := FALSE;
    button_EmergencyStop : BOOL := FALSE;
    button_Reset : BOOL := FALSE;
    button_Shutdown : BOOL := FALSE;

    (* Timers *)
    timer_WaitTimeBetweenOp : TON;
    timer_DrainWaitTime : TON;
    timer_TimeElapsed : TON;
    timer_TimeElapsed_Value : TIME := T#0s;

    timer_FillTimeout : TON;
    timer_HeatingTimeout : TON;
    timer_ShutdownDrainTimeout : TON;

    timer_AgitateInterval : TON;
    timer_AgitateDuration : TON;

    timer_HourPulse : TON;

    (* Pulse *)
    pulse_Timer : TON;
    pulse_TimerOneSec : BOOL := FALSE;

    (* Log *)
    log_ClearIndex : INT;
END_VAR