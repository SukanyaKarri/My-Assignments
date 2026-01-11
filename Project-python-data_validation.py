"""
Purpose:
Initial data exploration and validation for the SaaS Growth & GTM Analytics assessment.
This script supports data quality checks for Tasks 1 ,2 & 3
"""

import pandas as pd

#load data
customers = pd.read_csv(r"E:\E drive\Python Practice\Udemy_DA_python\Assesment\customers.csv")
subscriptions = pd.read_csv(r"E:\E drive\Python Practice\Udemy_DA_python\Assesment\subscriptions.csv")
events = pd.read_csv(r"E:\E drive\Python Practice\Udemy_DA_python\Assesment\events.csv")

# Data Validation Check
customers.info()
subscriptions.info()
events.info()

# Missing value checks
customers.isna().sum()
subscriptions.isna().sum()
events.isna().sum()

#Funnel sanity check
events['event_type'].value_counts()

#Identifier uniqueness checks
customers['customer_id'].nunique()
subscriptions['subscription_id'].nunique()

print(customers.isna().sum())
print(subscriptions.isna().sum())
print(events.isna().sum())

print(events['event_type'].value_counts())

# Note: Script provided for validation logic, execution depends on local environment setup.
