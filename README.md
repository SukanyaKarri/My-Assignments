# SaaS Growth & GTM Analytics – Data Analyst Assessment

## Overview
This project analyzes customer, subscription, and event data for a SaaS business to understand revenue performance, customer lifecycle behavior, churn, and growth bottlenecks.
I focused on:
Preserving factual integrity of the data
Using business-safe assumptions
Clearly documenting logic and limitations
Prioritizing insight over visual or technical complexity
The analysis combines SQL for core metrics, Python for validation, and Power BI for visualization.

## Tools Used
SQL Server (local environment) – data loading, cleaning, and metric computation
SQL logic is ANSI-compatible and portable to MySQL
Python (pandas) – lightweight data validation and sanity checks
Power BI – dashboard visualization
Note: NumPy and database connectors were not required as all metric calculations were performed in SQL and exported for visualization.

## Data Sources
customers.csv – customer master data
subscriptions.csv – subscription lifecycle and pricing
events.csv – customer lifecycle events

## Task 1: Data Loading & Cleaning

### Objective
Load raw CSV data, identify data quality issues, and apply minimal, business-safe cleaning without fabricating or distorting facts.

### Data Loading
All CSV files were loaded into a relational database.
Raw tables were preserved.
Cleaned tables were created separately to maintain lineage and auditability.

### Duplicate Analysis
Checks performed:
Primary key level (customer_id, subscription_id, event_id)
Full-record level (all columns)
Result:
No exact duplicate records found.
Repeated customer events (e.g., multiple signup or trial events) were validated as legitimate lifecycle behavior.
Rationale:
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
segment: NULL → 'Unknown'
Improves grouping while remaining transparent
signup_date: NULLs retained
Avoids fabricating customer history

**Subscriptions**
end_date: NULLs retained
Represents active subscriptions, not missing data
Derived field added:
subscription_status = ACTIVE / INACTIVE

**Events**
No cleaning required

**Key Principle:**
NULL ≠ bad data. NULL often represents "unknown" or "ongoing," which is meaningful in SaaS analytics.

## Task 2: Core SaaS Metrics

### Objective
Calculate and explain core SaaS performance metrics with consistent, business-aligned logic.

### Core Assumptions
A subscription contributes full revenue if active for at least one day in a month (no proration).
NULL end_date indicates an active subscription.
No forecasting or expansion revenue included.

### Metrics Calculated
**Monthly MRR**
Sum of monthly price for all active subscriptions per month

**ARR**
ARR = Monthly MRR × 12

**Customer (Logo) Churn Rate**
Customers active in the previous month but inactive in the current month

**Revenue Churn Rate**
Month-over-month lost MRR using LAG()
First month shows NULL by design (no prior comparison)

**Average Revenue per Customer (ARPC)**
Monthly MRR ÷ total customer count
NULL values produced by LAG() were preserved as expected time-series behavior.

## Task 3: Funnel Analysis
**Funnel Definition**
Signup → Trial → Activated → Paid → Churned

**Findings**
Largest drop-off occurs between Trial and Activated
Funnel progression is not strictly linear
Some users reach Paid without a clearly logged Activated event

**Interpretation**
This suggests onboarding friction or incomplete event tracking rather than data quality issues.

## Task 4: Dashboard

### Objective
Create a single dashboard focused on clarity and insight.

### Charts Included
1. Monthly MRR Trend
Shows rapid early growth followed by stabilization
2. Customer Funnel Conversion
Highlights Trial → Activation as the primary bottleneck
3. Customer Churn Overview
Churn stabilizes after early lifecycle, indicating strong post-activation retention
4. Customer Distribution by Segment
SMB dominates customer base
Enterprise and Mid-Market show lower penetration
'Unknown' segment highlights data enrichment opportunity

 **Power BI Dashboard Link:**
[https://app.powerbi.com/links/SqmLXlZrBC?ctid=ef1bdf02-1a23-40dc-a668-6beef7cffc4b&pbi_source=linkShare](https://app.powerbi.com/links/SqmLXlZrBC?ctid=ef1bdf02-1a23-40dc-a668-6beef7cffc4b&pbi_source=linkShare)

## Task 5: Insights & Recommendations

### Key Growth Bottlenecks
Significant drop-off between Trial and Activated
Funnel progression inconsistencies suggest activation tracking gaps

### Strongest & Weakest Customer Groups
SMB is the strongest segment by volume
Enterprise and Mid-Market underrepresented
Meaningful share of customers remain unclassified

### Churn Insights
Churn is concentrated early
Retention stabilizes once customers are activated

### What I Would Investigate Next
Trial user behavior and activation blockers
Segment-level MRR and churn contribution
Event tracking consistency between activation and payment

### Actionable Recommendations
**Improve trial-to-activation onboarding**
Focus on guided onboarding, in-app nudges, and early value delivery.

**Strengthen customer data enrichment**
Reduce the "Unknown" segment to enable better GTM targeting and analysis.

## Assumptions & Limitations
No revenue proration applied
No forecasting or expansion revenue modeled
Dashboard uses aggregated outputs, not raw event-level joins

## Instructions to Reproduce Results
Clone the repository.
Load CSV files from the data/ folder into a relational database.
Execute SQL scripts in order (sql/ folder).
(Optional) Run the Python validation script/notebook.
Open Power BI using exported metric tables or the provided dashboard link.
