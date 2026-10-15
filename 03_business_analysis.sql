---Portfolio Overview
SELECT
    COUNT(DISTINCT policy_id) AS total_policies,
    SUM(NULLIF(TRIM(premium_usd::text), '')::numeric)
        AS total_premium_usd,
    ROUND(
        AVG(NULLIF(TRIM(premium_usd::text), '')::numeric),
        2
    ) AS average_premium_usd
FROM raw_policies;
--- Claims Analysis (CTE)
WITH claims_summary AS (
    SELECT
        TRIM(incident_type) AS incident_type,
        COUNT(DISTINCT claim_id) AS claim_count,
        SUM(
            NULLIF(TRIM(paid_amount_usd::text), '')::numeric
        ) AS total_paid_usd
    FROM raw_claims
    GROUP BY TRIM(incident_type)
)
SELECT *
FROM claims_summary
ORDER BY total_paid_usd DESC NULLS LAST;

---Monthly Premium Trend (LAG)
WITH monthly_premium AS (
    SELECT
        TO_CHAR(
            NULLIF(TRIM(start_date::text), '')::date,
            'YYYY-MM'
        ) AS start_month,
        SUM(
            NULLIF(TRIM(premium_usd::text), '')::numeric
        ) AS total_premium_usd
    FROM raw_policies
    WHERE NULLIF(TRIM(start_date::text), '') IS NOT NULL
    GROUP BY 1
)
SELECT
    start_month,
    total_premium_usd,
    LAG(total_premium_usd) OVER (
        ORDER BY start_month
    ) AS previous_month_premium,
    total_premium_usd
        - LAG(total_premium_usd) OVER (
            ORDER BY start_month
        ) AS monthly_change
FROM monthly_premium
ORDER BY start_month;

---Customer Risk Analysis
SELECT
    TRIM(risk_band) AS risk_band,
    COUNT(DISTINCT policyholder_id) AS customer_count,
    ROUND(
        AVG(NULLIF(TRIM(risk_score::text), '')::numeric),
        2
    ) AS average_risk_score
FROM raw_policyholders
WHERE NULLIF(TRIM(risk_score::text), '') IS NOT NULL
GROUP BY TRIM(risk_band)
ORDER BY average_risk_score DESC NULLS LAST;

---Product Performance (RANK)
WITH product_premium AS (
    SELECT
        pr.product_id,
        TRIM(pr.product_name) AS product_name,
        SUM(
            NULLIF(TRIM(p.premium_usd::text), '')::numeric
        ) AS total_premium_usd
    FROM raw_products pr
    LEFT JOIN raw_policies p
        ON TRIM(pr.product_id) = TRIM(p.product_id)
    GROUP BY
        pr.product_id,
        TRIM(pr.product_name)
)
SELECT
    product_id,
    product_name,
    total_premium_usd,
    RANK() OVER (
        ORDER BY total_premium_usd DESC NULLS LAST
    ) AS premium_rank
FROM product_premium
ORDER BY premium_rank;
