VAR_GLOBAL
    (* Sensor Inputs *)
    sensor_TankCurrentLevel : REAL;
    sensor_TankCurrentTemp : REAL;

    (* Output Signals *)
    //
    output_OilPump : BOOL := FALSE;
    output_Motor : BOOL := FALSE;
    output_DrainValve : BOOL := FALSE;
    output_SteamValve : REAL := 0.0;

    //
    output_Alarm : BOOL := FALSE;

    //
    string_Alarm : STRING := '';
    string_Normal : STRING := '';
END_VAR