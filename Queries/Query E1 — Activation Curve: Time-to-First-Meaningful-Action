
-- Query E1 — Activation Curve: Time-to-First-Meaningful-Action
-- Business question: How fast do new signups become real users, and how has that changed cohort-over-cohort?
-- What this tells us: 7-day activation peaked at 21.67% for the May 18 cohort but dropped sharply to 8.79% for June 8. However, users who did activate in the June 8 cohort reached their first meaningful action faster, suggesting the issue is fewer users activating rather than slower activation.
-- PM Action: Compare the June 8 and May 18 cohorts by acquisition channel, device, and first meaningful event to identify where the activation drop is occurring.
-- Sanity check: activated_7d <= cohort_size for every row. Also: the most recent 1–2 cohorts will look artificially low because the 7-day window hasn't closed


WITH signup_cohort AS (
    SELECT 
        DATE_TRUNC('week', created_at) AS signup_week,
        COUNT(*) AS cohort_size
    FROM ecom.customers
    WHERE DATE_TRUNC('week', created_at) >= DATE '2026-04-20'
      AND DATE_TRUNC('week', created_at) < DATE_TRUNC('week', CURRENT_DATE) - INTERVAL '7 days'
    GROUP BY DATE_TRUNC('week', created_at)
),

first_action AS (
    SELECT
        se.customer_id,
        c.created_at AS signup_time,
        MIN(se.occurred_at) AS activation_time,
        EXTRACT(
            EPOCH FROM (
                MIN(se.occurred_at) - c.created_at
            )
        ) / 60 AS minutes_to_activation
    FROM ecom.customers c
    JOIN ecom.session_events se
        ON c.customer_id = se.customer_id
    WHERE DATE_TRUNC('week', c.created_at) >= DATE '2026-04-20'
      AND se.event_type IN (
          'add_to_cart',
          'begin_checkout',
          'purchase'
      )
      AND se.occurred_at >= c.created_at
    GROUP BY
        se.customer_id,
        c.created_at
)

SELECT
    sc.signup_week,
    sc.cohort_size,

    COUNT(DISTINCT CASE
        WHEN fa.minutes_to_activation <= 10080
        THEN fa.customer_id
    END) AS activated_7d,

    ROUND(
        COUNT(DISTINCT CASE
            WHEN fa.minutes_to_activation <= 10080
            THEN fa.customer_id
        END) * 100.0 / sc.cohort_size,
        2
    ) AS activation_rate_7d,

    PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY CASE
                WHEN fa.minutes_to_activation <= 10080
                THEN fa.minutes_to_activation
            END
        ) AS median_minutes_to_activation,

    PERCENTILE_CONT(0.9)
        WITHIN GROUP (
            ORDER BY CASE
                WHEN fa.minutes_to_activation <= 10080
                THEN fa.minutes_to_activation
            END
        ) AS p90_minutes_to_activation

FROM signup_cohort sc

LEFT JOIN first_action fa
    ON sc.signup_week = DATE_TRUNC('week', fa.signup_time)

GROUP BY
    sc.signup_week,
    sc.cohort_size

ORDER BY
    sc.signup_week;
