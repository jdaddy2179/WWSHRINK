WINDWARD
========

Payment and Billing Run Process — Standard Operating Procedure
--------------------------------------------------------------

_Including New Business Implementations_
|  |  |
| --- | --- |
| **Department:** | Finance / Claims Operations |
| --- | --- |
| **Version:** | 2.0 |
| **Effective Date:** | March 25, 2026 |
| **Classification:** | Internal Use Only |
| **Supersedes:** | Payment and Billing Process for NBIs v1.0 |

* * *

1. Overview
-----------

This document provides a comprehensive, step-by-step guide to the Windward (WW2) payment and billing run process. It covers the complete lifecycle of a claim payment—from initial claim submission and repeater verification through payment execution, results capture, notification to the Oracle team, and billing runs. This SOP consolidates procedures from the original NBI (New Business Implementation) payment and billing process documentation with current operational practices.

> **SCOPE**
> This procedure applies to all claims processed through the Windward 2 (WW2) Payment system, including New Business Implementation environments. It is intended for Claims Analysts, Payment Processors, QA Testers, and Finance Operations staff.

* * *

2. Prerequisites
----------------

Before initiating the payment process, ensure the following requirements are met:
*   Active user credentials for the Windward 2 (WW2) Payment system
*   BeyondTrust access configured and approved for App Server connectivity
*   Proper role-based permissions to submit claims and execute payment runs
*   SQL Server Management Studio (SSMS) access to Windward_Payment_COM, Windward_Payment_COM, and Windward_Government databases
*   Access to the Oracle reporting channel or distribution list
*   RDP access to the appropriate App Server (see Environment List on SharePoint)
*   Familiarity with claim statuses and their definitions within the WW2 system

> **⚠ WARNING**
> Do not proceed with any payment processing steps unless all prerequisites above have been satisfied. Unauthorized access attempts will be logged and reported.

* * *

3. Process Flow Summary
-----------------------

The Windward payment and billing process consists of nine sequential steps. Each step must be completed and verified before advancing to the next:
| Step | Action | System | Owner |
| --- | --- | --- | --- |
| **1** | Submit Claim & Verify Payable Status | Claims System | Claims Analyst |
| **2** | Check Claims Repeaters | WW2 Payment DB | Claims Analyst |
| **3** | Confirm Claim Reported to WW2 Payment | WW2 Payment | Claims Analyst |
| **4** | Verify Open Payment Run & Run Date | WW2 Payment DB | Payment Processor |
| **5** | Verify Claim Exists in Open Payment Run | WW2 Payment DB | Payment Processor |
| **6** | Execute Payment Run on App Server | App Server / BeyondTrust | Payment Processor |
| **7** | Verify Completion & Capture Results | WW2 Payment / WW1 DB | Payment Processor |
| **8** | Send Payment Info to Oracle Team | Email / Ticketing | Finance Operations |
| **9** | Run Billing (If Applicable) | WW1 Database / CMS | Finance Operations |

### 3.1 Payment Claims Verification Query (Primary)

The following SQL query against the Windward_Payment_COM database is the primary tool for verifying claim status, payment run details, and payment cycle information throughout Steps 3–5. Run this in SSMS.

#### 3.1.1 Full Query

    USE Windward_Payment_COM
    
    SELECT DISTINCT
        Co.code,
        G.Group_Identifier,
        PCC.Claim_Number,
        PCC.Claim_Status,
        PRS.run_date,
        PRS.Payment_Run_Summary_GUID,
        G.Funding_Arrangement_Type,
        PCS.Payment_Cycle_Number,
        PCS.Payment_Cycle_Summary_GUID,
        PCS.Issued_Date,
        PCS.State,
        PCC.Assignment_Code,
        PCC.Amount,
        EOBS.EOB_Number,
        G.Group_Identifier,
        G.Group_Short_Name,
        EOBS.Explanation_Of_Benefit_Summary_GUID,
        EOBS.Payee_GUID,
        C.Payment_Type,
        C.Payment_Number,
        C.Payment_Status,
        EOBs.Amount
    FROM dbo.Payment_Cycle_Claim PCC
    JOIN dbo.Payment_Cycle_Summary PCS
        ON PCC.Payment_Cycle_Summary_GUID = PCS.Payment_Cycle_Summary_GUID
    JOIN dbo.Payment_Run_Summary PRS
        ON PRS.Payment_Run_Summary_GUID = PCS.Payment_Run_Summary_GUID
    JOIN dbo.Explanation_Of_Benefit_Summary EOBS
        ON PCC.Explanation_of_benefit_summary_guid
         = EOBS.Explanation_of_benefit_summary_guid
    JOIN info.[Group] G
        ON G.Group_GUID = PCC.Sub_Group_GUID
    JOIN dbo.Company Co
        ON G.Company_GUID = Co.Company_GUID
    LEFT JOIN dbo.[Check] C
        ON C.Explanation_Of_Benefit_GUID
         = EOBS.Explanation_Of_Benefit_Summary_GUID
    WHERE 1 = 1
        AND PCS.State = '1'
        -- AND PCC.Claim_Number < '2026031'
        -- AND PCC.Claim_Status <> 'R'
        -- AND PRS.Run_Date = '2025-12-30 00:00:00.000'
    ORDER BY PCC.Claim_Number ASC
    

#### 3.1.2 Common WHERE Clause Filters

| Filter Clause | Purpose | When to Use |
| --- | --- | --- |
| `PCC.Claim_Number = '<number>'` | Filter by specific claim | Verify a single claim |
| `PCC.Claim_Status <> 'R'` | Exclude rejected claims | Focus on active/payable claims |
| `PRS.Run_Date = 'YYYY-MM-DD'` | Filter to specific run date | Verify a particular run |
| `PCS.State = '1'` | Open cycles only (default) | Always active in base query |

#### 3.1.3 Key Output Fields Reference

| Field | Description | Used In |
| --- | --- | --- |
| PCC.Claim_Number | Unique claim identifier | Steps 3, 5 |
| PCC.Claim_Status | Claim status ('R' = Rejected) | Steps 1, 3, 5 |
| PCS.State | Payment cycle state ('1' = Open) | Steps 4, 5 |
| PRS.Run_Date | Date of the payment run | Steps 4, 6, 7 |
| PRS.Payment_Run_Summary_GUID | Unique ID for the payment run | Steps 4, 6 |
| PCS.Payment_Cycle_Number | Payment cycle reference number | Steps 5, 7 |
| PCC.Amount | Claim payment amount | Steps 5, 7, 8 |
| C.Payment_Type | Type of payment issued | Steps 7, 8 |
| C.Payment_Number | Check / payment reference number | Steps 7, 8 |
| C.Payment_Status | Current payment status | Step 7 |
| EOBS.EOB_Number | EOB reference | Step 8 |
| G.Group_Identifier | Group/account identification | Steps 5, 8 |
| Co.code | Company code | Step 8 |

#### 3.1.4 Database Schema Overview

| Table | Role |
| --- | --- |
| dbo.Payment_Cycle_Claim (PCC) | Claims within a payment cycle; claim number, status, amount |
| dbo.Payment_Cycle_Summary (PCS) | Payment cycle metadata: cycle number, issued date, state |
| dbo.Payment_Run_Summary (PRS) | Payment run details: run date, run GUID |
| dbo.Explanation_Of_Benefit_Summary (EOBS) | EOB records linking claims to payee info |
| info.[Group] (G) | Group/account info: identifier, funding arrangement |
| dbo.Company (Co) | Company code lookup |
| dbo.[Check] (C) | Payment instrument details (LEFT JOIN — may not yet exist) |

> **TIP**
> The [Check] table uses a LEFT JOIN because payment instrument records may not yet exist for claims included in a payment run but not yet processed. NULL values in C.Payment_Number indicate the payment has not been issued.

* * *

4. Detailed Procedures
----------------------

### STEP 1 — Submit Claim & Verify Payable Status

Submit the claim and confirm it is in a payable state. Claims in a pending status will not be repeated to WW2 Payment and cannot proceed through the pipeline.

#### 4.1.1 Procedure

1.  Navigate to the Claims Management module within the primary claims system.
2.  Locate the target claim using the claim number, claimant name, or policy number.
3.  Review the claim details to confirm all required documentation is attached and all approvals are in place.
4.  Submit the claim for payment processing.
5.  Verify the claim status has updated to a **payable** state. The status must **not** show as "Pending." Pending claims will not be repeated in WW2 Payment.
6.  If the status remains pending, investigate the hold reason and resolve before continuing.

#### 4.1.2 Validation Criteria

| Checkpoint | Expected Result | Action if Failed |
| --- | --- | --- |
| Claim Status | Payable / Approved | Review hold reason; resolve and resubmit |
| Documentation | All required docs attached | Request missing documents from claimant |
| Approval Chain | All approvals obtained | Escalate to appropriate supervisor |

* * *

### STEP 2 — Check Claims Repeaters

Before proceeding with payment runs (especially in New Business Implementation environments), verify that the Claims Repeaters are operational. The repeaters transfer claim data from the source claims system into the WW2 Payment database. If repeaters are not running, claims will never appear in WW2 Payment.

#### 4.2.1 Procedure

1.  After entering your first claim (Step 1), wait a few minutes for the repeater cycle to process.
    
2.  Run the following query against the Windward_Government database to confirm the claim was queued for replication:
    

    USE Windward_Government
    
    SELECT * FROM dbo.Claims_To_Repeat
    WHERE claim_number = '201927130615100' -- Replace with your claim number
    

3.  Run the following query against the WW2 Payment database to confirm the claim was received:

    USE Windward_Payment_COM
    
    SELECT * FROM dbo.Claim_Transaction
    WHERE claim_number = '201927130615100' -- Replace with your claim number
    

4.  Both queries must return results. Check the **Processed_Time** and **Date_Time_Created** columns — these timestamps should be close to your claim entry time.
    
5.  If either query returns no data, the repeaters may be down. Reach out to **Team Voltron** for investigation.
    
6.  Once repeaters are confirmed operational, proceed to enter the remaining claims per your scenarios.
    

> **⚠ WARNING**
> Pending claims will NOT be repeated to WW2 Payment. Always confirm the claim is in a payable/non-pending status before checking the repeater tables.

* * *

### STEP 3 — Confirm Claim REPEATED to WW2 Payment

Once claims are entered and repeaters are confirmed, verify that all claims have been successfully transmitted to the WW2 Payment system.

#### 4.3.1 Database Verification

Run the Payment Claims Verification Query (Section 3.1) to confirm the claim exists on the payment side. Filter by specific claim number:

    -- Add to WHERE clause:
    AND PCC.Claim_Number = '<YOUR_CLAIM_NUMBER>'
    

Key fields to check: PCC.Claim_Number (confirms claim exists), PCC.Claim_Status (should not be 'R'), and PCC.Amount (confirms correct payment amount).

#### 4.3.2 Troubleshooting

If the claim does not appear in WW2 Payment:
*   Verify the claim was submitted correctly and is not in a pending state (Step 1).
*   Check that the repeaters are running (Step 2).
*   Verify the data feed has run since submission.
*   Contact the IT integration team or Team Voltron if the claim remains absent.

* * *

### STEP 4 — Verify Open Payment Run & Run Date

Before a claim can be processed, there must be an active (open) payment run with a future run date. If the run date has already passed, you must execute that payment run first to advance the schedule to the next available date.

#### 4.4.1 Check Payment Run Date

Run the following query to ensure the payment Run_Date for your subgroups is in the future:

    USE Windward_Payment_COM
    
    SELECT * FROM dbo.Payment_Run_Summary PRS
    JOIN info.Group_Payment_Configuration_Detail GPCD
        ON GPCD.Payment_Cycle_Configuration_GUID
         = PRS.Payment_Cycle_Configuration_GUID
    JOIN info.[Group] G
        ON G.Group_GUID = GPCD.Group_GUID
    WHERE G.Group_Identifier IN ('6001422190') -- Replace with your subgroup
        AND PRS.Finalized = '0'
        AND PRS.Abandoned = '0'
    

> **⚠ WARNING**
> If the Run_Date is in the past, you must run payment for that date first (before entering claims) to advance the run date to the next available future date. See Step 6 for execution instructions.

#### 4.4.2 Verify Using Primary Query

You can also use the Payment Claims Verification Query (Section 3.1). The base query already filters by PCS.State = '1' (open). Check results for:
*   **PRS.Payment_Run_Summary_GUID** — Confirms a payment run exists.
*   **PRS.Run_Date** — Must be in the future for new claims.

> **NOTE**
> Payment runs are typically created on a predefined schedule (e.g., weekly or bi-weekly). Verify with your team lead if you are unsure of the current payment cycle schedule.

* * *

### STEP 5 — Verify Claim Exists in Open Payment Run

With an open payment run confirmed, verify that each claim has been included. Claims are matched to payment runs based on payable status, group configuration, and reporting date.

#### 4.5.1 Get Your Run Date & Payment Cycle Number

Run the following query after replacing the Sub Group Numbers and Claim Numbers:

    USE Windward_Payment_COM
    
    SELECT DISTINCT
        PCC.Claim_Number,
        PRS.run_date,
        PRS.Payment_Run_Summary_GUID,
        PCS.Payment_Cycle_Number,
        PCS.Payment_Cycle_Summary_GUID,
        PCS.Issued_Date,
        PCS.State,
        PCC.Assignment_Code,
        PCC.Amount,
        EOBS.EOB_Number,
        G.Group_Identifier
    FROM Windward_Payment_COM.dbo.Payment_Cycle_Claim PCC
    JOIN Windward_Payment_COM.dbo.Payment_Cycle_Summary PCS
        ON PCC.Payment_Cycle_Summary_GUID = PCS.Payment_Cycle_Summary_GUID
    JOIN Windward_Payment_COM.dbo.Payment_Run_Summary PRS
        ON PRS.Payment_Run_Summary_GUID = PCS.Payment_Run_Summary_GUID
    JOIN dbo.Explanation_Of_Benefit_Summary EOBS
        ON PCC.Explanation_of_benefit_summary_guid
         = EOBS.Explanation_of_benefit_summary_guid
    JOIN info.[Group] G
        ON G.Group_GUID = PCC.Sub_Group_GUID
    WHERE G.Group_Identifier IN
        ('6001852134','6001852135','6001852132','6001852133')
        -- Replace with your subgroup numbers
        AND PCS.State = '1'
        AND PCC.Claim_Number IN ('201935018974800','201921121122000')
        -- Replace with your claim numbers
    

Ensure you find ALL your claims in the results. If a claim is not listed here, it will NOT be part of the payment run.
Capture the **Run_Date** and **Payment_Cycle_Number** from the result set — you will need these for the payment execution step.

#### 4.5.2 Troubleshooting

If a claim is missing from the payment run:
*   Confirm the claim status is payable in both the source system and WW2.
*   Check whether the claim was reported after the payment run cutoff time.
*   Verify the repeaters processed the claim (Step 2).
*   If the claim should have been included but is absent, escalate to WW2 Payment support.

* * *

### STEP 6 — Execute Payment Run on App Server

This is the critical execution step. The payment run is triggered from the App Server via command line, requiring authenticated access through BeyondTrust.

> **⚠ WARNING**
> This step requires elevated privileges managed through BeyondTrust. Only authorized personnel with approved credentials may execute payment runs.

#### 4.6.1 Pre-Flight Check: Verify No Active Runs

Before starting a new payment run, confirm that no other run is currently in progress:

    USE Windward_Payment_COM
    
    SELECT * FROM dbo.Payment_Run_Request
    

Check the top rows. If any row shows **Finished = '0'**, a payment run is actively running. **Do NOT start another run.** Wait until it completes (Finished changes to '1'). Contact the user in User_Id_Requested for updates.

#### 4.6.2 Connect to App Server

1.  Launch BeyondTrust and authenticate using your assigned credentials.
2.  RDP into the App Server for your environment. Find the App Server name on the Environment List on SharePoint.
3.  Open the Command Prompt on the App Server.

#### 4.6.3 Navigate and Execute

Navigate to the WW2 payment directory:

    cd C:\Windward2\GOV\ConsoleApps\RunSchedule
    

Run the payment for your run date. Use the exact date format shown:

    DQ.Payment.RunSchedule.exe Auto 2021-10-15
    -- Replace the date with your Run_Date from Step 5
    

> **⚠ WARNING**
> Do NOT start a new payment run while another run is in progress. Do NOT close the Command Prompt until all runs are finalized.

#### 4.6.4 Monitor Progress

Monitor progress by running the following query in SSMS:

    USE Windward_Payment_COM
    
    SELECT * FROM dbo.Payment_Run_Summary
    WHERE Run_Date = '2019-07-12 00:00:00.000'
    -- Replace with your Run_Date from Step 5
    

The run is complete when all rows show **Finalized = '1'** and there are **no NULLs** in the Finished_Finalizing column.

#### 4.6.5 Security Requirements

| Requirement | Details |
| --- | --- |
| Access Tool | BeyondTrust (required for all App Server connections) |
| Authentication | Multi-factor authentication via BeyondTrust credentials |
| Authorization | Role-based; only approved Payment Processors |
| Session Logging | All BeyondTrust sessions are recorded for audit |
| Environment Lookup | App Server names on SharePoint Environment List |

* * *

### STEP 7 — Verify Completion & Capture Results

After the payment run completes, verify successful finalization and capture results for reporting and audit.

#### 4.7.1 Verify Finalization

1.  Re-run the Payment_Run_Summary query from Step 6.4.
2.  Confirm all rows show **Finalized = '1'** with no NULLs in Finished_Finalizing.
3.  Review for any errors, exceptions, or partially processed claims.

#### 4.7.2 Get Check Production Run Log IDs

Run the following query on the Windward_Government (WW1) database to obtain the Check Prod Run Log GID and PKID:

    USE Windward_Government
    
    SELECT
        CPRL.check_prod_run_log_gid,
        CPRL.Check_Prod_Run_Log_PKID,
        PC.*
    FROM dbo.Check_Prod_Run_Log CPRL
    JOIN dbo.Payment_Cycle PC
        ON PC.check_prod_run_log_pkid = CPRL.Check_Prod_Run_Log_PKID
    WHERE CPRL.cycle_eff_date_time = '2019-07-12 00:00:00.000'
        -- Replace with your Run_Date
        AND PC.payment_cycle_gid IN (207529)
        -- Replace with your Payment_Cycle_Number from Step 5
    

Capture the **check_prod_run_log_gid** (GID) and **Check_Prod_Run_Log_PKID** (PKID) — needed for result queries below.

#### 4.7.3 Capture Check Run Summary

Replace the GID and PKID values and run on the WW1 database:

    USE Windward_Government
    
    SELECT
        check_prod_run_log_gid AS 'Check Run #',
        cprl.run_start_date_time AS 'Payment Run Date',
        CONVERT(VARCHAR(10), cycle_eff_date_time, 110) AS 'Cycle Date',
        SUM(tot_checks_count) AS 'Check Count',
        SUM(tot_transaction_count) AS 'Transaction Count',
        SUM(tot_eob_count) AS 'EOB Count',
        SUM(tot_transaction_amount) AS 'Total Check Run Amount',
        SUM(tot_begin_rolling_bal_amount)
            - SUM(tot_end_rolling_bal_amount) AS 'Change in Rolling Balance',
        CASE
            WHEN payment_type = 'F' THEN 'FFS'
            WHEN payment_type = 'C' THEN 'CAP'
            ELSE '???'
        END AS 'Cycle Type'
    FROM dbo.Check_Prod_Run_Log cprl WITH (NOLOCK)
    WHERE cprl.check_prod_run_log_gid = 26436 -- Change this GID
        AND cprl.check_prod_run_log_pkid = 23324 -- Change this PKID
    GROUP BY cprl.check_prod_run_log_gid,
        cprl.cycle_eff_date_time,
        cprl.payment_type,
        cprl.run_start_date_time
    ORDER BY cprl.check_prod_run_log_gid DESC
    

#### 4.7.4 Capture Payment Cycle Detail by Group

Replace GID, PKID, and Sub Group IDs. Capture results and share with the team:

    USE Windward_Government
    
    SELECT
        payment_cycle_gid AS 'Payment Cycle',
        group_id AS 'Group Id',
        group_name AS 'Group Name',
        total_paid_amount AS 'Total Paid Amount',
        CONVERT(VARCHAR(11), pc.date_time_created) AS 'Date Created',
        CONVERT(VARCHAR(11), issued_date) AS 'Issue Date',
        pc.payment_cycle_pkid AS 'Payment Cycle PKID'
    FROM Payment_Cycle pc WITH (NOLOCK)
    INNER JOIN Payment_Cycle_Group_Log pcgl WITH (NOLOCK)
        ON pc.payment_cycle_pkid = pcgl.payment_cycle_PKID
    INNER JOIN Groups gr WITH (NOLOCK)
        ON pcgl.groups_PKID = gr.Groups_PKID
    INNER JOIN dbo.Check_Prod_Run_Log cprl
        ON cprl.Check_Prod_Run_Log_PKID = pc.check_prod_run_log_pkid
    WHERE cprl.check_prod_run_log_gid = 26436 -- Change this GID
        AND cprl.check_prod_run_log_pkid = 23324 -- Change this PKID
        AND gr.group_id IN ('7003682002') -- Your Subgroup IDs
    GROUP BY gr.group_id, gr.group_name,
        pc.payment_cycle_gid, pc.total_paid_amount,
        pc.issued_date, pc.payment_cycle_pkid,
        pc.date_time_created
    ORDER BY gr.group_id ASC
    

#### 4.7.5 Completion Checklist

| Verification Item | Status | Notes |
| --- | --- | --- |
| All payment runs finalized (Finalized = 1) | ☐ |  |
| No NULLs in Finished_Finalizing column | ☐ |  |
| All claims processed without errors | ☐ |  |
| Total payment amount matches expected total | ☐ |  |
| Check Run Summary captured (Section 4.7.3) | ☐ |  |
| Payment Cycle Detail captured (Section 4.7.4) | ☐ |  |
| Results shared with team | ☐ |  |

* * *

### STEP 8 — Send Payment Info to Oracle Team

Communicate the completed payment run details to the Oracle team so financial records can be updated.

#### 4.8.1 Procedure

1.  Compile the payment run summary from WW2 Payment, including Payment Run ID, total amount, claim count, and processing date.
2.  Include the Check Run Summary and Payment Cycle Detail results captured in Step 7.
3.  Export or generate the payment details file as required (CSV, Excel, or standardized report).
4.  Send via the established communication channel (email distribution list, ticketing system, or shared file repository).
5.  Include any notes regarding exceptions, errors, or manually adjusted claims.
6.  Confirm receipt from the Oracle team and retain a copy for audit.

#### 4.8.2 Required Information for Oracle

*   Payment Run ID and Run Date
*   Total number of claims processed
*   Total payment amount
*   Check Run Summary (Check Count, Transaction Count, EOB Count, Total Amount)
*   Payment Cycle Detail by Group (Group ID, Total Paid Amount, Issue Date)
*   Breakdown by payment/cycle type (FFS vs. CAP) if applicable
*   List of any exceptions or errors encountered

* * *

### STEP 9 — Run Billing (If Applicable)

After the payment run is complete, a billing run may be required depending on the subgroup's billing configuration. Client Claims billing uses the same run date as the payment run. If the subgroup does not have Client Claims billing, you may need to run Admin Billing instead.

#### 4.9.1 Find Billing Run Date

For Client Claims billing, use the same run date from your payment run (Step 5). For Admin Billing or to verify the billing schedule:
1.  Search for the subgroup in CMS (Configuration Management System).
2.  Right-click the SubGroup node and select 'DrillDown.'
3.  Scroll down to Billing and Reconciliation.
4.  Open the Billing Parameter Assignment (right-click → 'Modify' or 'View').
5.  The Next Active Run Date will be displayed on the screen.

#### 4.9.2 Determine Group Hierarchy GIDs

Run the following query to get group hierarchy GID values needed for the billing stored procedure:

    USE Windward_Government
    
    SELECT GH.* FROM dbo.GroupHierarchy GH
    JOIN dbo.Sub_Group SG
        ON SG.Sub_Group_GID = GH.sub_group_gid
    WHERE SG.Sub_Group_ID IN ('7003682002') -- Replace with your Sub Group IDs
        AND SG.Record_Status = 'A'
        AND SG.Sub_Group_Status = '01'
    

#### 4.9.3 Execute Billing

Execute the billing stored procedure in SSMS. Choose the appropriate level:
**At Subgroup Level:**

    USE Windward_Government
    
    EXEC prbarbilling_process
        @i_run_date = '05/20/2021 18:00:00',
        @i_precheck_mode = 0,
        @i_subgroup_gid = 179251,
        @i_skip_precheck_next_bill_run = 1
    

**At Group Level:**

    USE Windward_Government
    
    EXEC prbarbilling_process
        @i_run_date = '02/05/2021 18:00:00',
        @i_precheck_mode = 0,
        @i_group_gid = 181027,
        @i_skip_precheck_next_bill_run = 1
    

**At Purchaser Level:**

    USE Windward_Government
    
    EXEC prbarbilling_process
        @i_run_date = '02/05/2021 18:00:00',
        @i_precheck_mode = 0,
        @i_purchaser_gid = 436,
        @i_skip_precheck_next_bill_run = 1
    

Wait until the run completes. SSMS will display a completion message when finished.

> **TIP**
> If the billing run seems to be taking an unusually long time, check the invoice_error table for any errors that may be blocking the process.

#### 4.9.4 Capture Billing Results

Run the following query to capture billing run results. The top row of the result set should correspond to your most recent billing run:

    USE Windward_Government
    
    IF OBJECT_ID('tempdb..#Billing_Cycle_Type') IS NOT NULL
        DROP TABLE #Billing_Cycle_Type
    
    CREATE TABLE #Billing_Cycle_Type (
        brl_gid INT,
        cycle_type VARCHAR(10)
    )
    
    INSERT INTO #Billing_Cycle_Type
    SELECT DISTINCT i.billing_run_log_gid,
        CASE
            WHEN i.bill_type_id IN (1,2,3) THEN 'Client'
            WHEN i.bill_type_id IN (4,5) THEN 'Individual'
            ELSE CONVERT(VARCHAR(10), i.bill_type_id)
        END
    FROM dbo.Invoice i
    WHERE i.invoice_gid > 0
        AND i.subgroup_invoice_gid > 0
        AND i.record_status = 'A'
    
    SELECT TOP 2
        i.billing_run_log_gid AS 'BRL GID',
        CONVERT(VARCHAR(10), i.inv_process_date, 110) AS 'Run Date',
        SUM(i.claims_total_count) AS 'Claim Count',
        SUM(i.treatment_total_amount) AS 'Claim $',
        SUM(i.claims_tax_total_amount) AS 'Claim Tax',
        SUM(i.admin_total_amount) AS 'Non-PMPM Admin $',
        SUM(i.continuing_census_count) AS 'Current Membership Count',
        SUM(i.current_census_total) AS 'Current Admin $',
        SUM(i.added_member_retro_total
            + i.termed_member_retro_total) AS 'Retro $',
        SUM(i.transaction_type_e_total
            + i.transaction_type_m_total
            + i.transaction_type_p_total) AS 'Misc. Transactions',
        SUM(i.treatment_total_amount + i.premium_total_amount
            + i.admin_total_amount + i.claims_tax_total_amount
            + i.transaction_type_e_total + i.transaction_type_m_total
            + i.transaction_type_p_total) AS 'Current Activity Total',
        COUNT(DISTINCT(invoice_gid)) AS 'Invoice Count',
        MIN(invoice_gid) AS 'Invoice # Start',
        MAX(invoice_gid) AS 'Invoice # End',
        bc.cycle_type AS 'Cycle Type'
    FROM #Billing_Cycle_Type bc
    INNER JOIN dbo.Invoice i
        ON i.billing_run_log_gid = bc.brl_gid
        AND i.invoice_gid > 0
        AND i.subgroup_invoice_gid > 0
        AND i.record_status = 'A'
    GROUP BY i.billing_run_log_gid,
        i.inv_process_date,
        bc.cycle_type
    ORDER BY i.billing_run_log_gid DESC
    
    IF OBJECT_ID('tempdb..#Billing_Cycle_Type') IS NOT NULL
        DROP TABLE #Billing_Cycle_Type
    

* * *

5. Revision History
-------------------

| Version | Date | Author | Changes |
| --- | --- | --- | --- |
| 1.0 | Original | [Original Author] | Initial NBI payment and billing process documentation |
| 2.0 | March 25, 2026 | [Author Name] | Consolidated NBI SOP with current procedures; added primary verification query, repeater checks, expanded result capture, billing section, glossary |

* * *

6. Appendix
-----------

### 6.1 Glossary

| Term | Definition |
| --- | --- |
| WW2 Payment | Windward 2 Payment system; platform for managing and executing payment runs. |
| WW1 / Windward_Government | The original Windward database containing check production logs, payment cycles, billing, and group data. |
| Payment Run | Batch processing event where multiple approved claims are grouped and paid. |
| Payment Cycle | Specific cycle within a payment run, identified by Payment_Cycle_Number. |
| Claims Repeaters | Automated processes that replicate claim data from the source system into WW2 Payment. |
| BeyondTrust | Privileged access management (PAM) tool for secure App Server connections. |
| App Server | Application server where payment runs are executed via command line. |
| Oracle Team | Finance/accounting team responsible for recording payments in Oracle ERP. |
| Payable Status | Claim status indicating full approval and eligibility for payment. |
| Finalized | Payment run status flag (0 = in progress, 1 = complete). |
| FFS / CAP | Fee-For-Service and Capitation — the two primary payment cycle types. |
| Check Prod Run Log | WW1 table tracking check production runs with GID and PKID identifiers. |
| CMS | Configuration Management System — used to view subgroup billing parameters. |
| Team Voltron | Internal team responsible for claims repeater infrastructure and support. |

### 6.2 Contact Information

| Team / Role | Contact Method | Responsibility |
| --- | --- | --- |
| Claims Operations | [Email / Extension] | Claim submission & status inquiries |
| Payment Processing | [Email / Extension] | Payment run execution & verification |
| Team Voltron | [Email / Extension] | Claims repeater issues & support |
| IT Integration Team | [Email / Extension] | Data feed issues between systems |
| WW2 Support | [Email / Extension] | WW2 system issues & troubleshooting |
| Oracle Finance Team | [Email / Distribution List] | Payment recording & reconciliation |
| BeyondTrust Admin | [Email / Extension] | Credential & access management |

### 6.3 Environment Reference

App Server names for each environment can be found on the SharePoint Environment List:
_SharePoint > Corporate Information Services > Lists > Windward Environments_
Payment execution command path on App Server:

    C:\Windward2\GOV\ConsoleApps\RunSchedule\DQ.Payment.RunSchedule.exe