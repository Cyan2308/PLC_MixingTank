IF NOT Enable THEN
    Integral := 0.0;
    PrevError := 0.0;
    Out := 0.0;
    Error := 0.0;
ELSE
    Error := SetPoint - ProcessValue;
    
    IF Ti > 0.0 AND CycleTime > 0.0 THEN
        Integral := Integral + ((CycleTime * Error) / Ti);
    ELSE
        Integral := 0.0;
    END_IF

    IF CycleTime > 0.0 THEN
        Derivative := (Error - PrevError) / CycleTime * Td;
    ELSE
        Derivative := 0.0;
    END_IF

    RawOut := Kp * (Error + Integral + Derivative);

    IF RawOut > OutMax THEN
        Out := OutMax;
        IF Ti > 0.0  AND CycleTime > 0.0 THEN
            Integral := Integral - ((CycleTime * Error) / Ti);
        END_IF
    ELSIF RawOut < OutMin THEN
        Out := OutMin;
        IF Ti > 0.0 AND CycleTime > 0.0 THEN
            Integral := Integral - ((CycleTime * Error)/ Ti);
        END_IF
    ELSE
        Out := RawOut;
    END_IF
    PrevError := Error;
END_IF