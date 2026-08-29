
-- Q[2] — Trial-to-Paid Conversion by Cohort
-- Business question:  Of accounts that started a trial in week W, what fraction converted to paid by day 14, 30, 60?
-- What this tells us: Most conversions happen within the first 14 days, with little additional conversion by 30 or 60 days. Conversion rates vary across cohorts, ranging from 25% to 100%, while median time to conversion is generally around 9–14 days.
-- PM Action: Investigate trial cohort × acquisition channel, then segment by plan, customer type, and early product engagement to identify the behaviors and channels associated with faster and higher trial-to-paid conversion.
-- Sanity check: converted_by_14d <= converted_by_30d <= converted_by_60d <= trials_started. Conversion counts should never exceed cohort size, and conversion rates should remain between 0% and 100%.


WITH calculated_days AS (
    SELECT
        account_id,
        started_at,
        converted_at,
        DATE_TRUNC('week', started_at) AS trial_week,
        EXTRACT(
            EPOCH FROM (converted_at - started_at)
        ) / 86400.0 AS converted_days
    FROM saas.trials
)

SELECT
    trial_week,

    COUNT(*) AS trials_started,

    COUNT(DISTINCT CASE
        WHEN converted_days BETWEEN 0 AND 14
        THEN account_id
    END) AS converted_by_14d,

    COUNT(DISTINCT CASE
        WHEN converted_days BETWEEN 0 AND 30
        THEN account_id
    END) AS converted_by_30d,

    COUNT(DISTINCT CASE
        WHEN converted_days BETWEEN 0 AND 60
        THEN account_id
    END) AS converted_by_60d,

    ROUND(
        COUNT(DISTINCT CASE
            WHEN converted_days BETWEEN 0 AND 14
            THEN account_id
        END) * 100.0 / COUNT(*),
        2
    ) AS conv_rate_14d,

    ROUND(
        COUNT(DISTINCT CASE
            WHEN converted_days BETWEEN 0 AND 30
            THEN account_id
        END) * 100.0 / COUNT(*),
        2
    ) AS conv_rate_30d,

    ROUND(
        COUNT(DISTINCT CASE
            WHEN converted_days BETWEEN 0 AND 60
            THEN account_id
        END) * 100.0 / COUNT(*),
        2
    ) AS conv_rate_60d,

    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY converted_days
        )::numeric,
        2
    ) AS median_days_trial_to_paid

FROM calculated_days
GROUP BY trial_week
ORDER BY trial_week;
