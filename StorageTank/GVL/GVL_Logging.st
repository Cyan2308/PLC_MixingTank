VAR_GLOBAL
    log_LevelHistory : ARRAY[0..23] OF REAL;
    log_LevelHistoryIndex : INT := 0;

    log_HourPulse : BOOL := FALSE;
    log_IntervalSet : TIME := T#1h;
END_VAR