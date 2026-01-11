# My-Assignments

Task 1 – Data Loading & Cleaning

• Data loaded into SQL Server due to local MySQL constraints; SQL is ANSI-compatible.
• Raw data preserved; cleaning applied only in derived tables.
• No duplicate identifiers found.
• Customers:
  - signup_date NULLs retained (legacy/unknown).
  - segment NULLs replaced with 'Unknown'.
• Subscriptions:
  - NULL end_date treated as active subscription.
• Events contained no data quality issues.
