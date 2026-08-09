IF Reset THEN
    SimulatedLevel := InitialLevel;
ELSIF Execute THEN
    dLevel := 0.0;

    IF XOValveActive THEN
        dLevel := dLevel + XOFillRate;
    END_IF

    IF DischargeValveActive THEN
        dLevel := dLevel - DischargeRate;
    END_IF

    IF DrainValveActive THEN
        dLevel := dLevel - DrainRate;
    END_IF

    SimulatedLevel := SimulatedLevel + dLevel;

    IF SimulatedLevel < 0.0 THEN
        SimulatedLevel := 0.0;
    END_IF
END_IF