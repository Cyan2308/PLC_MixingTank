FUNCTION_BLOCK FB_PID
VAR_INPUT
    SetPoint : REAL;
    ProcessValue : REAL;
    Kp : REAL;
    Ti : REAL;
    Td : REAL;
    CycleTime : REAL;
    Enable : BOOL;
    OutMin : REAL := 0.0;
    OutMax : REAL := 100.0;
END_VAR

VAR_OUTPUT
    Out : REAL;
    Error : REAL;
END_VAR

VAR
    PrevError : REAL;
    Integral : REAL;
    Derivative : REAL;
    RawOut : REAL;
END_VAR