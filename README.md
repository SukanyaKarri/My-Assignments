# My-Assignments

**Task 1 Requirement**
- Load all CSV files into MySQL
- Identify data quality issues

-- Handle:
- Duplicate records
- Missing values
- Inconsistent or conflicting events
- Clearly document assumptions in SQL comments and/or README

****-- Objective**
To load raw CSV data, assess data quality, and apply minimal, business-safe cleaning while preserving factual integrity and avoiding fabricated or misleading data. The goal was clarity and trustworthiness, not cosmetic perfection.

**--Data Loading**
- All CSV files (customers, subscriptions, events) were loaded into a relational database.
- SQL Server was used locally due to environment constraints; all SQL logic is ANSI-compatible and directly portable to MySQL (e.g., LOAD DATA INFILE, CREATE TABLE AS SELECT equivalents).
- Raw source data was not overwritten; cleaned outputs were written to derived tables.

****Data Profiling & Quality Findings**
**- Duplicate Records****

**Checks performed:**
- Primary identifier level (customer_id, subscription_id, event_id)
- Full-record level (grouping across all columns)
****Result:**
- No exact duplicate records were detected in any table.
- Repeated events per customer (e.g., multiple signup or trial_start events) were reviewed and confirmed as legitimate business events, not data duplication.
**Context- Reason behind the logic:**
- A customer can perform the same action multiple times across their lifecycle. Treating these as duplicates would incorrectly remove valid behavioral data.

****** Missing Values — Quantified Findings******
- **Customers (1000 records)**
| Column      | NULL Count | Business Interpretation                               |
| ----------- | ---------- | ----------------------------------------------------- |
| customer_id | 0          | Mandatory identifier                                  |
| signup_date | 36         | Historical / legacy users where date was not captured |
| segment     | 243        | Customers not yet classified into a segment           |

**Subscriptions (941 Records)**
| Column          | NULL Count | Business Interpretation            |
| --------------- | ---------- | ---------------------------------- |
| subscription_id | 0          | Mandatory identifier               |
| customer_id     | 0          | Relationship intact                |
| start_date      | 0          | Subscription start known           |
| end_date        | 718        | Subscription has **not ended yet** |

Events(2411)
| Column      | NULL Count |
| ----------- | ---------- |
| event_id    | 0          |
| customer_id | 0          |
| event_type  | 0          |
No missing values were detected in the events dataset.

**Cleaning Decisions & Business Rationale**
- **Customers**
**-- segment**
  -- Action: NULLs replaced with 'Unknown'
  -- Rationale: Segment is a categorical label. Replacing NULL improves reporting and grouping while remaining transparent about classification status.

**-signup_date**
- Action: NULLs intentionally retained
- Rationale: Signup date is a factual timestamp. Imputing or defaulting values would fabricate customer history and distort tenure, cohort, and lifecycle analysis
**Context- Reason behind the logic:**
- It is safer to say “we don’t know when this customer signed up” than to invent a date that could mislead decision-makers.

**Subscriptions**

**-- end_date**
- Action: NULLs retained
- Rationale: A NULL end_date semantically represents an ongoing (active) subscription, not missing data.

**Derived Field Added**
**-- subscription_status:**
- ACTIVE → end_date IS NULL
- INACTIVE → end_date IS NOT NULL
**Context- Reason behind the logic:**
A customer is only churned when an end date exists. Until then, the relationship is still active. NULL here communicates “not ended yet,” not “unknown.”
**--Events**
-No cleaning was required.
- Repeated event types for the same customer were validated as normal lifecycle transitions (e.g., signup → trial → activation).
**Key Principles Followed**
- NULL does not mean bad data — it often means unknown, not applicable, or ongoing.
- Fabricating values (e.g., using 0 or default dates) introduces analytical and audit risk.
- Only categorical fields were normalized; factual timestamps were preserved.
- Business meaning was made explicit through derived fields rather than altering raw facts.--
-- Note on SQL Dialect:

