# SaaS Growth & GTM Analytics – Assessment
## Repository Structure

My-Assignments/

├── data/  
│   ├── customers.csv  
│   ├── subscriptions.csv  
│   └── events.csv  
│  
├── python/  
│   └── Project-python-data_validation.py  
│  
├── sql/  
│   ├── Assignment.sql  
│   │   (Contains table creation, data cleaning, core SaaS metrics, and funnel analysis queries)  
│   ├── MRR.csv  
│   ├── ARR.csv  
│   ├── Customer (Logo) Churn Rate.csv  
│   ├── Revenue Churn Rate.csv  
│   ├── Average Rate of Churn Per customer (ARPC).csv  
│   ├── Funnel_analysis.csv  
│   └── Funnel conversion rates.csv  
│  
├── dashboard/  
│   ├── Dashboard_updated.png 
│   └── dashboard_link.txt  
│  
└── README.md


## Overview
This project analyzes customer, subscription, and event data for a SaaS business to understand revenue performance, customer lifecycle behavior, churn, and growth bottlenecks.
I focused on:
- Preserving factual integrity of the data
- Using business-safe assumptions
- Clearly documenting logic and limitations
- Prioritizing insight over visual or technical complexity
The analysis combines SQL for core metrics, Python for validation, and Power BI for visualization.

## Tools Used
SQL Server (local environment) – data loading, cleaning, and metric computation
SQL logic is ANSI-compatible and portable to MySQL
Python (pandas) – lightweight data validation and sanity checks
Power BI – dashboard visualization
Note: NumPy and database connectors were not required as all metric calculations were performed in SQL and exported for visualization.

## Data Sources
- customers.csv – customer master data
- subscriptions.csv – subscription lifecycle and pricing
- events.csv – customer lifecycle events

## Task 1: Data Loading & Cleaning

### Objective
Load raw CSV data, identify data quality issues, and apply minimal, business-safe cleaning without fabricating or distorting facts.

### Data Loading
- All CSV files were loaded into a relational database.
- Raw tables were preserved.
- Cleaned tables were created separately to maintain lineage and auditability.

### Duplicate Analysis
Checks performed:
- Primary key level (customer_id, subscription_id, event_id)
- Full-record level (all columns)

 **Result:**
- No exact duplicate records found.
- Repeated customer events (e.g., multiple signup or trial events) were validated as legitimate lifecycle behavior.

 **Rationale:**
Customer journeys are not linear; repeated actions represent real behavior and should not be deduplicated.

### Missing Values – Quantified Findings
**Customers (1000 records)**
signup_date: 36 NULLs
segment: 243 NULLs

**Subscriptions (941 records)**
end_date: 718 NULLs

**Events (2411 records)**
No missing values

### Cleaning Decisions & Business Rationale
**Customers**
- segment: NULL → 'Unknown'
- Improves grouping while remaining transparent
- signup_date: NULLs retained (Avoids fabricating customer history)

**Subscriptions**
end_date: NULLs retained
Represents active subscriptions, not missing data
Derived field added:
subscription_status = ACTIVE / INACTIVE

**Events**
No cleaning required

**Key Principle:**
NULL is not equal to bad data. NULL often represents "unknown" or "ongoing," which is meaningful in SaaS analytics.

## Task 2: Core SaaS Metrics

### Objective
Calculate and explain core SaaS performance metrics with consistent, business-aligned logic.

### Core Assumptions
- A subscription contributes full revenue if active for at least one day in a month (no proration).
- NULL end_date indicates an active subscription.
- No forecasting or expansion revenue included.

### Metrics Calculated
**Monthly MRR**
Sum of monthly price for all active subscriptions per month

**ARR**
ARR = Monthly MRR × 12

**Customer (Logo) Churn Rate**
- Customers active in the previous month but inactive in the current month

**Revenue Churn Rate**
- Month-over-month lost MRR using LAG()
- First month shows NULL by design (no prior comparison)

**Average Revenue per Customer (ARPC)**
- Monthly MRR dived by total customer count
- NULL values produced by LAG() were preserved as expected time-series behavior.

## Task 3: Funnel Analysis
**Funnel Definition**
- Signup → Trial → Activated → Paid → Churned

**Findings**
- Largest drop-off occurs between Trial and Activated
- Funnel progression is not strictly linear
- Some users reach Paid without a clearly logged Activated event

**Interpretation**
- This suggests onboarding friction or incomplete event tracking rather than data quality issues.

## Task 4: Dashboard

**1. Monthly MRR Trend**
- Shows month-over-month recurring revenue growth and decline.
- Highlights rapid growth in early months followed by stabilization.
- Used to assess overall revenue momentum and retention impact.

**2. Customer Funnel Conversion**
- Visualizes the full customer journey: Signup → Trial → Activated → Paid → Churned.
- Clearly shows the largest drop-off occurring between Trial and Activated.
- Used to identify onboarding and activation bottlenecks.

**3. Customer Churn Overview**
- Displays customer churn rate over time.
- Churn stabilizes after the initial period, indicating strong retention post-activation.
- Used to separate early lifecycle issues from long-term retention risk.
- Customer churn remains stable across observed months, indicating that once customers are onboarded, retention is strong

**4. Customer Distribution by Segment**
- Breaks down customers across SMB, Enterprise, Mid-Market, and Unknown segments.
- SMB dominates the customer base, while Enterprise adoption remains lower.
- Used to guide go-to-market and targeting strategy.


 **Power BI Dashboard Link:**
[https://app.powerbi.com/links/SqmLXlZrBC?ctid=ef1bdf02-1a23-40dc-a668-6beef7cffc4b&pbi_source=linkShare](https://app.powerbi.com/links/SqmLXlZrBC?ctid=ef1bdf02-1a23-40dc-a668-6beef7cffc4b&pbi_source=linkShare)

## Task 5: Insights & Recommendations

## Tasks in brief:
- Analyzed customer lifecycle data using SQL to calculate core SaaS metrics (MRR, churn, funnel conversion).
- I visualized the results in a single dashboard to understand revenue trends, customer drop-offs, churn behavior, and segment distribution,focusing on clarity and business meaning

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

## What I would investigate next
- Why many users reach Paid without a clearly logged Activated event?
- Trial user behavior (time spent, feature usage) to understand why activation drops.
- Segment-level churn and MRR contribution to see which segments drive sustainable revenue, not just volume.

## Actionable recommendations for leadership
- Improve trial-to-activation onboarding
- Focus on guided onboarding, product walkthroughs, or in-app nudges during the trial phase to reduce early drop-off.
- Strengthen customer data enrichment
- Reduce the "Unknown" segment by capturing segment information earlier, enabling better targeting and GTM decisions.
