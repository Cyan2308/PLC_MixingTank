FUNCTION_BLOCK FB_TankLevelSim
VAR_INPUT
    XOValveActive : BOOL;
    DrainValveActive : BOOL;
    DischargeValveActive : BOOL;
 
 
    XOFillRate : REAL := 8.0;
    DrainRate : REAL := 15.0;
    DischargeRate : REAL := 3.0;
 
    Execute : BOOL;
    Reset : BOOL;
    InitialLevel : REAL := 0.0;
END_VAR

VAR_OUTPUT
    SimulatedLevel : REAL := 0.0;
END_VAR

VAR
    RawTrig : R_TRIG;
    dLevel : REAL;
END_VAR