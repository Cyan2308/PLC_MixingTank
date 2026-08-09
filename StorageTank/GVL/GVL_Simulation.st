VAR_GLOBAL
    (* Simulate *)
    simulate_SimMode : BOOL := TRUE;
    simulate_SimReset : BOOL := FALSE;

    // Tank level simulate
    simulate_LevelSim : FB_TankLevelSim;
    simulate_LevelSim_XOFillRate : REAL := 8.0;
    simulate_LevelSim_DischargeRate : REAL := 3.0;
    simulate_LevelSim_DrainRate : REAL := 15.0;
    simulate_LevelSim_InitialLevel : REAL := 0.0;

    // Tank temp simulate
    simulate_TempSim : FB_TankTempSim;
    simulate_TempSim_AmbientTemp : REAL := 26.0;
    simulate_TempSim_MaxHeatRate : REAL := 0.05;
    simulate_TempSim_HeatLossCoeff : REAL := 0.001;
END_VAR