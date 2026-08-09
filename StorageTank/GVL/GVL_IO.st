VAR_GLOBAL
    (* Sensor Inputs *)
    sensor_TankCurrentLevel : REAL;
    sensor_TankCurrentTemp : REAL;
    sensor_PackagingReady : BOOL := TRUE;

    (* Output Signals *)
    //
    output_XOValve : BOOL := FALSE;
    output_DischargeValve : BOOL := FALSE;
    output_Motor : BOOL := FALSE;
    output_DrainValve : BOOL := FALSE;
    output_SteamValve : REAL := 0.0;

    //
    output_Alarm : BOOL := FALSE;

    output_TankFull : BOOL := FALSE;
    output_TankReady : BOOL := FALSE;

    //
    string_Alarm : STRING := '';
    string_Normal : STRING := '';
END_VAR