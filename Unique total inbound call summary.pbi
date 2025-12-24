Month = 
FORMAT ('gold fact_call_summary'[full_date], "MMM-yy" )

Unique Total Calls = CALCULATE(
DISTINCTCOUNT ('gold fact_call_summary'[caller_key]),
'gold fact_call_summary'[call_type] = "Inbound")

Unique Answered Calls = 
CALCULATE (
    DISTINCTCOUNT ('gold fact_call_summary'[caller_key]),
    'gold fact_call_summary'[call_type] = "Inbound",
    'gold fact_call_summary'[answered_flag] = TRUE
)

Unique Not Answered Calls = 
VAR TotalCallers =
    CALCULATETABLE (
        VALUES ( 'gold fact_call_summary'[caller_key] ),
        'gold fact_call_summary'[call_type] = "Inbound"
    )

VAR AnsweredCallers =
    CALCULATETABLE (
        VALUES ( 'gold fact_call_summary'[caller_key] ),
        'gold fact_call_summary'[call_type] = "Inbound",
        'gold fact_call_summary'[answered_flag] = TRUE
    )

RETURN
COUNTROWS (
    EXCEPT ( TotalCallers, AnsweredCallers )
)

Unique Answered % = FORMAT(
DIVIDE ( [Unique Answered Calls], [Unique Total Calls], 0 )*100, "00")

Unique Missed Reversion Calls = 
VAR MissedOnlyCallers =
    EXCEPT (
        CALCULATETABLE (
            VALUES ( 'gold fact_call_summary'[caller_key] ),
            'gold fact_call_summary'[call_type] = "Inbound"
        ),
        CALCULATETABLE (
            VALUES ( 'gold fact_call_summary'[caller_key] ),
            'gold fact_call_summary'[call_type] = "Inbound",
            'gold fact_call_summary'[answered_flag] = TRUE
        )
    )

VAR CallbackCallers =
    CALCULATETABLE (
        VALUES ( 'gold fact_call_summary'[caller_key] ),
        'gold fact_call_summary'[same_day_callback_flag] = TRUE
            || 'gold fact_call_summary'[next_day_callback_flag] = TRUE
    )

RETURN
COUNTROWS (
    INTERSECT ( MissedOnlyCallers, CallbackCallers )
)

Unique Missed Calls Reversion % = 
FORMAT(DIVIDE (
    [Unique Missed Reversion Calls],
    [Unique Not Answered Calls],
    0
)*100, "00")
