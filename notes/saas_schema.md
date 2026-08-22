


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
Rowcount   : 
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
