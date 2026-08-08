RawTrig(CLK := IngredientTrigger);

IF Reset THEN
    SimulatedLevel := 0.0;
ELSE
    IF RawTrig.Q THEN
        SimulatedLevel := SimulatedLevel + IngredientAmount;
    END_IF

    IF Execute THEN
        dLevel := 0.0;

        IF OilPumpActive THEN
            dLevel := dLevel + OilFillRate;
        END_IF

        IF DrainValveActive THEN
            dLevel := dLevel - DrainRate;
        END_IF

        SimulatedLevel := SimulatedLevel + dLevel;
    END_IF

    IF SimulatedLevel < 0.0 THEN
        SimulatedLevel := 0.0;
    END_IF
END_IF