VAR_GLOBAL
    (* State Variables *)
    state_StateOfOp : INT := 0;

    state_IsPaused : BOOL := FALSE;
    state_MachineRunning : BOOL := FALSE;
    state_EmergencyStop : BOOL := FALSE;
    state_Wait : BOOL := TRUE;

    state_ShutdownRequested : BOOL := FALSE;
    state_AgitateActive : BOOL := FALSE;
END_VAR