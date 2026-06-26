-- KCL Purchasers — DISCOVERY query
-- =================================================================
-- Purpose : Return the distinct set of Purchasers that make up KCL, derived
--           from the commercial contract classes ('055001','055002') and the
--           currently-effective coverage chain. This purchaser set IS the
--           canonical KCL client definition — the same Purchaser scope that
--           drives the WW Shrink (Phase 4 / TC-P4-03) and the source-vs-target
--           member reconciliation.
--
-- Server      : AWWW2SQLKCL01D
-- Run against : windward_commercial   (full source DB — the source of truth)
-- Environment : PRODUCTION / PHI — authorized US-based operator, read-only creds.
-- SME         : AJ Schmucker (alan.schmucker@greatdentalplans.com)
--
-- Use the output as the scoping input for:
--   * WWShrink_KCL_SourceTarget_Reconciliation.sql (filters members by purchaser)
--   * Phase 4 shrink scoping validation (Purchaser_ID list, TC-P4-03)
-- =================================================================

SELECT distinct p.Purchaser, p.Purchaser_PKID
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
                              -- and mc.termination_date >= getdate()
where c.[contract_class_code] IN ('055001','055002')
  and c.record_status = 'A'
order by p.Purchaser;
