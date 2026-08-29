


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
