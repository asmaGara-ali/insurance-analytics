-- 1. Check missing values
SELECT
    COUNT(*) AS total_rows,
    COUNT(agent_id) AS non_null_id,
    COUNT(agent_name) AS non_null_name,
    COUNT(distribution_channel) AS non_null_distribution_channel,
    COUNT(country) AS non_null_country,
    COUNT(city) AS non_null_city,
    COUNT(commission_rate_pct) AS non_null_commission,
    COUNT(joined_date) AS non_null_joined_date,
    COUNT(is_active) AS non_null_active
FROM raw_agents;

-- 2. Check duplicate agent IDs
SELECT
    agent_id,
    COUNT(*) AS duplicate_count
FROM raw_agents
GROUP BY agent_id
HAVING COUNT(*) > 1;

-- 3. Check missing values
SELECT
    COUNT(*) AS total_rows,
    COUNT(policyholder_id) AS non_null_id,
    COUNT(policyholder_name) AS non_null_name,
    COUNT(policyholder_type) AS non_null_type,
    COUNT(industry) AS non_null_industry,
    COUNT(country) AS non_null_country,
    COUNT(city) AS non_null_city,
    COUNT(risk_score) AS non_null_risk_score,
    COUNT(risk_band) AS non_null_risk_band,
    COUNT(customer_since) AS non_null_customer_since
FROM raw_policyholders;

-- 4. Identify missing industry by policyholder type
SELECT
    policyholder_type,
    COUNT(*) AS missing_industry_count
FROM raw_policyholders
WHERE industry IS NULL
GROUP BY policyholder_type
ORDER BY missing_industry_count DESC;

-- 5. Check duplicate policyholder IDs
SELECT
    policyholder_id,
    COUNT(*) AS duplicate_count
FROM raw_policyholders
GROUP BY policyholder_id
HAVING COUNT(*) > 1;
-- 6. Check duplicate policy IDs
SELECT
    policy_id,
    COUNT(*) AS duplicate_count
FROM raw_policies
GROUP BY policy_id
HAVING COUNT(*) > 1;

-- 7. Check missing values
SELECT
    COUNT(*) AS total_rows,
    COUNT(policy_id) AS non_null_policy_id,
    COUNT(policyholder_id) AS non_null_holder_id,
    COUNT(product_id) AS non_null_product_id,
    COUNT(premium_usd) AS non_null_premium,
    COUNT(sum_insured_usd) AS non_null_sum_insured
FROM raw_policies;

-- 8. Check invalid policy dates
SELECT
    policy_id,
    start_date,
    end_date
FROM raw_policies
WHERE end_date < start_date;

-- 9. Check negative financial amounts
SELECT
    policy_id,
    premium_usd,
    sum_insured_usd,
    deductible_usd
FROM raw_policies
WHERE premium_usd < 0
   OR sum_insured_usd < 0
   OR deductible_usd < 0;
-- 10. Check duplicate claim IDs
SELECT
    claim_id,
    COUNT(*) AS duplicate_count
FROM raw_claims
GROUP BY claim_id
HAVING COUNT(*) > 1;

-- 11. Check missing values
SELECT
    COUNT(*) AS total_rows,
    COUNT(claim_id) AS non_null_claim_id,
    COUNT(policy_id) AS non_null_policy_id,
    COUNT(claim_status) AS non_null_status,
    COUNT(claimed_amount_usd) AS non_null_claimed,
    COUNT(approved_amount_usd) AS non_null_approved,
    COUNT(paid_amount_usd) AS non_null_paid
FROM raw_claims;

-- 12. Check date consistency and reporting delay
SELECT
    claim_id,
    incident_date,
    settlement_date,
    reported_after_days
FROM raw_claims
WHERE settlement_date < incident_date
   OR reported_after_days < 0;

-- 13. Approved amount should not exceed claimed amount
SELECT
    claim_id,
    claimed_amount_usd,
    approved_amount_usd
FROM raw_claims
WHERE approved_amount_usd > claimed_amount_usd;

-- 14. Paid amount should not exceed approved amount
SELECT
    claim_id,
    approved_amount_usd,
    paid_amount_usd
FROM raw_claims
WHERE paid_amount_usd > approved_amount_usd;
-- Review product data types before conversion
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'raw_products'
ORDER BY ordinal_position;
