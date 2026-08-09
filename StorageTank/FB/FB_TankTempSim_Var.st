FUNCTION_BLOCK FB_TankTempSim
VAR_INPUT
    SteamValveInput : REAL;

    Execute : BOOL;
    Reset : BOOL;
    
    MaxHeatingPerSec : REAL := 0.05;
    AmbientTemp : REAL := 25.0;
    HeatLossCoeff : REAL := 0.001;
END_VAR

VAR_OUTPUT
    SimulatedTemp : REAL := 25.0;
END_VAR

VAR
    dTemp : REAL;
END_VAR