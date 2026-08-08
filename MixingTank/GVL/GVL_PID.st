VAR_GLOBAL
    (* PID *)
    // Heating
    PID_Heating : FB_PID;
    PID_Heating_Kp : REAL := 5.0;
    PID_Heating_Ti : REAL := 120.0;
    PID_Heating_Td : REAL := 0.0;

    // Cooking
    PID_Cooking : FB_PID;
    PID_Cooking_Kp : REAL := 8.0;
    PID_Cooking_Ti : REAL := 60.0;
    PID_Cooking_Td : REAL := 5.0;

    //
    PID_Output : REAL := 0.0;
END_VAR