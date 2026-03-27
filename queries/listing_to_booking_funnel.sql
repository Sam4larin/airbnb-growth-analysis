-- Listing-to-First-Booking Funnel
-- Business Question: How long does it take listings to get
-- their first booking, and where does the funnel break?

WITH listing_funnel AS (
    SELECT
        id AS listing_id,
        host_id,
        room_type,
        neighbourhood_cleansed,
        host_since,
        first_review,
        number_of_reviews,

        CASE
            WHEN first_review IS NOT NULL AND host_since IS NOT NULL
            THEN DATE_DIFF(
                'day',
                CAST(host_since AS DATE),
                CAST(first_review AS DATE)
            )
            ELSE NULL
        END AS days_to_first_booking,

        CASE
            WHEN number_of_reviews = 0
                THEN 'Stage 1: Never Booked'
            WHEN first_review IS NOT NULL
                AND DATE_DIFF('day',
                    CAST(host_since AS DATE),
                    CAST(first_review AS DATE)) BETWEEN 0 AND 30
                THEN 'Stage 2: Booked within 30 days'
            WHEN first_review IS NOT NULL
                AND DATE_DIFF('day',
                    CAST(host_since AS DATE),
                    CAST(first_review AS DATE)) BETWEEN 31 AND 90
                THEN 'Stage 3: Booked within 90 days'
            WHEN first_review IS NOT NULL
                AND DATE_DIFF('day',
                    CAST(host_since AS DATE),
                    CAST(first_review AS DATE)) BETWEEN 91 AND 365
                THEN 'Stage 4: Booked within 1 year'
            WHEN first_review IS NOT NULL
                AND DATE_DIFF('day',
                    CAST(host_since AS DATE),
                    CAST(first_review AS DATE)) > 365
                THEN 'Stage 5: Took over 1 year'
            ELSE 'Stage 6: Data inconsistency'
        END AS funnel_stage

    FROM read_csv_auto('{file_path}')
    -- Filter out rows where first_review predates host_since
    WHERE host_since IS NOT NULL
      AND (
          first_review IS NULL
          OR CAST(first_review AS DATE) >= CAST(host_since AS DATE)
      )
),

room_type_totals AS (
    SELECT
        room_type,
        COUNT(*) AS total_in_room_type
    FROM listing_funnel
    GROUP BY room_type
),

funnel_by_room_type AS (
    SELECT
        f.room_type,
        f.funnel_stage,
        COUNT(*) AS listing_count,
        t.total_in_room_type,
        ROUND(AVG(f.days_to_first_booking), 0) AS avg_days_to_first_booking,
        ROUND(MEDIAN(f.days_to_first_booking), 0) AS median_days_to_first_booking
    FROM listing_funnel f
    JOIN room_type_totals t ON f.room_type = t.room_type
    GROUP BY f.room_type, f.funnel_stage, t.total_in_room_type
)

SELECT
    room_type,
    funnel_stage,
    listing_count,
    total_in_room_type,
    ROUND(100.0 * listing_count / total_in_room_type, 1) AS pct_of_room_type,
    avg_days_to_first_booking,
    median_days_to_first_booking
FROM funnel_by_room_type
ORDER BY room_type, funnel_stage;