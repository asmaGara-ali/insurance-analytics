-- 1. Check policy amounts against product limits
SELECT
    p.policy_id,
    p.product_id,
    p.sum_insured_usd,
    pr.min_sum_insured_usd,
    pr.max_sum_insured_usd
FROM raw_policies p
JOIN raw_products pr
    ON TRIM(p.product_id) = TRIM(pr.product_id)
WHERE NULLIF(TRIM(p.sum_insured_usd::text), '')::numeric
          < pr.min_sum_insured_usd
   OR NULLIF(TRIM(p.sum_insured_usd::text), '')::numeric
          > pr.max_sum_insured_usd;
-- 2. Policies with missing or unmatched product IDs
SELECT
    p.policy_id,
    p.product_id
FROM raw_policies p
LEFT JOIN raw_products pr
    ON TRIM(p.product_id) = TRIM(pr.product_id)
WHERE p.product_id IS NULL
   OR pr.product_id IS NULL;
-- 3. Policies with missing or unmatched policyholder IDs
SELECT
    p.policy_id,
    p.policyholder_id
FROM raw_policies p
LEFT JOIN raw_policyholders ph
    ON TRIM(p.policyholder_id) = TRIM(ph.policyholder_id)
WHERE p.policyholder_id IS NULL
   OR ph.policyholder_id IS NULL;
-- 4. Policies with missing or unmatched agent IDs
SELECT
    p.policy_id,
    p.agent_id
FROM raw_policies p
LEFT JOIN raw_agents a
    ON TRIM(p.agent_id) = TRIM(a.agent_id)
WHERE p.agent_id IS NULL
   OR a.agent_id IS NULL;
-- 5. Claims linked to missing or unmatched policies
SELECT
    c.claim_id,
    c.policy_id
FROM raw_claims c
LEFT JOIN raw_policies p
    ON TRIM(c.policy_id) = TRIM(p.policy_id)
WHERE c.policy_id IS NULL
   OR p.policy_id IS NULL;
