


----- Every table and column in the saas schema
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'saas'
ORDER BY table_name, ordinal_position;

----- Approximate row counts

SELECT relname AS table_name, n_live_tup AS approx_row_count
FROM pg_stat_user_tables
WHERE schemaname = 'saas'
ORDER BY n_live_tup DESC;

----- Declared foreign keys

SELECT tc.table_name, kcu.column_name,
       ccu.table_name AS foreign_table_name,
       ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'saas';
	   
	   

----1. Accounts

Grain         : One row= one account/Customer
Row count     : 1250
Purpose       : Stores information about each customer/company account using the SaaS product.
PK            : account_id

----2. email_sends

Grain         : one row = email send to its Customer
Row count     : 3385
Purpose       : Tracks the different campaigns sent to users and their engagement with those communications.
PK            : send_id
FK            : user_id

----3. events

Grain         :One row = one event/action performed by one user.
Row count     : 53534
Purpose       : Tracks user activities/events performed within the SaaS product.
PK            : event_id
FK            : user_id, account_id

----4. experiment_assignments

Grain         : One row = one user assigned to one experiment variant.
Rowcount      : 3200 
Purpose       : Tracks which users are assigned to which experiment and variant for A/B testing.
PK            : assignment_id
FK            : user_id, variant_id, experiment_id


----5. experiments_variants

Grain         : One row = one variant within one experiment.
Rowcount      : 8
Purpose       : Defines the variants/groups within each product experiment, including their allocation and control status.
PK            : variant_id
FK            : experiment_id


----6. experiements

Grain        : One row = one experiment.
Rowcount     : 4
Purpose      : Stores the definition, timing, hypothesis, owner, and status of each product experiment.
PK           : experiment_id


----7. features

Grain        : One row = one product feature.
Rowcount     : 50
Purpose      : Stores the list of product features, their categories, and release dates.
PK           : feature_id       

----8. invoices

Grain        : One row = one invoice/billing record.
Rowcount     : 4201
Purpose      : Stores invoices generated for customer subscriptions, including amounts, billing dates, and payment status.
Pk           : invoice_id
FK           : user_id, account_id, subscription_id

-----9. Legacy_companies

Grain        : One row = one legacy company.
Rowcount     : 200
Purpose      : Stores historical company/customer records from the legacy system.
Pk           : id

-----10. Legacy events

Grain        : One row = one event/action performed by a company in the legacy system.
Rowcount     : 15028
Purpose      : Stores historical user/company activity events from the legacy system.
Pk           : id
FK           : company_id

----11. Legacy_invoices

Grain       : One row = one invoice generated for one legacy company subscription.
Rowcount    : 1500
Purpose     : Stores historical invoices and payment information from the legacy billing system.
Pk          : id
Fk          : company_id, subscription_id

----12. Legacy_sunscription

Grain       : One row = one subscription period for one legacy company.
Rowcount    : 500
Purpose     : Stores historical subscription periods, plans, MRR, and cancellation details for companies in the legacy system.
Pk          : id
Fk          : company_id

----13.  legacy_support_tickets

Grain       : One row = one support ticket raised by one legacy company.
Rowcount    : 300
Purpose     : Stores customer support tickets and their resolution details from the legacy system.
Pk          : id
Fk          : company_id

----14. payment_attempts

Grain      : One row = one payment attempt for one invoice.
Rowcount   : 5690
Purpose    : Tracks individual payment attempts, failures, and retries for customer invoices.
PK         : attempt_id
Fk         : invoice_id, user_id, subscription_id, account_id


----15. plans

Grain      : One row = one pricing plan/
Rowcount   : 8
Purpose    : Defines the SaaS pricing plans, prices, seat limits, and billing intervals.
PK         : plan_id


----16. seats

Grain     : One row = one seat assignment for one user within an account.
Rowcount  : 1556
Purpose   : Tracks user seat assignments within customer accounts and their activation/deactivation dates.
Pk        : seat_id
FK        : user_id, account_id


----17. signups

Grain    : One row = one user signup.
Rowcount : 2556
Purpose  : Tracks user signups, their associated accounts, signup dates, and acquisition sources.
Fk       : user_id, account_id

----18. subscription_events

Grain      : One row = one event/change to one subscription.
Rowcount   : 3741
Purpose    : Records subscription lifecycle events and the resulting MRR movements.
Pk         : event_id
Fk         : subscription_id, user_id


----19. subscriptions

Grain      : One row = one subscription period
Rowcount   : 2113
Purpose    : Stores subscription records, including plan, MRR, lifecycle dates, and subscription status for SaaS customers.
Pk         : subscription_id
Fk         : user_id, account_id, plan_id
 
 
----20. support_tickets

Grain       : One row = one support ticket raised by one user within an account.
Rowcount    : 1249
Purpose     : Tracks customer support tickets, including who opened them, when they were opened/closed, priority, category, and customer satisfaction (CSAT).
Pk          : ticket_id
Fk          : account_id, opened_by_user_id


-----21. trails

Grain      : One row = one trial period for one account.
Rowcount   : 250
Purpose    : Tracks account trial periods and whether they converted into paid subscriptions.
Pk         : trail_id
FK         : account_id, converted_subscription_id


-----22. users

Grain        : One row = one user.
Rowcount     : 2556
Purpose      : Stores user-level information, including their company, signup details, plan, and activity status.
Pk           : user_id
Fk           : account_id



---------------------Column dictionary for the top 6 most important tables---------------------------------------------------

1. Accounts:


account_id	               : Unique identifier of the customer account
name	                   : Name of the customer/account	
account_type	           : Type of customer account
industry	               : Industry of the customer	
employee_count	           : Number of employees/users associated with the account	
country	                   : Country of the customer account	
signup_date	               : Date when the account signed up	
acquisition_channel	       : Channel through which the account was acquired


2. Users :

user_id	                   : Unique identifier for each user
email	                   : User's email address	
company_name	           : Name of the company associated with the user
signup_date	               : Date when the user signed up	
signup_source	           : Channel through which the user signed up
plan_type	               : Plan associated with the user
is_active	               : Indicates whether the user is currently active (1) or inactive (0)
last_login_date	           : Date of the user's most recent login	
account_id	               : Identifier of the account/company the user belongs to; FK to accounts


3. subscription


subscription_id	           : Unique identifier for each subscription
user_id	                   : User associated with the subscription; 
account_id	               : Customer account associated with the subscription	
plan	                   : Name of the subscription plan	
start_date	               : Date the subscription period started	
end_date	               : Date the subscription period ended, if applicable	
mrr	                       : Monthly recurring revenue associated with the subscription	
status	                   : Current subscription status
cancelled_at	           : Date/time when the subscription was cancelled
cancellation_reason	       : Reason for subscription cancellation


4. subscription_events

event_id	               : Unique ID of the subscription event	
subscription_id	           : Subscription affected by the event	
user_id	                   : User associated with the subscription event
event_type	               : Type of change/action that happened	
event_time	               : When the event happened	
from_plan	               : Previous plan before the change;	NULL for a new subscription
to_plan	                   : New plan after the change
mrr_delta	               : Change in monthly recurring revenue caused by the event
account_id	               : Customer account associated with the subscription
actor_user_id	           : User who triggered the subscription change	
seats_delta	               : Change in the number of seats caused by the event

5. plans

plan_id	                   : Unique identifier for each plan/pricing configuration
plan_name	               : Name of the subscription plan
monthly_price	           : Price charged per month for that plan
seat_limit	               : Maximum number of seats/users allowed under the plan
billing_interval	       : How often the customer is billed

6. features

feature_id	              : Unique identifier for each product feature	
feature_name	          : Name of the feature	Dashboard
category	              : Category/group the feature belongs to
release_date              : Date the feature was released


7. payment_attempts

attempt_id	             : Unique ID of each payment attempt
invoice_id	             : Invoice for which the payment was attempted
user_id	                 : User associated with the payment	
subscription_id	         : Subscription associated with the payment	
amount	                 : Amount attempted to be charged
status	                 : Result of the payment attempt
failure_reason	         : Reason the payment failed
attempt_number	         : Number of the retry attempt	
attempted_at	         : Date/time of the payment attempt
account_id	             : Customer account associated with the payment



---------------------Data quality findings----------------------------------

1. subscriptions contains inconsistent capitalization and naming such as pro, Pro, and enterprise. Queries should normalize plan names using LOWER()

2. Many subscription rows have NULL cancellation_reason; this is expected for subscriptions that have not been cancelled, but cancellation records should be checked for missing reasons.

3. Some events reference users that do not exist in the users table




--------------1. Active paying Accounts

SELECT 

        COUNT(DISTINCT account_id) AS active_paying_accounts
  FROM saas.subscriptions
  WHERE status = 'active'
  AND LOWER(plan) <> 'free';
  

-----2. Breakdown of accounts by plan

select 
        lower(plan),
		count(distinct account_id) as account_count 
	from saas.Subscription
	group by lower(plan)
	
----3. Ten subscription events chronologically

select  
       *
	from saas.subscription_events
	order by event_time asc
	limit 10
