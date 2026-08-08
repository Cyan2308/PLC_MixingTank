IF Reset THEN
    SimulatedTemp := AmbientTemp;
ELSIF Execute THEN
    dTemp := (SteamValveInput / 100.0) * MaxHeatingPerSec - HeatLostCoeff * (SimulatedTemp - AmbientTemp);
    SimulatedTemp := SimulatedTemp + dTemp;
END_IF