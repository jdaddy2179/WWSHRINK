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
-- Environment : PRODUCTION / PHI — run ONLY as an authorized US-based operator,
--               with read-only / least-privilege credentials.
-- SME         : AJ Schmucker (alan.schmucker@greatdentalplans.com)
-- Owners      : SQA validation (Joshua Ernstoff, Keerthan Tumuganti)
--
-- HOW IT WORKS
--   Section 0 derives the KCL PURCHASER SET once from windward_commercial (the
--   canonical client definition, contract_class_code IN ('055001','055002') +
--   currently-effective Contract_Relation). The same member query — filtered to
--   that purchaser set — is then run against BOTH databases via three-part
--   naming, so no USE / batch-switch is needed and both sides use an identical
--   purchaser scope. One execution returns the verdict. The shrink PASSES only when:
--      (a) source count  == target count, AND
--      (b) the member sets are identical (zero rows in either EXCEPT diff).
--   Count parity alone can hide a swap (one lost member + one extra) — the
--   set-level diff (sections 4-5) is what makes this a real reconciliation.
--
--   TOTAL vs ACTIVE: leave the mc.termination_date line commented for TOTAL
--   (expected 97,210, 2026-06-15); uncomment it in BOTH blocks for ACTIVE
--   (expected 81,211). Keep the two blocks identical or the compare is invalid.
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

SELECT distinct p.Purchaser, p.Purchaser_PKID
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
select Purchaser, Purchaser_PKID from #kcl_purchasers order by Purchaser;

-- -----------------------------------------------------------------
-- 1) SOURCE — KCL members in windward_commercial (scoped to KCL purchasers)
-- -----------------------------------------------------------------
drop table if exists #src_members;

SELECT mc.contact_relation_gid
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
                              -- and mc.termination_date >= getdate()   -- UNCOMMENT (both blocks) for ACTIVE
where c.[contract_class_code] IN ('055001','055002')
  and c.record_status = 'A'
  and p.[Purchaser_PKID] in (select Purchaser_PKID from #kcl_purchasers)   -- filter to the KCL purchaser set
group by mc.contact_relation_gid;

-- -----------------------------------------------------------------
-- 2) TARGET — KCL members in windward_KCL (same scoped query, shrunk DB)
-- -----------------------------------------------------------------
drop table if exists #tgt_members;

SELECT mc.contact_relation_gid
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
                              -- and mc.termination_date >= getdate()   -- UNCOMMENT (both blocks) for ACTIVE
where c.[contract_class_code] IN ('055001','055002')
  and c.record_status = 'A'
  and p.[Purchaser_PKID] in (select Purchaser_PKID from #kcl_purchasers)   -- filter to the KCL purchaser set
group by mc.contact_relation_gid;

-- -----------------------------------------------------------------
-- 3) VERDICT — count parity + set-identity in one row
-- -----------------------------------------------------------------
declare @src        int = (select count(*) from #src_members);
declare @tgt        int = (select count(*) from #tgt_members);
declare @lost       int = (select count(*) from (select contact_relation_gid from #src_members
                                                 except
                                                 select contact_relation_gid from #tgt_members) d);  -- in source, not in target
declare @extra      int = (select count(*) from (select contact_relation_gid from #tgt_members
                                                 except
                                                 select contact_relation_gid from #src_members) d);  -- in target, not in source

select 'AWWW2SQLKCL01D'                       as server_name,
       @src                                   as commercial_kcl_members,   -- source (full DB, KCL-scoped)
       @tgt                                   as kcl_members,              -- target (shrunk DB)
       @tgt - @src                            as count_delta,
       @lost                                  as members_lost_by_shrink,   -- MUST be 0
       @extra                                 as members_extra_in_target,  -- MUST be 0 (no other client leaked in)
       case when @src = @tgt and @lost = 0 and @extra = 0
            then 'PASS' else 'FAIL' end        as reconciliation_result;

-- -----------------------------------------------------------------
-- 4) DIAGNOSTIC — members the shrink DROPPED (present in source, absent in target)
--    Any rows here = data loss. Route to WW Shrinker Owner (Nabeel Syed). FAIL.
-- -----------------------------------------------------------------
select contact_relation_gid as lost_member_contact_relation_gid
from #src_members
except
select contact_relation_gid from #tgt_members;

-- -----------------------------------------------------------------
-- 5) DIAGNOSTIC — members present in target but NOT in source
--    Any rows here = another client's data leaked into the shrunk DB, or a
--    scoping mismatch. FAIL (cross-client contamination). Route to Shrinker Owner.
-- -----------------------------------------------------------------
select contact_relation_gid as extra_member_contact_relation_gid
from #tgt_members
except
select contact_relation_gid from #src_members;

-- Expected (KCL, TOTAL — termination_date line commented in BOTH blocks):
--   commercial_kcl_members = 97,210   kcl_members = 97,210
--   count_delta = 0   members_lost_by_shrink = 0   members_extra_in_target = 0
--   reconciliation_result = PASS   (sections 4 & 5 return zero rows)

drop table if exists #src_members;
drop table if exists #tgt_members;
drop table if exists #kcl_purchasers;
