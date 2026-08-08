VAR_GLOBAL
    safety_OverTempMargin : REAL := 15.0;
    safety_MaxTankLevel : REAL := 280.0;
    safety_MinLevelForMotor : REAL := 10.0;

    safety_TempSensorMin : REAL := -10.0;
    safety_TempSensorMax : REAL := 150.0;
    safety_LevelSensorMin : REAL := -5.0;
    safety_LevelSensorMax : REAL := 300.0;

    safety_State1TimeoutSet : TIME := T#10m;
    safety_State4TimeoutSet : TIME := T#30m;
    safety_State6TimeoutSet : TIME := T#5m;
    safety_IngredientWaitTimeoutSet : TIME := T#30m;

    safety_AlarmOverTemp : BOOL := FALSE;
    safety_AlarmOverflow : BOOL := FALSE;
    safety_AlarmTempSensorFault : BOOL := FALSE;
    safety_AlarmLevelSensorFault : BOOL := FALSE;
    safety_AlarmState1Timeout : BOOL := FALSE;
    safety_AlarmState4Timeout : BOOL := FALSE;
    safety_AlarmState6Timeout : BOOL := FALSE;
    safety_AlarmIngredientTimeout : BOOL := FALSE;

    safety_AnyCriticalAlarm : BOOL := FALSE;
END_VAR