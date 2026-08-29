
-- Q[1] —  Monthly MRR Movement Decomposition
-- Business question:  How did MRR change last month — and what drove the change? New, expansion, contraction, or churn?
-- What this tells us: MRR grew strongly from ₹169.92 in August 2025 to ₹164.32K in June 2026, driven mainly by new and expansion MRR. March 2026 stands out because churn MRR spiked to ₹13.82K, approximately 2.8x February's ₹4.90K, making churn the key revenue-retention risk.
-- PM Action: Investigate the March churn spike using a signup cohort × churn month cut, then segment the affected cohort by plan, acquisition channel, and product engagement to identify the root cause. 
-- Sanity check: ending_mrr_month_N = ending_mrr_month_N-1 + net_new_mrr_month_N. Reconcile event-sum ending MRR against an independent month-end MRR snapshot; the two should be within ~1%.




WITH classified AS (
    SELECT
        DATE_TRUNC('month', event_time) AS month,

        CASE
            WHEN event_type = 'subscription_started'
                 AND EXISTS (
                     SELECT 1
                     FROM saas.subscription_events p
                     WHERE p.account_id = se.account_id
                       AND p.event_type = 'cancelled'
                       AND p.event_time < se.event_time
                 )
            THEN 'reactivation'

            WHEN event_type IN ('subscription_started', 'trial_converted')
            THEN 'new'

            WHEN event_type = 'plan_changed'
                 AND mrr_delta > 0
            THEN 'expansion'

            WHEN event_type IN ('seat_add', 'addon_attach')
            THEN 'expansion'

            WHEN event_type = 'plan_changed'
                 AND mrr_delta < 0
            THEN 'contraction'

            WHEN event_type = 'cancelled'
            THEN 'churn'
        END AS bucket,

        mrr_delta

    FROM saas.subscription_events se

    WHERE event_type <> 'trial_started'
      AND event_time >= CURRENT_DATE - INTERVAL '12 months'
      AND event_time <= DATE '2026-06-15'
),

monthly_mrr AS (
    SELECT
        month,

        SUM(mrr_delta) FILTER (
            WHERE bucket = 'new'
        ) AS new_mrr,

        SUM(mrr_delta) FILTER (
            WHERE bucket = 'expansion'
        ) AS expansion_mrr,

        SUM(mrr_delta) FILTER (
            WHERE bucket = 'contraction'
        ) AS contraction_mrr,

        SUM(mrr_delta) FILTER (
            WHERE bucket = 'churn'
        ) AS churn_mrr,

        SUM(mrr_delta) FILTER (
            WHERE bucket = 'reactivation'
        ) AS reactivation_mrr,

        SUM(mrr_delta) AS net_new_mrr

    FROM classified
    GROUP BY month
)

SELECT
    month,
    new_mrr,
    expansion_mrr,
    contraction_mrr,
    churn_mrr,
    reactivation_mrr,
    net_new_mrr,

    SUM(net_new_mrr) OVER (
        ORDER BY month
    ) AS ending_mrr

FROM monthly_mrr
ORDER BY month;
