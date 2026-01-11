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
 **Customers (1000 records)**
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

**Task 2** Core SaaS Metrics (MRR,ARR,Customer Churn , Revenue Churn Rate, Average Revenue per customer)
- All metrics were calculated using consistent active-subscription logic, with clearly documented assumptions to ensure business interpretability and auditability.”
- Ref file : 

**Objective**
- To calculate key SaaS performance metrics using subscription data and clearly explain the business logic behind each metric. The focus was on interpretability, consistency, and business realism, rather than over-engineering.

**Environment Note**
- SQL Server was used locally due to environment constraints.
- All queries are written using ANSI-compatible logic and are directly portable to MySQL with minor syntax changes (e.g., date functions).

**Core Assumptions (Applied Consistently)**
- A subscription contributes full monthly revenue if it is active for at least one day in a given month (no proration).
- A subscription with a NULL end_date is considered ongoing (active).
- Business logic prioritises correctness and interpretability over synthetic data completion.

**Metrics Calculated & Business Rationale**
- **1. Monthly MRR (Monthly Recurring Revenue)**
- **What:**  Sum of monthly prices of all subscriptions active in a given month.
- **Why:**  MRR represents predictable, recurring revenue and is the foundation for all other SaaS metrics.
- **Logic:** A subscription is included if: start_date ≤ month end end_date is NULL or ≥ month start

**2.ARR (Annual Recurring Revenue)**
- **What:** Annualised recurring revenue.
- **Why:** Provides a standardised, annual view of business scale.
- **Logic:** ARR = Monthly MRR × 12 (No growth or churn forecasting applied.)

**Customer (Logo) Churn Rate**
- **What:** Percentage of customers lost month-over-month.
- **Why:** Measures customer retention independently of revenue size.
- **Logic:** A customer is churned if: They had ≥1 active subscription in the previous month and They have no active subscriptions in the current month

**Revenue Churn Rate**
- **What:** Percentage of recurring revenue lost compared to the previous month.
- **Why:** Captures the financial impact of churn, not just customer count.
- **Logic:** Calculated using LAG() on Monthly MRR , Only lost MRR is considered (no expansion or upsell included)

**Note on NULL values appeared while working with LAG:**
- The first month has NULL revenue churn because there is no prior month for comparison.
- This is expected behavior and indicates correct time-series logic, not missing data.

**Average Revenue per Customer (ARPC)**
- **What:** Average recurring revenue per customer.
- **Why:** Provides a high-level view of monetisation efficiency across the entire customer base.
- **Logic:** ARPC = Monthly MRR ÷ Total number of customers (A stable denominator was used to avoid volatility from month-to-month activity changes)

**Key Principles Followed**
- Time-aware metrics: Month-over-month comparisons were explicitly modeled.
- Business-meaningful NULLs: NULL values were preserved where they represent “not applicable” (e.g., first month in LAG).
- Simplicity over complexity: No proration, forecasting, or expansion logic was added as it was outside scope

# Task 5: Insights & Recommendations README

## Tasks in breif
I analyzed customer lifecycle data using SQL to calculate core SaaS metrics (MRR, churn, funnel conversion).
I visualized the results in a single dashboard to understand revenue trends, customer drop-offs, churn behavior, and segment distribution, Focusing on clarity and business meaning

## Key growth bottlenecks
- The largest drop-off occurs between Trial and Activated, indicating users start trials but fail to fully activate.
- Despite a high number of paid users, activation is comparatively low, suggesting timing or event-tracking gaps between activation and payment.
- Funnel progression is not strictly linear, which may indicate data timing mismatches or users converting to paid without a clearly logged activation event.

## Strongest and weakest acquisition / customer groups
- SMB segment represents the largest portion of customers, indicating strong traction in smaller businesses.
- Enterprise and Mid-Market segments are smaller, suggesting either lower acquisition focus or higher entry friction.
- The 'Unknown' segment still represents a meaningful share, highlighting gaps in customer classification.

## Churn insights
- Customer churn stabilizes after the initial period, with near-zero churn in later months.
- This suggests strong retention once customers are onboarded, making early-stage conversion more critical than long-term retention.

## What to investigate next
- Why many users reach Paid without a clearly logged Activated event?
- Trial user behavior (time spent, feature usage) to understand why activation drops.
- Segment-level churn and MRR contribution to see which segments drive sustainable revenue, not just volume.

## Actionable recommendations for leadership
- Improve trial-to-activation onboarding
- Focus on guided onboarding, product walkthroughs, or in-app nudges during the trial phase to reduce early drop-off.
- Strengthen customer data enrichment
- Reduce the "Unknown" segment by capturing segment information earlier, enabling better targeting and GTM decisions.

