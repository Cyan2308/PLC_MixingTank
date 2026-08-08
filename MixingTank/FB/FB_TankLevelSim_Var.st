FUNCTION_BLOCK FB_TankLevelSim
VAR_INPUT
    OilPumpActive : BOOL;
    IngredientTrigger : BOOL;
    DrainValveActive : BOOL;

    Execute : BOOL;
    Reset : BOOL;
    
    OilFillRate : REAL := 5.0;
    IngredientAmount : REAL := 50.0;
    DrainRate : REAL := 8.0;
END_VAR

VAR_OUTPUT
    SimulatedLevel : REAL := 0.0;
END_VAR

VAR
    RawTrig : R_TRIG;
    dLevel : REAL;
END_VAR