PROGRAM PLC_PRG
VAR
    (* Input Buttons *)
    button_Start : BOOL := FALSE;
    button_Stop : BOOL := FALSE;
    button_EmergencyStop : BOOL := FALSE;
    button_Reset : BOOL := FALSE;
    button_ConfirmIngredient : BOOL := FALSE;

    (* Timers *)
    timer_WaitTimeBetweenOp : TON;
    timer_DrainWaitTime: TON;

    //
    timer_TimeElapsed : TON;
    timer_TimeElapsed_Value : TIME := T#0s;

    //
    timer_State1Timeout : TON;
    timer_State4Timeout : TON;
    timer_State6Timeout : TON;
    timer_IngredientWaitTimeout : TON;

    (* Cycle *)
    cycle_SmallCycle : CTU;
    cycle_LargeCycle : CTU;
    cycle_SmallCycle_Value : WORD;
    cycle_LargeCycle_Value : WORD;
    cycle_LastCycleTimeElapsed : TIME := T#0s;

    (* Pulse *)
    pulse_Timer : TON;
    pulse_TimerOneSec : BOOL := FALSE;
    pulse_CookTimeElapsed : TIME := T#0s;
END_VAR