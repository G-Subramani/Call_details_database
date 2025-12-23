/*
===============================================================================
DDL Script : Create Bronze Tables (Call Events)
Schema     : bronze
Database   : PostgreSQL
===============================================================================
Script Purpose:
    This script creates Bronze layer tables for Call Events data.

Design Principles:
    - Bronze is RAW and IMMUTABLE
    - Incremental loads only (append history)
    - Deduplication enforced via unique index
    - Staging table is reloadable
    - Supports Medallion Architecture

Re-runnable:
    YES (uses IF NOT EXISTS / DROP + CREATE pattern where needed)

===============================================================================
*/

-- ============================================================================
-- Schema
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS bronze;

-- ============================================================================
-- Final Bronze Table (HISTORICAL / INCREMENTAL)
-- ============================================================================
DROP TABLE IF EXISTS bronze.bronze_call_events CASCADE;

CREATE TABLE bronze.bronze_call_events (

    -- Surrogate Key
    bronze_id BIGSERIAL PRIMARY KEY,

    -- Business Keys
    ucid TEXT,
    caller_no TEXT,
    call_date DATE,
    start_time TEXT,

    -- Call Attributes
    call_id TEXT,
    call_type TEXT,
    campaign TEXT,
    skill TEXT,
    location_ TEXT,
    caller_e164 TEXT,
    queue_time TEXT,
    pickup_time TEXT,
    time_to_answer TEXT,
    hold_time TEXT,
    end_time TEXT,
    talk_time TEXT,
    duration TEXT,
    call_event TEXT,
    dialed_number TEXT,
    agent TEXT,
    status TEXT,
    dial_status TEXT,
    customer_dial_status TEXT,
    agent_dial_status TEXT,
    wrapup_start_time TEXT,
    wrapup_end_time TEXT,
    disposition TEXT,
    dialout_name TEXT,
    transfer_type TEXT,
    transferred_to TEXT,
    hangup_by TEXT,
    uui TEXT,
    comments_ TEXT,
    customer_ring_time TEXT,
    recording_url TEXT,
    agent_id TEXT,
    ratings TEXT,
    rating_comments TEXT,
    dynamic_did TEXT,
    did TEXT,

    -- Metadata (Bronze Control)
    ingestion_ts TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
    source_file_name TEXT NOT NULL
);

-- ============================================================================
-- Deduplication / Safety Net (Incremental Load Support)
-- ============================================================================
CREATE UNIQUE INDEX ux_bronze_call_events_nodup
ON bronze.bronze_call_events (
    ucid,
    caller_no,
    call_date,
    start_time
);

-- ============================================================================
-- Staging Table (Transient / Reloadable)
-- ============================================================================
DROP TABLE IF EXISTS bronze.bronze_call_events_stg;

CREATE TABLE bronze.bronze_call_events_stg (

    ucid TEXT,
    call_id TEXT,
    call_type TEXT,
    campaign TEXT,
    skill TEXT,
    location_ TEXT,
    caller_no TEXT,
    caller_e164 TEXT,
    call_date DATE,
    queue_time TEXT,
    start_time TEXT,
    pickup_time TEXT,
    time_to_answer TEXT,
    hold_time TEXT,
    end_time TEXT,
    talk_time TEXT,
    duration TEXT,
    call_event TEXT,
    dialed_number TEXT,
    agent TEXT,
    status TEXT,
    dial_status TEXT,
    customer_dial_status TEXT,
    agent_dial_status TEXT,
    wrapup_start_time TEXT,
    wrapup_end_time TEXT,
    disposition TEXT,
    dialout_name TEXT,
    transfer_type TEXT,
    transferred_to TEXT,
    hangup_by TEXT,
    uui TEXT,
    comments_ TEXT,
    customer_ring_time TEXT,
    recording_url TEXT,
    agent_id TEXT,
    ratings TEXT,
    rating_comments TEXT,
    dynamic_did TEXT,
    did TEXT
);

-- ============================================================================
-- Validation
-- ============================================================================
-- Current database
SELECT current_database();

-- Sample data check
SELECT *
FROM bronze.bronze_call_events
LIMIT 10;
