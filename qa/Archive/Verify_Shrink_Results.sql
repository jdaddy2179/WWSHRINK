-- =====================================================================
-- Verification Query: Proves Database Shrink Process Worked
-- =====================================================================
-- This query verifies the database shrinking operation completed successfully
-- by checking the run status, step completion, and data statistics.
-- =====================================================================

USE TempDB_WW;

PRINT '========================================';
PRINT 'SHRINK PROCESS VERIFICATION REPORT';
PRINT '========================================';

-- 1. Check the Most Recent Run Status
PRINT '';
PRINT '1. RECENT RUN STATUS:';
PRINT '----------------------------------------';
SELECT TOP 1
    RunId,
    RunDateTime,
    State = CASE 
        WHEN State = 1 THEN 'Running'
        WHEN State = 2 THEN 'Succeeded'
        WHEN State = 3 THEN 'Failed'
        ELSE 'Unknown'
    END,
    SelectorType,
    SelectorValues,
    DATEDIFF(SECOND, RunDateTime, EndedAt) AS ExecutionSeconds,
    EndedAt,
    LastCompletedOrdinal
FROM dbo.TrimShrink_Run
ORDER BY RunDateTime DESC;

-- 2. Check Pre-Step Execution
PRINT '';
PRINT '2. PRE-STEP EXECUTION:';
PRINT '----------------------------------------';
SELECT
    Ordinal,
    StepName,
    ExecutionSeconds,
    ExecutedAt,
    CompletedAt
FROM dbo.TrimShrink_RunStepLog
WHERE RunId = (SELECT TOP 1 RunId FROM dbo.TrimShrink_Run ORDER BY RunDateTime DESC)
  AND Ordinal < 3
ORDER BY Ordinal;

-- 3. Check Step Log Summary (Numbered Steps)
PRINT '';
PRINT '3. NUMBERED STEPS SUMMARY:';
PRINT '----------------------------------------';
SELECT
    TotalStepsExecuted = COUNT(*),
    NumberedStepsExecuted = SUM(CASE WHEN Ordinal >= 3 AND Ordinal <= 92 THEN 1 ELSE 0 END),
    AverageExecutionSeconds = AVG(ExecutionSeconds),
    MinExecutionSeconds = MIN(ExecutionSeconds),
    MaxExecutionSeconds = MAX(ExecutionSeconds),
    TotalExecutionSeconds = SUM(ExecutionSeconds)
FROM dbo.TrimShrink_RunStepLog
WHERE RunId = (SELECT TOP 1 RunId FROM dbo.TrimShrink_Run ORDER BY RunDateTime DESC);

-- 4. Step Execution Details (Sample - First 10 Steps)
PRINT '';
PRINT '4. STEP EXECUTION DETAILS (First 10 Numbered Steps):';
PRINT '----------------------------------------';
SELECT TOP 10
    Ordinal,
    StepName,
    ExecutionSeconds,
    ExecutedAt,
    CompletedAt
FROM dbo.TrimShrink_RunStepLog
WHERE RunId = (SELECT TOP 1 RunId FROM dbo.TrimShrink_Run ORDER BY RunDateTime DESC)
  AND Ordinal >= 3
ORDER BY Ordinal;

-- 5. Check for Any Failed Steps
PRINT '';
PRINT '5. FAILED STEPS CHECK:';
PRINT '----------------------------------------';
SELECT
    FailedStepCount = COUNT(*)
FROM dbo.TrimShrink_RunStepLog
WHERE RunId = (SELECT TOP 1 RunId FROM dbo.TrimShrink_Run ORDER BY RunDateTime DESC)
  AND ErrorText IS NOT NULL
  AND ErrorText <> '';

-- 6. Configuration Used for This Run
PRINT '';
PRINT '6. CONFIGURATION USED:';
PRINT '----------------------------------------';
SELECT TOP 1
    SelectorType,
    SelectorValues,
    SourceDb,
    WindwardDbName,
    TempDbName
FROM dbo.TrimShrink_Run
ORDER BY RunDateTime DESC;

-- =====================================================================
-- Database File Size Information (Windward Database)
-- =====================================================================
USE Windward_Commercial_SunLife;

PRINT '';
PRINT '========================================';
PRINT 'DATABASE FILE SIZE INFORMATION';
PRINT '========================================';
PRINT '';

SELECT
    [File_Name] = name,
    [Type] = CASE type_desc
        WHEN 'ROWS' THEN 'Data File'
        WHEN 'LOG' THEN 'Log File'
        ELSE type_desc
    END,
    [Size_MB] = CAST((size * 8.0 / 1024) AS DECIMAL(10, 2)),
    [Max_Size_MB] = CASE
        WHEN max_size = -1 THEN NULL
        ELSE CAST((max_size * 8.0 / 1024) AS DECIMAL(10, 2))
    END,
    [Growth_MB] = CASE growth_unit_of_measure
        WHEN 'KB' THEN CAST((growth * 8.0 / 1024) AS DECIMAL(10, 2))
        WHEN 'PERCENT' THEN growth
        ELSE 0
    END,
    [File_Path] = physical_name
FROM sys.database_files
ORDER BY file_id;

-- =====================================================================
-- Record Counts by Category (Sample Tables for Verification)
-- =====================================================================

PRINT '';
PRINT '========================================';
PRINT 'TRIMMED DATA RECORD COUNTS';
PRINT '========================================';
PRINT '';

PRINT 'Case-Related Tables:';
SELECT
    'Case_Details' AS Tbl,
    COUNT(*) AS Rows
FROM dbo.Case_Details
UNION ALL
SELECT 'Case_Associated_Claims', COUNT(*) FROM dbo.Case_Associated_Claims
UNION ALL
SELECT 'Case_Associated_Members', COUNT(*) FROM dbo.Case_Associated_Members
UNION ALL
SELECT 'Case_Associated_Providers', COUNT(*) FROM dbo.Case_Associated_Providers
ORDER BY Tbl;

PRINT '';
PRINT 'Claims-Related Tables:';
SELECT TOP 5
    'Claims_Current_Version' AS Tbl,
    COUNT(*) AS Rows
FROM dbo.Claims_Current_Version
UNION ALL
SELECT 'Claims_Header_Log', COUNT(*) FROM dbo.Claims_Header_Log
UNION ALL
SELECT 'Claims_Detail_Log', COUNT(*) FROM dbo.Claims_Detail_Log
ORDER BY Tbl;

PRINT '';
PRINT 'Member-Related Tables:';
SELECT
    'Member_ID' AS Tbl,
    COUNT(*) AS Rows
FROM dbo.Member_ID
UNION ALL
SELECT 'Subscriber_Coverage', COUNT(*) FROM dbo.Subscriber_Coverage
UNION ALL
SELECT 'Member_Coverage', COUNT(*) FROM dbo.Member_Coverage
UNION ALL
SELECT 'Address', COUNT(*) FROM dbo.Address
ORDER BY Tbl;

PRINT '';
PRINT '========================================';
PRINT 'VERIFICATION COMPLETE';
PRINT '========================================';
