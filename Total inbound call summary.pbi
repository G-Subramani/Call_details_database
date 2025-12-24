Month = 
FORMAT ('gold fact_call_summary'[full_date], "MMM-yy" )

Total Calls = 
CALCULATE (
    DISTINCTCOUNT( 'gold fact_call_summary'[call_key]),
    'gold fact_call_summary'[call_type] = "Inbound"
)

Answered Calls = 
CALCULATE (
    DISTINCTCOUNT( 'gold fact_call_summary'[call_key]),
    'gold fact_call_summary'[call_type] = "Inbound",
    'gold fact_call_summary'[answered_flag]= TRUE
)

Not Answered = 
[Total Calls]-[Answered Calls]

Answered % = 
FORMAT(DIVIDE ( [Answered Calls], [Total Calls], 0 )*100, "00")

Missed Reversion Calls = 
VAR MissedOnlyCallID =
    EXCEPT (
        CALCULATETABLE (
            VALUES ( 'gold fact_call_summary'[call_key] ),
            'gold fact_call_summary'[call_type] = "Inbound"
        ),
        CALCULATETABLE (
            VALUES ( 'gold fact_call_summary'[call_key] ),
            'gold fact_call_summary'[call_type] = "Inbound",
            'gold fact_call_summary'[answered_flag] = TRUE
        )
    )

VAR CallbackCallID =
    CALCULATETABLE (
        VALUES ( 'gold fact_call_summary'[call_key] ),
        'gold fact_call_summary'[same_day_callback_flag] = TRUE
            || 'gold fact_call_summary'[next_day_callback_flag] = TRUE
    )

RETURN
COUNTROWS (
    INTERSECT ( MissedOnlyCallID, CallbackCallID)
)


Missed Calls Reversion % = 
FORMAT(DIVIDE (
    [Missed Reversion Calls],
    [Not Answered],
    0
    )*100, 
"00")

Agents Count = 
CALCULATE (
    DISTINCTCOUNT ( 'gold fact_call_summary'[agent_key] ),
    'gold fact_call_summary'[call_type] = "Inbound",
    NOT ISBLANK ( 'gold fact_call_summary'[agent_key] )
)

Answered Avg Calls Per Agent = 
DIVIDE ( [Answered Calls], [Agents Count], 0 )

Answered Avg Calls Per Agent Day = 
DIVIDE (
    [Answered Avg Calls Per Agent],
    DISTINCTCOUNT ('gold fact_call_summary'[full_date]),
    0
)

Total Answered Calls = 
[Answered Calls]+[Missed Reversion Calls]
