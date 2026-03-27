-- Host Activity & Retention by Neighbourhood
-- Business Question: Where are hosts active vs. dormant,
-- and does host tenure predict activity?

-- We use reviews as a booking proxy since actual booking
-- counts are not publicly available in this dataset.
-- A listing with a recent review = recently booked.

WITH host_activity AS (
    SELECT
        host_id,
        host_since,
        neighbourhood_cleansed,
        number_of_reviews,
        last_review,
        reviews_per_month,
        calculated_host_listings_count,

        CASE
            WHEN number_of_reviews = 0
                THEN 'Never Booked'
            WHEN last_review >= (CURRENT_DATE - INTERVAL '12 months')
                THEN 'Active (reviewed in last 12 months)'
            WHEN last_review >= (CURRENT_DATE - INTERVAL '24 months')
                THEN 'Dormant (12-24 months ago)'
            ELSE
                'Inactive (no review in 2+ years)'
        END AS activity_status,

        -- Calculate how many years the host has been on the platform
        DATE_DIFF('year',
            CAST(host_since AS DATE),
            CURRENT_DATE
        ) AS host_tenure_years

    FROM read_csv_auto('{file_path}')
    WHERE host_since IS NOT NULL
),

neighbourhood_summary AS (
    SELECT
        neighbourhood_cleansed,
        COUNT(*) AS total_listings,

        COUNT(CASE WHEN activity_status = 'Never Booked' THEN 1 END)
            AS never_booked,
        COUNT(CASE WHEN activity_status = 'Active (reviewed in last 12 months)' THEN 1 END)
            AS active,
        COUNT(CASE WHEN activity_status LIKE 'Dormant%' THEN 1 END)
            AS dormant,
        COUNT(CASE WHEN activity_status LIKE 'Inactive%' THEN 1 END)
            AS inactive,

        -- What % of listings in this neighbourhood were never booked
        ROUND(
            100.0 * COUNT(CASE WHEN activity_status = 'Never Booked' THEN 1 END)
            / COUNT(*), 1
        ) AS pct_never_booked,

        -- What % are currently active
        ROUND(
            100.0 * COUNT(CASE WHEN activity_status = 'Active (reviewed in last 12 months)' THEN 1 END)
            / COUNT(*), 1
        ) AS pct_active,

        -- Average host tenure in this neighbourhood
        ROUND(AVG(host_tenure_years), 1) AS avg_host_tenure_years,

        -- Average reviews per month for active listings only
        ROUND(AVG(CASE
            WHEN activity_status = 'Active (reviewed in last 12 months)'
            THEN reviews_per_month END), 2
        ) AS avg_reviews_per_month_active

    FROM host_activity
    GROUP BY neighbourhood_cleansed
)

SELECT *
FROM neighbourhood_summary
WHERE total_listings >= 50  -- filter out tiny neighbourhoods with noisy %s
ORDER BY pct_never_booked DESC
LIMIT 20;