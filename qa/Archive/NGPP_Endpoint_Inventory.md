# NGPP API Endpoint Inventory

> Consolidated list of every endpoint across the Business and Domain service tiers, extracted from 27 OpenAPI/Swagger specs. Use this as the master reference for SQA coverage planning, the SLE rollout test plan, and cross-layer mirror identification.

**Totals: 248 endpoints across 24 services.**

| Layer | Endpoints | Services |
|---|---|---|
| Business | 137 | 15 |
| Domain | 111 | 9 |

---

## 1. Authentication Distribution

| Auth pattern | Count |
|---|---|
| none (network-isolated) | 190 |
| AWS IAM SigV4 | 57 |
| - | 1 |

---

## 2. Endpoints by Service

Each service is grouped by its OpenAPI title. Sorted alphabetically within each layer.

### 2.1 Business Layer (137 endpoints)

#### BusinessService.Api *(4 endpoints)*

Source: `business-service.json` | Auth: none (network-isolated)

| Method | Path | Tag | Operation |
|---|---|---|---|
| GET | `/api/member-interventions/v1/business/{taxIdNumber}/member-interventions` | Member Intervention |  |
| POST | `/api/member-interventions/v1/business/{taxIdNumber}/member-interventions/batch-delete` | Member Intervention |  |
| GET | `/api/member-interventions/v1/member-interventions/actions` | Member Intervention |  |
| GET | `/api/member-interventions/v1/member-interventions/measures` | Member Intervention |  |

#### DQ API V4 *(11 endpoints)*

Source: `on-prem-datahub-v4.json` | Auth: none (network-isolated)

| Method | Path | Tag | Operation |
|---|---|---|---|
| POST | `/restapi/v4/BenefitSummary` | BenefitSummary | BenefitSummary_GetBenefitSummary |
| POST | `/restapi/v4/BenefitSummaryPaged` | BenefitSummary | BenefitSummary_GetBenefitSummaryPaged |
| POST | `/restapi/v4/BenefitSummaryZip` | BenefitSummary | BenefitSummary_GetBenefitSummaryZip |
| POST | `/restapi/v4/FeeSchedules` | FeeSchedule | FeeSchedule_GetFeeSchedules |
| POST | `/restapi/v4/GetMemberFamily` | GetMember | GetMember_GetMemberFamily |
| POST | `/restapi/v4/MemberEligibility` | MemberEligibility | MemberEligibility_Post |
| POST | `/restapi/v4/NGPanelRosters` | NGPanelRoster | NGPanelRoster_GetPanelRosters |
| POST | `/restapi/v4/PanelRosters` | PanelRoster | PanelRoster_GetPanelRosters |
| POST | `/restapi/v4/PanelRostersDownload` | PanelRoster | PanelRoster_DownloadPanelRosters |
| GET | `/restapi/v4/PreEstimate` | PreEstimate | PreEstimate_Get |
| POST | `/restapi/v4/SpecialDealFeeSchedules` | FeeSchedule | FeeSchedule_GetSpecialDealFeeSchedules |

#### DQ.BusinessService.Api.BilledAmounts *(6 endpoints)*

Source: `billed-amounts-business-service-api.json` | Auth: AWS IAM SigV4

| Method | Path | Tag | Operation |
|---|---|---|---|
| GET | `/api/billed-amounts/v1/billed-amount-codes/` | BilledAmounts |  |
| GET | `/api/billed-amounts/v1/billed-amounts/` | BilledAmounts |  |
| POST | `/api/billed-amounts/v1/billed-amounts/` | BilledAmounts |  |
| DELETE | `/api/billed-amounts/v1/billed-amounts/{id}` | BilledAmounts |  |
| GET | `/api/billed-amounts/v1/billed-amounts/{id}` | BilledAmounts |  |
| PUT | `/api/billed-amounts/v1/billed-amounts/{id}` | BilledAmounts |  |

#### DQ.BusinessService.Api.Digital-Id *(10 endpoints)*

Source: `digital-id-business-services-api.json` | Auth: AWS IAM SigV4

| Method | Path | Tag | Operation |
|---|---|---|---|
| GET | `/api/health` | Digital Id |  |
| GET | `/api/health` | Digital Id |  |
| GET | `/api/members/{memberProfileGuid}/member-id-card` | Digital Id |  |
| GET | `/api/members/{memberProfileGuid}/member-id-card` | Digital Id |  |
| GET | `/api/v2.0/health` | Digital Id |  |
| GET | `/api/v2.0/image` | Digital Id image |  |
| GET | `/api/v2.0/members/{memberProfileGuid}/member-id-card` | Digital Id |  |
| GET | `/api/v2.0/members/{memberProfileGuid}/member-id-card/pdf` | Digital Id |  |
| GET | `/api/v2.0/members/{memberProfileGuid}/member-id-card/wallet/apple` | Digital Id |  |
| GET | `/api/v2.0/members/{memberProfileGuid}/member-id-card/wallet/google` | Digital Id |  |

#### DQ.BusinessService.Api.Digital-Id-Media *(1 endpoints)*

Source: `digital-id-media-business-services-api.json` | Auth: AWS IAM SigV4

| Method | Path | Tag | Operation |
|---|---|---|---|
| POST | `/api/member-id-card/pdf` | Digital Id Pdf |  |

#### DQ.BusinessService.Api.User-Management *(4 endpoints)*

Source: `user-management-business-service-api.json` | Auth: none (network-isolated)

| Method | Path | Tag | Operation |
|---|---|---|---|
| POST | `/api/user-management/generate-and-send-otp` | User Management |  |
| POST | `/api/user-management/send-username` | User Management |  |
| POST | `/api/user-management/valdidate-otp` | User Management |  |
| GET | `/api/users/v1/users` | User | Search Users by different parameters, including TIN |

#### DQ.Foundational.Api.Case-Management *(8 endpoints)*

Source: `case-management-bussiness-service-apis.json` | Auth: none (network-isolated)

| Method | Path | Tag | Operation |
|---|---|---|---|
| GET | `/api/case-management/v1/caseTypes` | CaseType |  |
| GET | `/api/case-management/v1/cases` | Case |  |
| POST | `/api/case-management/v1/cases` | Case |  |
| POST | `/api/case-management/v1/cases/batch-update` | Cases Batch Update |  |
| POST | `/api/case-management/v1/cases/bulk-close` | Cases- Bulk Close |  |
| GET | `/api/case-management/v1/cases/{caseNum}` | Case |  |
| PUT | `/api/case-management/v1/cases/{caseNum}` | Case |  |
| GET | `/api/case-management/v1/get-cases-pagination` | Case |  |

#### DQ.Foundational.Api.Claim-Submission *(15 endpoints)*

Source: `claim-submission-api.json` | Auth: none (network-isolated)

| Method | Path | Tag | Operation |
|---|---|---|---|
| GET | `/api/claim-submission/v1/business/claims/report/{claimType}/{date}` | Claim Submission |  |
| GET | `/api/claim-submission/v1/business/{taxIdNumber}/claims/adjudicated/` | Claim Submission |  |
| GET | `/api/claim-submission/v1/business/{taxIdNumber}/claims/adjudicated/{claimNumber}` | Claim Submission |  |
| GET | `/api/claim-submission/v1/business/{taxIdNumber}/claims/adjudicated/{claimNumber}/attachments` | Claim Submission |  |
| GET | `/api/claim-submission/v1/business/{taxIdNumber}/claims/adjudicated/{claimNumber}/attachments/{documentId}` | Claim Submission |  |
| GET | `/api/claim-submission/v1/business/{taxIdNumber}/claims/adjudicated/{claimNumber}/checks/{checkNumber}` | Claim Submission |  |
| GET | `/api/claim-submission/v1/business/{taxIdNumber}/claims/submitted/` | Claim Submission |  |
| POST | `/api/claim-submission/v1/business/{taxIdNumber}/claims/submitted/` | Claim Submission |  |
| GET | `/api/claim-submission/v1/business/{taxIdNumber}/claims/submitted/{claimNumber}` | Claim Submission |  |
| GET | `/api/claim-submission/v1/business/{taxIdNumber}/member/{memberProfileGuid}/claims/submitted/` | Claim Submission |  |
| GET | `/api/claim-submission/v1/business/{taxIdNumber}/member/{memberProfileGuid}/treatment-plan-estimate` | Treatment Plan Estimate |  |
| GET | `/api/claim-submission/v1/business/{taxIdNumber}/treatment-plan-estimate` | Treatment Plan Estimate |  |
| POST | `/api/claim-submission/v1/business/{taxIdNumber}/treatment-plan-estimate` | Treatment Plan Estimate |  |
| GET | `/api/claim-submission/v1/business/{taxIdNumber}/treatment-plan-estimate/{claimNumber}` | Treatment Plan Estimate |  |
| GET | `/api/claim-submission/v2/business/{taxIdNumber}/claims/adjudicated/` | Claim Submission |  |

#### DQ.Foundational.Api.Eligibility.Web *(17 endpoints)*

Source: `eligibility-api.json` | Auth: AWS IAM SigV4

| Method | Path | Tag | Operation |
|---|---|---|---|
| GET | `/api/eligibility/v1/birthdate-search` | EligibilitySearch |  |
| GET | `/api/eligibility/v1/eligibility-status` | EligibilitySearch |  |
| GET | `/api/eligibility/v1/member-contact-details` | EligibilitySearch |  |
| GET | `/api/eligibility/v1/member-coverage-search` | EligibilitySearch |  |
| GET | `/api/eligibility/v1/member-detail` | MemberDetail |  |
| GET | `/api/eligibility/v1/member-detail/business-contact-details` | MemberDetail |  |
| GET | `/api/eligibility/v1/member-detail/{id}` | MemberDetail |  |
| GET | `/api/eligibility/v1/member-detail/{id}/accumulators` | MemberDetail |  |
| GET | `/api/eligibility/v1/member-detail/{id}/clinical-history` | MemberDetail |  |
| GET | `/api/eligibility/v1/member-detail/{id}/coordination-of-benefits` | MemberDetail |  |
| GET | `/api/eligibility/v1/member-detail/{id}/enrollment-history` | MemberDetail |  |
| GET | `/api/eligibility/v1/member-detail/{id}/family-info` | MemberDetail |  |
| GET | `/api/eligibility/v1/member-detail/{id}/house-holds` | MemberDetail |  |
| GET | `/api/eligibility/v1/member-detail/{id}/member-info` | MemberDetail |  |
| GET | `/api/eligibility/v1/member-detail/{id}/product-configuration` | MemberDetail |  |
| POST | `/api/eligibility/v1/member-roster` | viewmemberroster |  |
| GET | `/api/eligibility/v2/member-detail/{id}/member-info` | MemberDetail |  |

#### DQ.Foundational.Api.IVR-Faxback *(1 endpoints)*

Source: `member-ivr-faxback-api.json` | Auth: none (network-isolated)

| Method | Path | Tag | Operation |
|---|---|---|---|
| GET | `/paperless/member-benefit-limitation-summary/{id}` | (none) |  |

#### DQ.Foundational.Api.PracticeManagement *(23 endpoints)*

Source: `practice-management-api.json` | Auth: AWS IAM SigV4

| Method | Path | Tag | Operation |
|---|---|---|---|
| GET | `/api/practice-management/v1/access-point-picklist` | AccessPointPicklist |  |
| GET | `/api/practice-management/v1/access-point-picklist-new` | AccessPointPicklist |  |
| GET | `/api/practice-management/v1/access-point-picklist/{businessGuid}` | AccessPointPicklist |  |
| GET | `/api/practice-management/v1/access-point/{id}` | AccessPoint |  |
| GET | `/api/practice-management/v1/business` | Business |  |
| GET | `/api/practice-management/v1/business-contact-information` | Business |  |
| GET | `/api/practice-management/v1/business/geographic-locations` | Business |  |
| GET | `/api/practice-management/v1/business/networks` | Business |  |
| GET | `/api/practice-management/v1/business/{id}` | Business |  |
| GET | `/api/practice-management/v1/fee-schedule` | Fee Schedule |  |
| GET | `/api/practice-management/v1/network-picklist` | Network Picklist |  |
| GET | `/api/practice-management/v1/pick-list-location/{id}/practitioners` | Practice Management - Pic |  |
| GET | `/api/practice-management/v1/pick-list-locations` | Practice Management - Pic |  |
| GET | `/api/practice-management/v1/practice-profile-info` | PracticeProfile |  |
| GET | `/api/practice-management/v1/practitioner` | Practitioner |  |
| GET | `/api/practice-management/v1/practitioner-business` | Practitioner |  |
| GET | `/api/practice-management/v1/practitioner/{id}` | Practitioner |  |
| GET | `/api/practice-management/v1/practitioner/{id}/active-par-networks` | Practitioner |  |
| GET | `/api/practice-management/v1/practitioner/{id}/service-locations` | Practitioner |  |
| GET | `/api/practice-management/v1/service-location` | Servicelocation |  |
| GET | `/api/practice-management/v1/service-location/{id}` | Servicelocation |  |
| GET | `/api/practice-management/v1/service-location/{id}/active-par-networks` | Servicelocation |  |
| GET | `/api/practice-management/v1/service-location/{id}/practitioners` | Servicelocation |  |

#### DQ.Foundational.Api.Product *(1 endpoints)*

Source: `product-api.json` | Auth: none (network-isolated)

| Method | Path | Tag | Operation |
|---|---|---|---|
| GET | `/api/product/v1/product-configuration/{id}` | Product |  |

#### DQ.SFDC.ProcessIntegration.Web *(34 endpoints)*

Source: `on-prem-documents-api.json` | Auth: none (network-isolated)

| Method | Path | Tag | Operation |
|---|---|---|---|
| GET | `/BrokerCommission` | BrokerCommission | BrokerCommission_BrokerCommissions |
| GET | `/BrokerCommission/{id}` | BrokerCommission | BrokerCommission_BrokerCommission |
| POST | `/Case` | Case | Case_Case |
| GET | `/CaseAttachment` | CaseAttachment | CaseAttachment_GetCaseAttachment |
| POST | `/CaseAttachmentWindward` | Case | Case_CaseAttachment |
| GET | `/CaseAttachments` | CaseAttachment | CaseAttachment_GetCaseAttachments |
| POST | `/CaseIntake` | CaseIntake | CaseIntake_CaseIntake |
| POST | `/CaseIntakeDetail` | CaseIntake | CaseIntake_CaseIntakeDetail |
| POST | `/CaseIntegrationCheck` | Case | Case_CaseIntegrationCheck |
| GET | `/ClaimAttachment` | ClaimAttachment | ClaimAttachment_GetNextSequenceNumberFromDatabase |
| POST | `/ClaimAttachment` | ClaimAttachment | ClaimAttachment_UploadClaimAttachment |
| GET | `/ClaimAttachment/ClaimAttachment` | ClaimAttachment | ClaimAttachment_ClaimAttachment |
| GET | `/ClaimAttachment/ClaimAttachments` | ClaimAttachment | ClaimAttachment_ClaimAttachments |
| GET | `/ClaimAttachment/{id}` | ClaimAttachment | ClaimAttachment_ClaimAttachment |
| GET | `/EOBServerStatus/{routeId}` | MemberEob | MemberEob_EOBServerStatus |
| GET | `/EobReconciled` | EobReconciled | EobReconciled_Get |
| POST | `/EobReconciled` | EobReconciled | EobReconciled_Post |
| GET | `/MemberEOBList/{subscriberId}/{planGuid}/{routeId}` | MemberEob | MemberEob_MemberEOBList |
| GET | `/MemberEOBs/{subscriberId}/{memberProfileGuid}/{routeId}` | MemberEob | MemberEob_MemberEOBs |
| GET | `/MemberEob` | MemberEob | MemberEob_MemberEOBList |
| GET | `/MemberEob/{id}` | MemberEob | MemberEob_Get |
| GET | `/NGEOBReconciled` | EobReconciled | EobReconciled_NGEOBReconciled |
| POST | `/NGEOBReconciled` | EobReconciled | NGEobReconciled_NGEOBReconciled |
| POST | `/NGProviderEOBs` | ProviderEob | ProviderEob_NGProviderEOBs |
| POST | `/Notification` | Notification | Notification_Post |
| GET | `/Notification/{id}` | Notification | Notification_Get |
| POST | `/PCDRequest` | PCDRequest | PCDRequest_Post |
| GET | `/PCDRequest/{id}` | PCDRequest | PCDRequest_Get |
| GET | `/ProviderEOB` | ProviderEob | ProviderEob_ProviderEOB |
| POST | `/ProviderEOBs` | ProviderEob | ProviderEob_ProviderEOBs |
| POST | `/ProviderEob` | ProviderEob | ProviderEob_ProviderEOBs |
| POST | `/UpdateCaseIntakeDetail` | CaseIntake | CaseIntake_UpdateCaseIntakeDetail |
| POST | `/UpdatePcdStatus` | UpdatePcdStatus | UpdatePcdStatus_Post |
| POST | `/UploadCaseAttachment` | CaseAttachment | CaseAttachment_UploadCaseAttachment |

#### Foundational.Api.MemberBenefits.Web *(1 endpoints)*

Source: `member-benefits-api.json` | Auth: none (network-isolated)

| Method | Path | Tag | Operation |
|---|---|---|---|
| GET | `/benefits/member-benefits/{id}` | MemberBenefits |  |

#### case-management-api.json *(1 endpoints)*

Source: `case-management-api.json` | Auth: -

| Method | Path | Tag | Operation |
|---|---|---|---|
| - | `(spec parse error)` | - | Expecting property name enclosed in double quotes: line 110  |

### 2.2 Domain Layer (111 endpoints)

#### DQ API External *(17 endpoints)*

Source: `external-api.json` | Auth: none (network-isolated)

| Method | Path | Tag | Operation |
|---|---|---|---|
| GET | `/external/Member` | MemberMobile | MemberMobile_Member |
| POST | `/external/Member/SLmobileUpdatePrimaryCareDentists` | PCDAssignment | PCDAssignment_SLmobileUpdatePrimaryCareDentists |
| POST | `/external/Member/UpdatePrimaryCareDentists` | PCDAssignment | PCDAssignment_UpdatePrimaryCareDentists |
| GET | `/external/Member/{id}` | MemberMobile | MemberMobile_MemberId |
| GET | `/external/Member/{id}/ServiceHistory` | MemberMobile | MemberMobile_MemberIdServiceHistory |
| GET | `/external/PanelRostersDownload` | PanelRoster | PanelRoster_DownloadPanelRosters_V3 |
| GET | `/external/SLmobileMemberSearch` | MemberMobile | MemberMobile_SLmobileMemberSearch |
| GET | `/external/SLmobileMemberSearch/{id}` | MemberMobile | MemberMobile_GetMemberIdSL |
| GET | `/external/SLmobileMemberSearch/{id}/ServiceHistory` | MemberMobile | MemberMobile_GetMemberIdServiceHistorySL |
| GET | `/external/SLmobileMemberSearchAllIDs` | MemberMobile | MemberMobile_SLmobileMemberSearchAllIDs |
| GET | `/external/v2/Member` | MemberMobile | MemberMobile_GetMember |
| POST | `/external/v2/Member/UpdatePrimaryCareDentists` | PCDAssignment | PCDAssignment_UpdateNonGuardianPrimaryCareDentists |
| GET | `/external/v2/Member/{id}` | MemberMobile | MemberMobile_GetMemberId |
| GET | `/external/v2/Member/{id}/ServiceHistory` | MemberMobile | MemberMobile_GetMemberIdServiceHistory |
| GET | `/external/v2/MultiMemberSearch` | MemberMobile | MemberMobile_GetMultiMemberSearch |
| GET | `/external/v6/Member-Login` | MemberMobile | MemberMobile_GetDDMAMemberSearch |
| GET | `/external/v6/MemberSearch` | MemberMobile | MemberMobile_GetMemberDDMAMemberSearch |

#### DQ API V6 *(18 endpoints)*

Source: `datahub-api-v6.json` | Auth: none (network-isolated)

| Method | Path | Tag | Operation |
|---|---|---|---|
| GET | `/external/v6/Member-Login` | MemberMobile | MemberMobile_GetDDMAMemberSearch |
| GET | `/external/v6/MemberSearch` | MemberMobile | MemberMobile_GetMemberDDMAMemberSearch |
| POST | `/restapi/v6/BenefitSummary` | BenefitSummary | BenefitSummary_GetBenefitSummaryV6 |
| POST | `/restapi/v6/BenefitSummaryNoProcCodesInFreqDesc` | BenefitSummary | BenefitSummary_GetBenefitSummaryNoProcCodeV6 |
| POST | `/restapi/v6/BenefitSummaryPaged` | BenefitSummary | BenefitSummary_GetBenefitSummaryPagedV6 |
| POST | `/restapi/v6/BenefitSummaryZip` | BenefitSummary | BenefitSummary_GetBenefitSummaryZipV6 |
| POST | `/restapi/v6/FeeSchedules` | FeeSchedule | FeeSchedule_GetFeeSchedules |
| POST | `/restapi/v6/GetClaim` | GetClaim | GetClaim_GetClaimV6 |
| POST | `/restapi/v6/GetMemberFamily` | GetMember | GetMember_GetMemberFamilyV6 |
| GET | `/restapi/v6/GetMemberServiceHistory/{id}` | GetMember | GetMember_GetMemberServiceHistoryV6Head |
| POST | `/restapi/v6/MemberCoverageMMP` | MemberCoverageMMP | MemberCoverageMMP_GetMemberCoverageMMPV6 |
| POST | `/restapi/v6/PanelRosters` | PanelRoster | PanelRoster_GetNGPanelRostersv6 |
| POST | `/restapi/v6/PanelRostersDownload` | PanelRoster | PanelRoster_DownloadPanelRosters_V6 |
| POST | `/restapi/v6/PlanSummary` | PlanSummary | PlanSummary_GetPlanSummaryV6 |
| POST | `/restapi/v6/PlanSummaryNoProcCodesInFreqDesc` | PlanSummary | PlanSummary_GetPlanSummaryNoProcCodeV6 |
| POST | `/restapi/v6/PlanSummaryPaged` | PlanSummary | PlanSummary_GetPlanSummaryPagedV6 |
| POST | `/restapi/v6/PlanSummaryZip` | PlanSummary | PlanSummary_GetPlanSummaryZipV6 |
| GET | `/restapi/v6/PreEstimate` | PreEstimate | PreEstimate_PreEstimateV6 |

#### DQ.Foundational.Api *(3 endpoints)*

Source: `group-product-api-swagger.json` | Auth: none (network-isolated)

| Method | Path | Tag | Operation |
|---|---|---|---|
| GET | `/v1/product-configuration/{id}` | Product | Get Product-Configuration by specified Product Configuration |
| GET | `/v1/purchaser` | Group | Search purchasers having the specified data |
| POST | `/v1/purchaser/hierarchies` | Group | Get purchasers group hierarchy for each purchaserId in reque |

#### DQ.Foundational.Api.Web *(9 endpoints)*

Source: `claims-api.json` | Auth: none (network-isolated)

| Method | Path | Tag | Operation |
|---|---|---|---|
| GET | `/Claims` | Claims |  |
| POST | `/Claims` | Claims |  |
| GET | `/Claims/Paginated` | Claims |  |
| POST | `/Claims/Paginated` | Claims |  |
| GET | `/Claims/Search/All` | Claims |  |
| GET | `/Claims/{id}` | Claims |  |
| POST | `/Claims/{id}` | Claims |  |
| GET | `/Claims/{id}/Version/{versionId}` | Claims |  |
| GET | `/claims/claims-search-paginated` | claims | Search claims by search pagination params |

#### DQ.Foundational.MembershipApi *(21 endpoints)*

Source: `member-api-swagger.json` | Auth: none (network-isolated)

| Method | Path | Tag | Operation |
|---|---|---|---|
| GET | `/v1/authorization/authorized-members` | Membership | Search authorized members having the specified data. |
| GET | `/v1/contact` | Membership | Seach members having the specified data |
| GET | `/v1/contact/{id}` | Membership | Get Contact by specified Id, with all data |
| GET | `/v1/guardian` | Membership | Seach guardians having the specified data |
| GET | `/v1/guardian/{id}` | Membership | Get Guardian by specified Contact Guardian Guid, with all da |
| GET | `/v1/member` | Membership | Search members having the specified data |
| GET | `/v1/member/Fast` | Membership | Search members having the specified data. |
| GET | `/v1/member/MemberCoverages` | Membership | Starts the search for Members and Coverages, who meet the cr |
| GET | `/v1/member/contact-details` | Membership | Search members having the specified data. |
| POST | `/v1/member/member-roster` | Membership | Get purchasers group hierarchy for each purchaserId in reque |
| POST | `/v1/member/member-roster-details` | Membership | Search Member Roster with Details - combines roster, PCD, an |
| GET | `/v1/member/{id}` | Membership | Get Member (with all data) by specified Member Profile Guid  |
| GET | `/v1/member/{id}/accumulator` | Membership | Get Member Accumulators by specified Member Profile Guid in  |
| GET | `/v1/member/{id}/cleaning-eligibility` | Membership | Gets cleaning eligibility information for a member |
| GET | `/v1/member/{id}/clinical-history` | Membership | Get Member Clinical History by specified Member Profile Guid |
| GET | `/v1/member/{id}/coordination-of-benefits` | Membership | Get Member Coordinator of Benefits by specified Member Profi |
| GET | `/v1/member/{id}/coverage` | Membership | Get Member Coverages by specified Member Profile Guid |
| GET | `/v1/member/{id}/medical-conditions` | Membership | Get Member Medical Condition by specified Member Profile Gui |
| GET | `/v1/member/{id}/member-info` | Membership | Get Member Info by specified Member Profile Guid |
| GET | `/v1/member/{id}/primary-care-dentist` | Membership | Get Member Primary Care Dentists by specified Member Profile |
| GET | `/v1/pcdrules/{id}` | Membership | Get PcdRules for given SubGroup Gid |

#### DQ.Foundational.ProviderApi *(32 endpoints)*

Source: `provider-api-swagger.json` | Auth: none (network-isolated)

| Method | Path | Tag | Operation |
|---|---|---|---|
| GET | `/v1/access-point` | Provider | Search AccessPoints by given query |
| GET | `/v1/access-point/{id}` | Provider | Get the AccessPoint by specified by given AccessPoint Id |
| GET | `/v1/business` | Provider | Search Business by given query, with full data result. |
| GET | `/v1/business/access-point-picklist` | Provider | Search Business by given query, to get AccessPoint PickList. |
| GET | `/v1/business/business-contact-information` | Provider | Gets the Business with the main contact data, corresponding  |
| GET | `/v1/business/by-tin-networks` | Provider | Retrieves all active network participations for the specifie |
| GET | `/v1/business/by-tin-practitioners` | Provider | Search a (lightweight with Practitioners) with of Business b |
| GET | `/v1/business/guid-conversion` | Provider | Convert Trusted GUIDs to Windward GUIDs. |
| GET | `/v1/business/locations` | Provider | Retrieve the list of locations (state and zip) for the speci |
| GET | `/v1/business/network-picklist` | Provider | Search Business by given query, to get Network PickList. |
| GET | `/v1/business/network-picklistV2` | Provider | Search Business by given query, to get Network PickList, alt |
| GET | `/v1/business/practice-profile-info` | Provider | Gets the Pratice profile info, corresponding to the TIN prov |
| GET | `/v1/business/practice-profile-locations` | Provider | Search a (lightweight with Practitioners) with of Business b |
| GET | `/v1/business/{id}` | Provider | Get Business by specified Business Guid, with all data |
| GET | `/v1/network-contract` | Provider | Search NetworkContract by given query |
| GET | `/v1/network-contract/{id}` | Provider | Get NetworkContract by specified Network identifier, with al |
| GET | `/v1/network-contract/{id}/service-location-id/{serviceLocationId}` | Provider | Get NetworkContract by specified Network identifier and Serv |
| GET | `/v1/network-stack` | Provider |  |
| GET | `/v1/network-stack/{id}` | Provider | Get the Network Stack by Network Stack identifier. |
| GET | `/v1/network-stack/{id}/service-location-id/{serviceLocationId}` | Provider | Get the Network Stack by Network Stack identifier and Servic |
| GET | `/v1/practitioner` | Provider | Search practitioners by NPI, TIN, license, name, or other cr |
| GET | `/v1/practitioner/{id}` | Provider | Get practitioner data with all information. |
| GET | `/v1/practitioner/{id}/information` | Provider | Get practitioner info with very basic information. |
| GET | `/v1/product-participation` | Provider | It searches for Product Participations that meet the specifi |
| GET | `/v1/product-participation/{id}` | Provider | Get the DQ.Foundational.Domain.Model.Entities.ProductPartici |
| GET | `/v1/product-participation/{id}/service-location-id/{serviceLocationId}` | Provider | Get the DQ.Foundational.Domain.Model.Entities.ProductPartici |
| GET | `/v1/service-location` | Provider | Search service locations by given parameters. |
| GET | `/v1/service-location/pick-list-locations` | Provider |  |
| GET | `/v1/service-location/{id}` | Provider | Get a specific service location by its Identification. |
| GET | `/v1/service-location/{id}/address` | Provider | Get the service location address. |
| GET | `/v1/service-location/{id}/pick-list-practitioners` | Provider | Get service location's practitioners by business TIN |
| POST | `/v1/trusted-guids` | Provider | Require a new Guid <=> Trusted Guid Mappings |

#### Foundational.Api.Benefits.Web *(2 endpoints)*

Source: `benefit-summary-v5-swagger.json` | Auth: none (network-isolated)

| Method | Path | Tag | Operation |
|---|---|---|---|
| POST | `/services-v2.0/restapi/GroupBenefitService` | GroupBenefit |  |
| POST | `/services-v2.0/restapi/v5/BenefitSummary` | BenefitSummary |  |

#### Foundational.Api.BilledAmounts *(6 endpoints)*

Source: `billed-amounts-api-swagger.json` | Auth: none (network-isolated)

| Method | Path | Tag | Operation |
|---|---|---|---|
| GET | `/billed-amounts/billed-amount-codes` | BilledAmounts |  |
| GET | `/billed-amounts/billed-amount-lists` | BilledAmounts |  |
| POST | `/billed-amounts/billed-amount-lists` | BilledAmounts |  |
| DELETE | `/billed-amounts/billed-amount-lists/{id}` | BilledAmounts |  |
| GET | `/billed-amounts/billed-amount-lists/{id}` | BilledAmounts |  |
| PUT | `/billed-amounts/billed-amount-lists/{id}` | BilledAmounts |  |

#### Foundational.Api.ElectronicDocuments *(3 endpoints)*

Source: `electronic-document-api-swagger.json` | Auth: none (network-isolated)

| Method | Path | Tag | Operation |
|---|---|---|---|
| GET | `/api/electronic-documents/v1/documents` | ElectronicDocument |  |
| GET | `/api/electronic-documents/v1/documents/{id}` | ElectronicDocument |  |
| GET | `/api/electronic-documents/v1/documents/{id}/document` | ElectronicDocument |  |

---

## 3. Cross-Layer Mirror Pairs (8 pairs)

Endpoints where the Business layer path is a structural mirror of a Domain layer path (same HTTP verb, same resource tail after stripping the `/api/<service>/v{n}` prefix and parameter names).

These are the highest-value targets for cross-layer contract testing per §3.4 of `NGPP_Test_Strategy.md` — verify that the Business response contains all Domain fields plus tenant-aware additions.

| Method | Business path | Business service | Domain path | Domain service |
|---|---|---|---|---|
| GET | `/api/practice-management/v1/access-point/{id}` | DQ.Foundational.Api.PracticeManagement | `/v1/access-point/{id}` | DQ.Foundational.ProviderApi |
| GET | `/api/practice-management/v1/business` | DQ.Foundational.Api.PracticeManagement | `/v1/business` | DQ.Foundational.ProviderApi |
| GET | `/api/practice-management/v1/business/{id}` | DQ.Foundational.Api.PracticeManagement | `/v1/business/{id}` | DQ.Foundational.ProviderApi |
| GET | `/api/practice-management/v1/practitioner` | DQ.Foundational.Api.PracticeManagement | `/v1/practitioner` | DQ.Foundational.ProviderApi |
| GET | `/api/practice-management/v1/practitioner/{id}` | DQ.Foundational.Api.PracticeManagement | `/v1/practitioner/{id}` | DQ.Foundational.ProviderApi |
| GET | `/api/product/v1/product-configuration/{id}` | DQ.Foundational.Api.Product | `/v1/product-configuration/{id}` | DQ.Foundational.Api |
| GET | `/api/practice-management/v1/service-location` | DQ.Foundational.Api.PracticeManagement | `/v1/service-location` | DQ.Foundational.ProviderApi |
| GET | `/api/practice-management/v1/service-location/{id}` | DQ.Foundational.Api.PracticeManagement | `/v1/service-location/{id}` | DQ.Foundational.ProviderApi |

> **Note:** the strict-mirror count is **8**, not the ~30 estimated earlier. Most Business endpoints either aggregate multiple Domain endpoints or transform the path in non-trivial ways. A loose-mirror analysis (Business endpoint X calls Domain endpoints {Y, Z, …} via Boomi or ALB) requires runtime tracing or code review and is outside the scope of static spec analysis.

---

## 4. Endpoints with Highest Test-Design Surface Area

Endpoints that take the most parameters — usually the highest-priority targets for negative testing and parameter-coverage matrices.

| Layer | Service | Method | Path | Path | Query | Header | Body | Required |
|---|---|---|---|---|---|---|---|---|
| Domain | DQ.Foundational.Api.Web | GET | `/Claims` | 0 | 11 | 1 |  | 1 |
| Domain | DQ.Foundational.Api.Web | GET | `/Claims/Paginated` | 0 | 11 | 1 |  | 1 |
| Domain | DQ.Foundational.MembershipApi | GET | `/v1/member/Fast` | 0 | 11 | 1 |  | 2 |
| Domain | DQ.Foundational.MembershipApi | GET | `/v1/member` | 0 | 11 | 1 |  | 2 |
| Domain | DQ.Foundational.ProviderApi | GET | `/v1/practitioner` | 0 | 11 | 1 |  | 1 |
| Business | DQ.Foundational.Api.Claim-Subm | GET | `/api/claim-submission/v1/business/{taxIdNumber}/claims/adjudicated/` | 1 | 9 | 1 |  | 3 |
| Domain | DQ.Foundational.Api.Web | GET | `/claims/claims-search-paginated` | 0 | 10 | 1 |  | 3 |
| Domain | DQ.Foundational.ProviderApi | GET | `/v1/service-location` | 0 | 10 | 1 |  | 1 |
| Business | DQ.Foundational.Api.Eligibilit | GET | `/api/eligibility/v1/member-coverage-search` | 0 | 9 | 1 |  | 2 |
| Domain | DQ.Foundational.Api.Web | GET | `/Claims/Search/All` | 0 | 9 | 1 |  | 1 |
| Domain | DQ.Foundational.MembershipApi | GET | `/v1/member/MemberCoverages` | 0 | 9 | 1 |  | 2 |
| Domain | DQ.Foundational.MembershipApi | GET | `/v1/member/contact-details` | 0 | 8 | 1 |  | 1 |
| Domain | DQ API External | GET | `/external/Member` | 0 | 9 | 0 |  | 0 |
| Domain | DQ API External | GET | `/external/v2/Member` | 0 | 9 | 0 |  | 0 |
| Domain | DQ API External | GET | `/external/v2/MultiMemberSearch` | 0 | 9 | 0 |  | 0 |
| Domain | DQ API V6 | GET | `/external/v6/MemberSearch` | 0 | 8 | 0 |  | 0 |
| Domain | DQ API V6 | GET | `/external/v6/Member-Login` | 0 | 8 | 0 |  | 0 |
| Domain | DQ.Foundational.MembershipApi | GET | `/v1/guardian` | 0 | 7 | 1 |  | 1 |
| Domain | DQ.Foundational.MembershipApi | GET | `/v1/authorization/authorized-members` | 0 | 7 | 1 |  | 1 |
| Domain | DQ API External | GET | `/external/SLmobileMemberSearch` | 0 | 8 | 0 |  | 0 |

---

## 5. Spec File Inventory

| Spec file | Layer | Service title | Endpoints |
|---|---|---|---|
| `GroupBenefit.json` | Domain | Foundational.Api.Benefits.Web | 1 |
| `benefit-summary-v5-swagger.json` | Domain | Foundational.Api.Benefits.Web | 1 |
| `billed-amounts-api-swagger.json` | Domain | Foundational.Api.BilledAmounts | 6 |
| `billed-amounts-business-service-api.json` | Business | DQ.BusinessService.Api.BilledAmounts | 6 |
| `business-service.json` | Business | BusinessService.Api | 4 |
| `case-management-api.json` | Business | case-management-api.json | 1 |
| `case-management-bussiness-service-apis.json` | Business | DQ.Foundational.Api.Case-Management | 8 |
| `claim-submission-api.json` | Business | DQ.Foundational.Api.Claim-Submission | 15 |
| `claims-api.json` | Domain | DQ.Foundational.Api.Web | 9 |
| `datahub-api-v6.json` | Domain | DQ API V6 | 18 |
| `digital-id-business-services-api.json` | Business | DQ.BusinessService.Api.Digital-Id | 8 |
| `digital-id-business-services-api_v1_5.json` | Business | DQ.BusinessService.Api.Digital-Id | 2 |
| `digital-id-media-business-services-api.json` | Business | DQ.BusinessService.Api.Digital-Id-Media | 1 |
| `electronic-document-api-swagger.json` | Domain | Foundational.Api.ElectronicDocuments | 3 |
| `eligibility-api.json` | Business | DQ.Foundational.Api.Eligibility.Web | 17 |
| `external-api.json` | Domain | DQ API External | 17 |
| `group-product-api-swagger.json` | Domain | DQ.Foundational.Api | 3 |
| `member-api-swagger.json` | Domain | DQ.Foundational.MembershipApi | 21 |
| `member-benefits-api.json` | Business | Foundational.Api.MemberBenefits.Web | 1 |
| `member-ivr-faxback-api.json` | Business | DQ.Foundational.Api.IVR-Faxback | 1 |
| `on-prem-datahub-v4.json` | Business | DQ API V4 | 11 |
| `on-prem-documents-api.json` | Business | DQ.SFDC.ProcessIntegration.Web | 34 |
| `practice-management-api.json` | Business | DQ.Foundational.Api.PracticeManagement | 23 |
| `product-api.json` | Business | DQ.Foundational.Api.Product | 1 |
| `provider-api-swagger.json` | Domain | DQ.Foundational.ProviderApi | 32 |
| `user-management-business-service-api.json` | Business | DQ.BusinessService.Api.User-Management | 4 |

> `case-management-api.json` is excluded — the file has malformed JSON (parse error at line 110, column 13). Coordinate with the Case Management team to fix the spec before regenerating.

---

*Last updated: 2026-05-06. Generated from the spec archives in `/uploads/business-service-apis.zip` and `/uploads/domain-service-apis.zip`. Pair with `NGPP_Test_Strategy.md` for the testing approach and `Canonical_Variable_Schema.md` for the pipeline-variable view.*