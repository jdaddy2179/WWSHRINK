-- WW DataShrink — KCL CONFIG FULL TABLE-LEVEL ANALYSIS (source vs target)
-- =================================================================
-- Purpose : Show EVERY table touched by the datashrink / data-load process,
--           with per-table row-count and size impact (source vs target).
--           "Touched" is defined two ways and both are reported:
--             * EMPIRICAL (sections 3-5): row count differs source vs target.
--             * BY DATASHRINK (sections 6-8): the TrimShrink process logged a
--               step against the table — the authoritative record of what the
--               shrink acted on. Section 8 reconciles the two.
--           Complements the member-level reconciliation
--           (WWShrink_KCL_SourceTarget_Reconciliation.sql) — this is the
--           breadth view across all tables; that is the depth view on members.
--           Supports TC-P4-04 (data integrity) and TC-P4-05 (size reduction).
--
-- Server      : AWWW2SQLKCL01D
-- Source DB   : Windward_Config        (full config DB, all clients)
-- Target DB   : Windward_Config_KCL    (shrunk config DB — KCL data only)
-- Environment : Non-PHI test data. Read-only / least-privilege creds recommended.
--
-- METHOD : Metadata only (sys.partitions / sys.allocation_units via three-part
--          naming). No COUNT(*), no table scans, no locks — safe on large DBs.
--          row_count = sys.partitions.rows for the heap/clustered index (0,1);
--          size = total_pages across all allocation units (data + indexes + LOB).
--          Tables are matched source<->target by schema + table name (object_ids
--          differ between databases).
-- =================================================================

set nocount on;

-- -----------------------------------------------------------------
-- 1) SOURCE table inventory — Windward_Config
-- -----------------------------------------------------------------
drop table if exists #src_tbl;

;with src_rows as (
    select object_id, sum(rows) as row_count
    from [Windward_Config].sys.partitions
    where index_id in (0,1)              -- heap (0) or clustered index (1)
    group by object_id
),
src_size as (
    select p.object_id, sum(a.total_pages) as total_pages
    from [Windward_Config].sys.partitions p
    join [Windward_Config].sys.allocation_units a on a.container_id = p.partition_id
    group by p.object_id
)
select sch.name as schema_name,
       t.name   as table_name,
       isnull(r.row_count, 0)                                   as row_count,
       cast(isnull(sz.total_pages, 0) * 8 / 1024.0 as decimal(18,2)) as reserved_mb
into #src_tbl
from [Windward_Config].sys.tables t
join [Windward_Config].sys.schemas sch on sch.schema_id = t.schema_id
left join src_rows r  on r.object_id  = t.object_id
left join src_size sz on sz.object_id = t.object_id
where t.is_ms_shipped = 0;

-- -----------------------------------------------------------------
-- 2) TARGET table inventory — Windward_Config_KCL
-- -----------------------------------------------------------------
drop table if exists #tgt_tbl;

;with tgt_rows as (
    select object_id, sum(rows) as row_count
    from [Windward_Config_KCL].sys.partitions
    where index_id in (0,1)
    group by object_id
),
tgt_size as (
    select p.object_id, sum(a.total_pages) as total_pages
    from [Windward_Config_KCL].sys.partitions p
    join [Windward_Config_KCL].sys.allocation_units a on a.container_id = p.partition_id
    group by p.object_id
)
select sch.name as schema_name,
       t.name   as table_name,
       isnull(r.row_count, 0)                                   as row_count,
       cast(isnull(sz.total_pages, 0) * 8 / 1024.0 as decimal(18,2)) as reserved_mb
into #tgt_tbl
from [Windward_Config_KCL].sys.tables t
join [Windward_Config_KCL].sys.schemas sch on sch.schema_id = t.schema_id
left join tgt_rows r  on r.object_id  = t.object_id
left join tgt_size sz on sz.object_id = t.object_id
where t.is_ms_shipped = 0;

-- -----------------------------------------------------------------
-- 3) PER-TABLE COMPARISON — full outer join, every table classified
--    status:
--      UNCHANGED      row counts equal (load did not touch this table)
--      TRIMMED        target < source (rows removed by the shrink)
--      EMPTIED        target = 0 while source > 0 (whole table cleared)
--      SOURCE_ONLY    table missing in target (dropped by the shrink)
--      TARGET_ONLY    table missing in source (created in target)
--      GREW (!)       target > source (unexpected — investigate)
-- -----------------------------------------------------------------
select
    schema_name     = isnull(s.schema_name, t.schema_name),
    table_name      = isnull(s.table_name,  t.table_name),
    config_rows = isnull(s.row_count, 0),
    kcl_config_rows        = isnull(t.row_count, 0),
    rows_removed    = isnull(s.row_count, 0) - isnull(t.row_count, 0),
    pct_retained    = case when isnull(s.row_count,0) = 0 then null
                           else cast(isnull(t.row_count,0) * 100.0 / s.row_count as decimal(6,2)) end,
    config_mb   = isnull(s.reserved_mb, 0),
    kcl_config_mb          = isnull(t.reserved_mb, 0),
    mb_reclaimed    = isnull(s.reserved_mb, 0) - isnull(t.reserved_mb, 0),
    status = case
                when s.table_name is null then 'TARGET_ONLY'
                when t.table_name is null then 'SOURCE_ONLY (dropped)'
                when isnull(t.row_count,0) = isnull(s.row_count,0) then 'UNCHANGED'
                when isnull(t.row_count,0) = 0 and isnull(s.row_count,0) > 0 then 'EMPTIED'
                when isnull(t.row_count,0) < isnull(s.row_count,0) then 'TRIMMED'
                else 'GREW (!)' end
from #src_tbl s
full outer join #tgt_tbl t on t.schema_name = s.schema_name and t.table_name = s.table_name
order by rows_removed desc, schema_name, table_name;

-- -----------------------------------------------------------------
-- 4) TOUCHED-ONLY view — just the tables the load process changed
--    (drops UNCHANGED so you see only what the shrink acted on)
-- -----------------------------------------------------------------
select
    schema_name     = isnull(s.schema_name, t.schema_name),
    table_name      = isnull(s.table_name,  t.table_name),
    config_rows = isnull(s.row_count, 0),
    kcl_config_rows        = isnull(t.row_count, 0),
    rows_removed    = isnull(s.row_count, 0) - isnull(t.row_count, 0),
    pct_retained    = case when isnull(s.row_count,0) = 0 then null
                           else cast(isnull(t.row_count,0) * 100.0 / s.row_count as decimal(6,2)) end,
    status = case
                when s.table_name is null then 'TARGET_ONLY'
                when t.table_name is null then 'SOURCE_ONLY (dropped)'
                when isnull(t.row_count,0) = 0 and isnull(s.row_count,0) > 0 then 'EMPTIED'
                when isnull(t.row_count,0) < isnull(s.row_count,0) then 'TRIMMED'
                else 'GREW (!)' end
from #src_tbl s
full outer join #tgt_tbl t on t.schema_name = s.schema_name and t.table_name = s.table_name
where isnull(s.row_count,0) <> isnull(t.row_count,0)
   or s.table_name is null
   or t.table_name is null
order by rows_removed desc, schema_name, table_name;

-- -----------------------------------------------------------------
-- 5) SUMMARY — one-row roll-up of the whole load
-- -----------------------------------------------------------------
select
    source_tables          = (select count(*) from #src_tbl),
    target_tables          = (select count(*) from #tgt_tbl),
    tables_touched         = (select count(*) from #src_tbl s
                              full outer join #tgt_tbl t on t.schema_name=s.schema_name and t.table_name=s.table_name
                              where isnull(s.row_count,0) <> isnull(t.row_count,0)
                                 or s.table_name is null or t.table_name is null),
    tables_dropped         = (select count(*) from #src_tbl s
                              left join #tgt_tbl t on t.schema_name=s.schema_name and t.table_name=s.table_name
                              where t.table_name is null),
    source_total_rows      = (select sum(cast(row_count as bigint)) from #src_tbl),
    target_total_rows      = (select sum(cast(row_count as bigint)) from #tgt_tbl),
    source_total_mb        = (select cast(sum(reserved_mb) as decimal(18,2)) from #src_tbl),
    target_total_mb        = (select cast(sum(reserved_mb) as decimal(18,2)) from #tgt_tbl),
    overall_pct_retained   = cast(
                                (select sum(cast(row_count as bigint)) from #tgt_tbl) * 100.0
                                / nullif((select sum(cast(row_count as bigint)) from #src_tbl),0)
                              as decimal(6,2));

-- =================================================================
-- BY DATASHRINK — drive the analysis from the TrimShrink step log
-- =================================================================
-- The sections above define "touched" empirically (row count changed). The
-- sections below define it authoritatively: a table is touched because the
-- datashrink process logged a STEP against it. We then attach the source/target
-- row-count impact to each datashrink step, and reconcile the two views.
--
-- Adjust [TempDB_WW] if the KCL run used a different working DB — the value is
-- in TrimShrink_Run.TempDbName. The latest run is max(RunId). The step-to-table
-- match looks for the table name inside StepName + ScriptFile; if your naming
-- differs, tweak the match_text / CHARINDEX predicate. Short table names can match
-- as substrings of longer ones (e.g. 'Address' in 'Member_Address') — a step may
-- then show several candidate tables; treat section 7 matches as best-effort.
-- -----------------------------------------------------------------

-- 5b) LATEST DATASHRINK RUN — context/config (real TrimShrink_Run columns)
select top 1
       RunId,
       run_state = case State when 1 then 'Running' when 2 then 'Succeeded'
                              when 3 then 'Failed' else cast(State as varchar(10)) end,
       StartedAt, EndedAt,
       duration_sec = cast(datediff(second, StartedAt, EndedAt) as bigint),
       RequestedBy, SourceServer, SourceDb, TempDbServer, TempDbName,
       SelectorType, SelectorValues, LastCompletedOrdinal, LastErrorText
from [TempDB_WW].dbo.TrimShrink_Run
order by RunId desc;

-- 6) Pull the latest datashrink run's step log (latest run = max RunId)
drop table if exists #shrink_steps;

select rsl.Ordinal,
       rsl.ScriptFile,
       rsl.StepName,
       rsl.TargetDb,
       rsl.Status,
       duration_sec = cast(rsl.DurationMs / 1000.0 as decimal(18,2)),
       rsl.StartedAt,
       rsl.EndedAt,
       error_flag = case when rsl.ErrorText is not null and rsl.ErrorText <> '' then 1 else 0 end,
       match_text = isnull(rsl.StepName, '') + ' ' + isnull(rsl.ScriptFile, '')
into #shrink_steps
from [TempDB_WW].dbo.TrimShrink_RunStepLog rsl
where rsl.RunId = (select max(RunId) from [TempDB_WW].dbo.TrimShrink_Run);

-- 7) DATASHRINK-DRIVEN — each step (matched to its table) + row impact
--    One row per (datashrink step, matched table). Steps that match no table and
--    tables changed without a step both surface in section 8.
select
    st.Ordinal,
    st.ScriptFile,
    st.StepName,
    st.TargetDb,
    st.Status,
    matched_schema  = isnull(s.schema_name, t.schema_name),
    matched_table   = isnull(s.table_name,  t.table_name),
    config_rows = isnull(s.row_count, 0),
    kcl_config_rows        = isnull(t.row_count, 0),
    rows_removed    = isnull(s.row_count, 0) - isnull(t.row_count, 0),
    pct_retained    = case when isnull(s.row_count,0) = 0 then null
                           else cast(isnull(t.row_count,0) * 100.0 / s.row_count as decimal(6,2)) end,
    st.duration_sec,
    step_errored    = st.error_flag
from #shrink_steps st
left join #src_tbl s on charindex(s.table_name, st.match_text) > 0
left join #tgt_tbl t on t.schema_name = s.schema_name and t.table_name = s.table_name
order by st.Ordinal;

-- 8) RECONCILE the two definitions of "touched"
--    A: datashrink steps that matched NO table (naming mismatch — review match rule)
--    B: tables whose rows changed but NO datashrink step references them (unexpected)
select 'A: step with no matched table' as finding, st.Ordinal, st.StepName, st.ScriptFile,
       null as schema_name, null as table_name
from #shrink_steps st
where not exists (select 1 from #src_tbl s where charindex(s.table_name, st.match_text) > 0)
  and not exists (select 1 from #tgt_tbl t where charindex(t.table_name, st.match_text) > 0)
union all
select 'B: table changed, no datashrink step', null, null, null,
       isnull(s.schema_name, t.schema_name), isnull(s.table_name, t.table_name)
from #src_tbl s
full outer join #tgt_tbl t on t.schema_name = s.schema_name and t.table_name = s.table_name
where (isnull(s.row_count,0) <> isnull(t.row_count,0) or s.table_name is null or t.table_name is null)
  and not exists (select 1 from #shrink_steps st
                  where charindex(isnull(s.table_name, t.table_name), st.match_text) > 0)
order by finding, table_name;

drop table if exists #src_tbl;
drop table if exists #tgt_tbl;
drop table if exists #shrink_steps;
