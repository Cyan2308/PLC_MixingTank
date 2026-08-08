VAR_GLOBAL
    (* Simulate *)
    // Init simulation
    simulate_SimMode : BOOL := TRUE;
    simulate_SimReset : BOOL := FALSE;

    // Tank level simulate
    simulate_TankLevelSim : FB_TankLevelSim;
    simulate_TankLevelSim_OilFillRate : REAL := 5.0;
    simulate_TankLevelSim_IngredientAmount : REAL := 60.0;
    simulate_TankLevelSim_DrainRate : REAL := 8.0;

    // Tank temp simulate
    simulate_TankTempSim : FB_TankTempSim;
    simulate_TankTempSim_AmbientTemp : REAL := 26.0;
    simulate_TankTempSim_MaxHeatRate : REAL := 0.05;
    simulate_TankTempSim_HeatLostCoeff : REAL := 0.001;
END_VAR