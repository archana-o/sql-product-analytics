
-- Q[3] — Cohort Retention Curve (Weekly, Behavioral)
-- Business question: How well do customers continue to engage after signup, and where does retention drop across Week 0 to Week 4?
-- What this tells us: Retention varies across signup cohorts, with W1 retention reaching a high of 36% for the May 11 cohort. Retention declines in later cohorts, especially May 25 and June 1. The latest cohorts should be interpreted cautiously because they may not have a complete observation window.
-- PM Action: Compare high- and low-retention cohorts by acquisition channel, device, customer segment, and event type to identify what is driving retention changes.
-- Sanity check: w1_retained <= cohort_size, w2_retained <= cohort_size, etc. Retention rates should be between 0 and 1



WITH customer_activity AS (

    SELECT
        c.customer_id,
        c.created_at AS signup_date,
        se.session_id,
        se.occurred_at AS event_date,
        se.event_type,

        FLOOR(
            EXTRACT(
                EPOCH FROM (se.occurred_at - c.created_at)
            ) / (86400 * 7)
        ) AS week_index

    FROM ecom.customers c

    LEFT JOIN ecom.session_events se
        ON c.customer_id = se.customer_id
        AND se.occurred_at >= c.created_at

    WHERE c.created_at >= DATE '2026-04-20' 
)

SELECT
    date_trunc('week', signup_date) AS cohort_week,

    COUNT(DISTINCT customer_id) AS cohort_size,

    -- W0 = ANY activity
    COUNT(DISTINCT CASE
        WHEN week_index = 0
        THEN customer_id
    END) AS w0_active,

    -- W1 = meaningful activity
    COUNT(DISTINCT CASE
        WHEN week_index = 1
         AND event_type IN (
             'product_view',
             'add_to_cart',
             'purchase'
         )
        THEN customer_id
    END) AS w1_retained,

    -- W2 = meaningful activity
    COUNT(DISTINCT CASE
        WHEN week_index = 2
         AND event_type IN (
             'product_view',
             'add_to_cart',
             'purchase'
         )
        THEN customer_id
    END) AS w2_retained,

    -- W3 = meaningful activity
    COUNT(DISTINCT CASE
        WHEN week_index = 3
         AND event_type IN (
             'product_view',
             'add_to_cart',
             'purchase'
         )
        THEN customer_id
    END) AS w3_retained,

    -- W4 = meaningful activity
    COUNT(DISTINCT CASE
        WHEN week_index = 4
         AND event_type IN (
             'product_view',
             'add_to_cart',
             'purchase'
         )
        THEN customer_id
    END) AS w4_retained,

    COUNT(DISTINCT CASE
        WHEN week_index = 1
         AND event_type IN (
             'product_view',
             'add_to_cart',
             'purchase'
         )
        THEN customer_id
    END)::numeric
    / NULLIF(COUNT(DISTINCT customer_id), 0)
        AS w1_retention_rate,

    COUNT(DISTINCT CASE
        WHEN week_index = 2
         AND event_type IN (
             'product_view',
             'add_to_cart',
             'purchase'
         )
        THEN customer_id
    END)::numeric
    / NULLIF(COUNT(DISTINCT customer_id), 0)
        AS w2_retention_rate,

    COUNT(DISTINCT CASE
        WHEN week_index = 3
         AND event_type IN (
             'product_view',
             'add_to_cart',
             'purchase'
         )
        THEN customer_id
    END)::numeric
    / NULLIF(COUNT(DISTINCT customer_id), 0)
        AS w3_retention_rate,

    COUNT(DISTINCT CASE
        WHEN week_index = 4
         AND event_type IN (
             'product_view',
             'add_to_cart',
             'purchase'
         )
        THEN customer_id
    END)::numeric
    / NULLIF(COUNT(DISTINCT customer_id), 0)
        AS w4_retention_rate

FROM customer_activity

GROUP BY date_trunc('week', signup_date)

ORDER BY cohort_week;
