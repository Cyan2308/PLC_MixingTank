VAR_GLOBAL
    (* State Variables *)
    state_StateOfOp : INT := 0;

    state_IsPaused : BOOL := FALSE;
    state_MachineRunning : BOOL := FALSE; // If possible, merge with state_IsPaused
    state_EmergencyStop : BOOL := FALSE;
    state_Wait : BOOL := TRUE;
    state_EndCycle : BOOL := FALSE;
END_VAR