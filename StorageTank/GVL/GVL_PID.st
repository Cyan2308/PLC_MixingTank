VAR_GLOBAL
    (* PID *)
    // Heating
    PID_Heating : FB_PID;
    PID_Heating_Kp : REAL := 5.0;
    PID_Heating_Ti : REAL := 120.0;
    PID_Heating_Td : REAL := 0.0;

    // Holding
    PID_Holding : FB_PID;
    PID_Holding_Kp : REAL := 3.0;
    PID_Holding_Ti : REAL := 180.0;
    PID_Holding_Td : REAL := 10.0;
    
    //
    PID_Output : REAL := 0.0;
END_VAR