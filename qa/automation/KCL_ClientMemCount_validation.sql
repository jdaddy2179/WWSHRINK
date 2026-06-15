-- KCL Client Member Count — VALIDATION query
-- =================================================================
-- Purpose : Validate the KCL member counts that drive Tier (Phase 1).
-- Environment : PRODUCTION only, authorized US-based operator (PHI).
-- SME : AJ Schmucker (alan.schmucker@greatdentalplans.com)
-- Validated : 2026-06-15 — results match Environment Variables sheet.
--
-- This scopes KCL by COMMERCIAL contract class codes ('055001','055002')
-- and currently-effective Contract_Relation, rather than a hardcoded
-- purchaser_gid. It resolves the Total-vs-Active gap (TC-SQL-03 / D-SQL-1):
--
--   * ACTIVE count  -> UNCOMMENT the `mc.termination_date >= getdate()` line  -> 81,211
--   * TOTAL count   -> leave that line commented (as below)                   -> 97,210
--
-- Read note: this builds a session temp table (#kcl_members). Wrap the final
-- SELECT with COUNT(*) for the number, or SELECT COUNT(*) FROM [#kcl_members].

drop table if exists [#kcl_members]
go

SELECT mc.contact_relation_gid
into [#kcl_members]
from [dbo].[Contracts] c
join [dbo].[Contract_Relation] cr on cr.[contract_gid] = c.[contract_gid]
                                 and cr.effective_date <= getdate()
                                 and cr.termination_date >= getdate()
                                 and cr.record_status = 'A'
join [dbo].[sub_group] sg on sg.sub_group_gid = cr.[entity_gid]
                         and sg.sub_group_status = '01'
                         and sg.record_status = 'A'
join [dbo].[Sub_Group_Coverage] sgc ON sgc.[Sub_Group_PKID] = sg.[Sub_Group_PKID] AND sgc.[record_status] = 'A'
join [dbo].[Parent_Group_Coverage] pgc ON sgc.[Parent_Group_Coverage_PKID] = pgc.[Parent_Group_Coverage_PKID] AND pgc.[record_status] = 'A'
join [dbo].[parent_group] pg ON pgc.[parent_group_pkid] = pg.[parent_group_pkid] and pg.[record_status] = 'A'
join [dbo].[Purchaser_Coverage] pc ON pgc.[Purchaser_Coverage_PKID] = pc.[Purchaser_Coverage_PKID] and pc.[record_status] = 'A'
join [dbo].[Purchaser] p ON pc.[Purchaser_PKID] = p.[Purchaser_PKID] AND p.[record_status] = 'A'
join [dbo].[Subscriber_Coverage] sc ON sc.[Sub_Group_PKID] = sg.[Sub_Group_PKID]
                                   AND sc.[record_status] = 'A'
join [dbo].[member_coverage] mc on mc.[Subscriber_Coverage_PKID] = sc.[Subscriber_Coverage_PKID]
                               and mc.record_status = 'A'
                              -- and mc.termination_date >= getdate()   -- UNCOMMENT for ACTIVE (81,211); commented = TOTAL (97,210)
where c.[contract_class_code] IN ('055001','055002')
  and c.record_status = 'A'
group by mc.contact_relation_gid

-- Expected (KCL, 2026-06-15):
--   TOTAL  (line commented)   = 97,210   -> Tier 3  (< 100,000)
--   ACTIVE (line uncommented) = 81,211   -> Tier 3  (< 100,000)

SELECT COUNT(*) AS member_count FROM [#kcl_members];
