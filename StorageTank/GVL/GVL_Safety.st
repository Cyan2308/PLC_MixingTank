VAR_GLOBAL
    safety_OverTempMargin : REAL := 15.0;
    safety_MinLevelForMotor : REAL := 10.0;
    safety_MinLevelForDischarge : REAL := 125.0;

    safety_TempSensorMin : REAL := -10.0;
    safety_TempSensorMax : REAL := 150.0;
    safety_LevelSensorMin : REAL := -5.0;
    safety_LevelSensorMax : REAL := 300.0;

    safety_FillTimeoutSet : TIME := T#20m;
    safety_HeatingTimeoutSet : TIME := T#30m;
    safety_ShutdownDrainTimeoutSet : TIME := T#10m;

    safety_AlarmOverTemp : BOOL := FALSE;
    safety_AlarmOverflow : BOOL := FALSE;
    safety_AlarmLowLevel : BOOL := FALSE;
    safety_AlarmTempSensorFault : BOOL := FALSE;
    safety_AlarmLevelSensorFault : BOOL := FALSE;
    safety_AlarmIngredientTimeout : BOOL := FALSE;
    safety_AlarmFillTimeout : BOOL := FALSE;
    safety_AlarmHeatingTimeout : BOOL := FALSE;
    safety_AlarmShutdownDrainTimeout : BOOL := FALSE;

    safety_AnyCriticalAlarm : BOOL := FALSE;
END_VAR