VAR_GLOBAL
    (* Input Parameters *)
    input_SetMaxTankLevel : REAL := 1000.0;
    input_SetMinTankLevel : REAL := 125.0;
    input_SetFillLowLevel : REAL := 150.0;
    input_SetFillHighLevel : REAL := 900.0;
    input_SetTankTemp : REAL := 90.0;
    input_MotorSpeed : REAL := 20.0;
    input_SetDrainWaitTime : TIME := T#15s;
    input_SetWaitTimeBetweenOp : TIME := T#5s;
    input_ContinuousAgitation : BOOL := FALSE;
    input_SetAgitateInterval : TIME := T#10m;
    input_SetAgitateDuration : TIME := T#30s;
END_VAR