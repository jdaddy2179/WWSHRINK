-- WW DataShrink — KCL Source-vs-Target member RECONCILIATION
-- =================================================================
-- Purpose : Validate the WW Shrink preserved every KCL member — the KCL
--           member set derived from the FULL source DB must equal the member
--           set in the SHRUNK single-client DB. This is the data-integrity
--           check behind TC-P4-04 (Phase 4 — WW Shrink for WW1.0 & Config).
--
-- Server      : AWWW2SQLKCL01D   (both DBs live on this instance)
-- Source DB   : windward_commercial   (full commercial DB, all clients)
-- Target DB   : windward_KCL          (shrunk DB — KCL data only)
-- Environment : Non-PHI test data. Run from a host with network access to the
--               instance; read-only / least-privilege credentials recommended.
-- SME         : AJ Schmucker (alan.schmucker@greatdentalplans.com)
-- Owners      : SQA validation (Joshua Ernstoff, Keerthan Tumuganti)
--
-- HOW IT WORKS
--   Section 0 derives the KCL PURCHASER SET once from windward_commercial (the
--   canonical client definition, contract_class_code IN ('055001','055002') +
--   currently-effective Contract_Relation). The same member query — filtered to
--   that purchaser set — is then run against BOTH databases via three-part
--   naming, so no USE / batch-switch is needed and both sides use an identical
--   purchaser scope.
--
--   TOTAL vs ACTIVE in ONE run: instead of toggling the termination_date filter,
--   each member is captured with an is_active flag (1 = has at least one member-
--   coverage row with termination_date >= getdate()). Section 3 then reports BOTH
--   the TOTAL and ACTIVE reconciliation in a single result set.
--
--   The shrink PASSES (per scope) only when:
--      (a) source count == target count, AND
--      (b) the member sets are identical (zero rows lost and zero extra).
--   Count parity alone can hide a swap (one lost member + one extra) — the
--   set-level diff (sections 4-6) is what makes this a real reconciliation.
-- =================================================================

set nocount on;

-- -----------------------------------------------------------------
-- 0) SCOPE — the KCL purchaser set (the canonical client definition)
--    Derived ONCE from the full source DB (windward_commercial) and then
--    applied to BOTH databases below, so the comparison is driven by the same
--    purchaser list rather than re-deriving scope independently in each DB.
--    See KCL_Purchasers_discovery.sql for the standalone list.
-- -----------------------------------------------------------------
drop table if exists #kcl_purchasers;

SELECT distinct p.purchaser_id, p.Purchaser_PKID
into #kcl_purchasers
from [windward_commercial].[dbo].[Contracts] c
join [windward_commercial].[dbo].[Contract_Relation] cr on cr.[contract_gid] = c.[contract_gid]
                                 and cr.effective_date <= getdate()
                                 and cr.termination_date >= getdate()
                                 and cr.record_status = 'A'
join [windward_commercial].[dbo].[sub_group] sg on sg.sub_group_gid = cr.[entity_gid]
                         and sg.sub_group_status = '01'
                         and sg.record_status = 'A'
join [windward_commercial].[dbo].[Sub_Group_Coverage] sgc ON sgc.[Sub_Group_PKID] = sg.[Sub_Group_PKID] AND sgc.[record_status] = 'A'
join [windward_commercial].[dbo].[Parent_Group_Coverage] pgc ON sgc.[Parent_Group_Coverage_PKID] = pgc.[Parent_Group_Coverage_PKID] AND pgc.[record_status] = 'A'
join [windward_commercial].[dbo].[parent_group] pg ON pgc.[parent_group_pkid] = pg.[parent_group_pkid] and pg.[record_status] = 'A'
join [windward_commercial].[dbo].[Purchaser_Coverage] pc ON pgc.[Purchaser_Coverage_PKID] = pc.[Purchaser_Coverage_PKID] and pc.[record_status] = 'A'
join [windward_commercial].[dbo].[Purchaser] p ON pc.[Purchaser_PKID] = p.[Purchaser_PKID] AND p.[record_status] = 'A'
join [windward_commercial].[dbo].[Subscriber_Coverage] sc ON sc.[Sub_Group_PKID] = sg.[Sub_Group_PKID]
                                   AND sc.[record_status] = 'A'
join [windward_commercial].[dbo].[member_coverage] mc on mc.[Subscriber_Coverage_PKID] = sc.[Subscriber_Coverage_PKID]
                               and mc.record_status = 'A'
where c.[contract_class_code] IN ('055001','055002')
  and c.record_status = 'A';

-- Show the purchaser scope being reconciled (audit evidence for the run)
select purchaser_id, Purchaser_PKID from #kcl_purchasers order by 1;

-- -----------------------------------------------------------------
-- 1) SOURCE — KCL members in windward_commercial (scoped to KCL purchasers)
--    is_active = 1 if the member has any currently-effective member_coverage row.
-- -----------------------------------------------------------------
drop table if exists #src_members;

SELECT mc.contact_relation_gid,
       max(case when mc.termination_date >= getdate() then 1 else 0 end) as is_active
into #src_members
from [windward_commercial].[dbo].[Contracts] c
join [windward_commercial].[dbo].[Contract_Relation] cr on cr.[contract_gid] = c.[contract_gid]
                                 and cr.effective_date <= getdate()
                                 and cr.termination_date >= getdate()
                                 and cr.record_status = 'A'
join [windward_commercial].[dbo].[sub_group] sg on sg.sub_group_gid = cr.[entity_gid]
                         and sg.sub_group_status = '01'
                         and sg.record_status = 'A'
join [windward_commercial].[dbo].[Sub_Group_Coverage] sgc ON sgc.[Sub_Group_PKID] = sg.[Sub_Group_PKID] AND sgc.[record_status] = 'A'
join [windward_commercial].[dbo].[Parent_Group_Coverage] pgc ON sgc.[Parent_Group_Coverage_PKID] = pgc.[Parent_Group_Coverage_PKID] AND pgc.[record_status] = 'A'
join [windward_commercial].[dbo].[parent_group] pg ON pgc.[parent_group_pkid] = pg.[parent_group_pkid] and pg.[record_status] = 'A'
join [windward_commercial].[dbo].[Purchaser_Coverage] pc ON pgc.[Purchaser_Coverage_PKID] = pc.[Purchaser_Coverage_PKID] and pc.[record_status] = 'A'
join [windward_commercial].[dbo].[Purchaser] p ON pc.[Purchaser_PKID] = p.[Purchaser_PKID] AND p.[record_status] = 'A'
join [windward_commercial].[dbo].[Subscriber_Coverage] sc ON sc.[Sub_Group_PKID] = sg.[Sub_Group_PKID]
                                   AND sc.[record_status] = 'A'
join [windward_commercial].[dbo].[member_coverage] mc on mc.[Subscriber_Coverage_PKID] = sc.[Subscriber_Coverage_PKID]
                               and mc.record_status = 'A'
where c.[contract_class_code] IN ('055001','055002')
  and c.record_status = 'A'
  and p.[Purchaser_PKID] in (select Purchaser_PKID from #kcl_purchasers)   -- filter to the KCL purchaser set
group by mc.contact_relation_gid;

-- -----------------------------------------------------------------
-- 2) TARGET — KCL members in windward_KCL (same scoped query, shrunk DB)
-- -----------------------------------------------------------------
drop table if exists #tgt_members;

SELECT mc.contact_relation_gid,
       max(case when mc.termination_date >= getdate() then 1 else 0 end) as is_active
into #tgt_members
from [windward_KCL].[dbo].[Contracts] c
join [windward_KCL].[dbo].[Contract_Relation] cr on cr.[contract_gid] = c.[contract_gid]
                                 and cr.effective_date <= getdate()
                                 and cr.termination_date >= getdate()
                                 and cr.record_status = 'A'
join [windward_KCL].[dbo].[sub_group] sg on sg.sub_group_gid = cr.[entity_gid]
                         and sg.sub_group_status = '01'
                         and sg.record_status = 'A'
join [windward_KCL].[dbo].[Sub_Group_Coverage] sgc ON sgc.[Sub_Group_PKID] = sg.[Sub_Group_PKID] AND sgc.[record_status] = 'A'
join [windward_KCL].[dbo].[Parent_Group_Coverage] pgc ON sgc.[Parent_Group_Coverage_PKID] = pgc.[Parent_Group_Coverage_PKID] AND pgc.[record_status] = 'A'
join [windward_KCL].[dbo].[parent_group] pg ON pgc.[parent_group_pkid] = pg.[parent_group_pkid] and pg.[record_status] = 'A'
join [windward_KCL].[dbo].[Purchaser_Coverage] pc ON pgc.[Purchaser_Coverage_PKID] = pc.[Purchaser_Coverage_PKID] and pc.[record_status] = 'A'
join [windward_KCL].[dbo].[Purchaser] p ON pc.[Purchaser_PKID] = p.[Purchaser_PKID] AND p.[record_status] = 'A'
join [windward_KCL].[dbo].[Subscriber_Coverage] sc ON sc.[Sub_Group_PKID] = sg.[Sub_Group_PKID]
                                   AND sc.[record_status] = 'A'
join [windward_KCL].[dbo].[member_coverage] mc on mc.[Subscriber_Coverage_PKID] = sc.[Subscriber_Coverage_PKID]
                               and mc.record_status = 'A'
where c.[contract_class_code] IN ('055001','055002')
  and c.record_status = 'A'
  and p.[Purchaser_PKID] in (select Purchaser_PKID from #kcl_purchasers)   -- filter to the KCL purchaser set
group by mc.contact_relation_gid;

-- -----------------------------------------------------------------
-- 3) VERDICT — TOTAL and ACTIVE reconciliation, one row each
-- -----------------------------------------------------------------
;with v as (
    select 'TOTAL' as scope,
           (select count(*) from #src_members) as src,
           (select count(*) from #tgt_members) as tgt,
           (select count(*) from (select contact_relation_gid from #src_members
                                  except select contact_relation_gid from #tgt_members) d) as lost,
           (select count(*) from (select contact_relation_gid from #tgt_members
                                  except select contact_relation_gid from #src_members) d) as extra
    union all
    select 'ACTIVE' as scope,
           (select count(*) from #src_members where is_active = 1),
           (select count(*) from #tgt_members where is_active = 1),
           (select count(*) from (select contact_relation_gid from #src_members where is_active = 1
                                  except select contact_relation_gid from #tgt_members where is_active = 1) d),
           (select count(*) from (select contact_relation_gid from #tgt_members where is_active = 1
                                  except select contact_relation_gid from #src_members where is_active = 1) d)
)
select 'AWWW2SQLKCL01D'        as server_name,
       scope,
       src                     as commercial_kcl_members,   -- source (full DB, KCL-scoped)
       tgt                     as kcl_members,               -- target (shrunk DB)
       tgt - src               as count_delta,
       lost                    as members_lost_by_shrink,    -- MUST be 0
       extra                   as members_extra_in_target,   -- MUST be 0 (no other client leaked in)
       case when src = tgt and lost = 0 and extra = 0
            then 'PASS' else 'FAIL' end as reconciliation_result
from v
order by case scope when 'TOTAL' then 1 else 2 end;

-- -----------------------------------------------------------------
-- 4) DIAGNOSTIC — members the shrink DROPPED (in source, absent in target)
--    Any rows here = data loss. Route to WW Shrinker Owner (Nabeel Syed). FAIL.
-- -----------------------------------------------------------------
select s.contact_relation_gid as lost_member_contact_relation_gid,
       s.is_active            as was_active_in_source
from #src_members s
where not exists (select 1 from #tgt_members t where t.contact_relation_gid = s.contact_relation_gid);

-- -----------------------------------------------------------------
-- 5) DIAGNOSTIC — members present in target but NOT in source
--    Any rows here = another client's data leaked in, or a scoping mismatch.
--    FAIL (cross-client contamination). Route to Shrinker Owner.
-- -----------------------------------------------------------------
select t.contact_relation_gid as extra_member_contact_relation_gid,
       t.is_active            as is_active_in_target
from #tgt_members t
where not exists (select 1 from #src_members s where s.contact_relation_gid = t.contact_relation_gid);

-- -----------------------------------------------------------------
-- 6) DIAGNOSTIC — members in BOTH DBs but whose ACTIVE status differs
--    Member survived the shrink but its active/termed state changed — investigate
--    (e.g. coverage rows dropped). Empty result expected.
-- -----------------------------------------------------------------
select s.contact_relation_gid,
       s.is_active as source_is_active,
       t.is_active as target_is_active
from #src_members s
join #tgt_members t on t.contact_relation_gid = s.contact_relation_gid
where s.is_active <> t.is_active;

-- Expected (KCL, 2026-06-15 baseline):
--   scope=TOTAL : commercial_kcl_members = 97,210  kcl_members = 97,210
--   scope=ACTIVE: commercial_kcl_members = 81,211  kcl_members = 81,211
--   count_delta = 0, members_lost_by_shrink = 0, members_extra_in_target = 0
--   reconciliation_result = PASS for both scopes; sections 4-6 return zero rows.

drop table if exists #src_members;
drop table if exists #tgt_members;
drop table if exists #kcl_purchasers;
