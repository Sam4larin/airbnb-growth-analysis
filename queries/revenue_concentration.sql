-- Revenue Concentration Analysis (Pareto)
-- Business Question: How concentrated is platform revenue?
-- What share of hosts generate 80% of estimated revenue?
--
-- Data note: estimated_revenue_l365d is available for London
-- and Amsterdam while for NYC it is all null values.
-- For NYC we use total_reviews as a relative activity proxy to rank hosts by platform contribution.
-- This means NYC tiers reflect booking activity concentration, not dollar revenue.
-- This is a limitation of the source data but still gives insight into how much of the platform is driven by a small share of highly active hosts.

WITH revenue_check AS (
    SELECT
        COALESCE(
            SUM(
                TRY_CAST(
                    REGEXP_REPLACE(
                        CAST(estimated_revenue_l365d AS VARCHAR),
                        '[^0-9.]', '', 'g'
                    ) AS DOUBLE
                )
            ), 0
        ) AS grand_revenue_total
    FROM read_csv_auto('{file_path}')
),

host_revenue AS (
    SELECT
        r.host_id,
        r.calculated_host_listings_count,
        SUM(r.number_of_reviews) AS total_reviews,
        COUNT(*) AS listing_count,

        CASE
            WHEN c.grand_revenue_total > 0
            THEN COALESCE(
                SUM(
                    TRY_CAST(
                        REGEXP_REPLACE(
                            CAST(r.estimated_revenue_l365d AS VARCHAR),
                            '[^0-9.]', '', 'g'
                        ) AS DOUBLE
                    )
                ), 0
            )
            ELSE CAST(SUM(r.number_of_reviews) AS DOUBLE)
        END AS total_estimated_revenue,

        CASE
            WHEN c.grand_revenue_total > 0
            THEN 'estimated_revenue_l365d'
            ELSE 'reviews_proxy'
        END AS metric_used

    FROM read_csv_auto('{file_path}') r

    CROSS JOIN revenue_check c
    WHERE r.host_id IS NOT NULL
    GROUP BY
        r.host_id,
        r.calculated_host_listings_count,
        c.grand_revenue_total
),


ranked_hosts AS (
    SELECT
        *,
        RANK() OVER (ORDER BY total_estimated_revenue DESC)
            AS revenue_rank,
        COUNT(*) OVER () AS total_hosts,
        SUM(total_estimated_revenue) OVER (
            ORDER BY total_estimated_revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue,
        SUM(total_estimated_revenue) OVER () AS grand_total_revenue
    FROM host_revenue
),

concentration_buckets AS (
    SELECT
        *,
        ROUND(100.0 * revenue_rank / total_hosts, 2) AS host_percentile,
        ROUND(
            100.0 * cumulative_revenue / NULLIF(grand_total_revenue, 0), 2
        ) AS cumulative_revenue_pct
    FROM ranked_hosts
)

SELECT
    CASE
        WHEN CAST(host_percentile AS DOUBLE) <= 1   THEN 'Top 1% of hosts'
        WHEN CAST(host_percentile AS DOUBLE) <= 5   THEN 'Top 5% of hosts'
        WHEN CAST(host_percentile AS DOUBLE) <= 10  THEN 'Top 10% of hosts'
        WHEN CAST(host_percentile AS DOUBLE) <= 20  THEN 'Top 20% of hosts'
        WHEN CAST(host_percentile AS DOUBLE) <= 50  THEN 'Top 50% of hosts'
        ELSE                                             'Bottom 50% of hosts'
    END AS host_tier,

    MAX(metric_used)                                     AS metric_used,
    COUNT(*)                                             AS host_count,
    ROUND(SUM(total_estimated_revenue), 0)               AS tier_value,
    ROUND(AVG(listing_count), 1)                         AS avg_listings_per_host,
    ROUND(
        100.0 * SUM(total_estimated_revenue)
        / NULLIF(MAX(grand_total_revenue), 0)
    , 1)                                                 AS pct_of_total

FROM concentration_buckets
GROUP BY host_tier
ORDER BY MIN(host_percentile);