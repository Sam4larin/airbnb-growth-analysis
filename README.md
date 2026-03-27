Airbnb Host Growth & Platform Health Analysis

End-to-end SQL and Tableau analysis evaluating marketplace health, host activity, revenue concentration, and booking conversion across 143,000+ Airbnb listings in New York City, London, and Amsterdam.

This project simulates analysis performed by a marketplace growth or strategy analytics team diagnosing platform performance and structural risk.

Dashboard Preview

Interactive Tableau workbook available in:

/assets/airbnb-growth-analysis.twb

Open using Tableau Desktop or Tableau Public.

Overview

Marketplace platforms depend on healthy supply participation, balanced revenue distribution, and efficient listing conversion. This project analyzes publicly available Airbnb data to answer key business questions about platform sustainability and growth dynamics across regulated and open markets.

Tools Used

SQL
Python
Tableau

Core Analytical Skills

Funnel analysis
Cohort & retention analysis
Revenue concentration (Pareto analysis)
Window functions
Data storytelling & dashboard design
Reproducible analytics workflows
Business Questions
Where are hosts becoming inactive, and what signals indicate declining marketplace health?
Which neighbourhoods have the highest share of listings that never convert to bookings?
How concentrated is platform revenue among top hosts?
How does revenue concentration differ between regulated and open markets?
Where does the listing-to-booking funnel break, and which room types convert fastest?
Key Findings
1️⃣ NYC Premium Neighbourhoods Show High Non-Conversion Rates

Several high-demand Manhattan neighbourhoods exhibit unusually large shares of listings that have never received a review (used as a booking proxy):

Battery Park City — 53.6% never booked
Theatre District — 49.9%
Tribeca — 47.8%
Murray Hill — 46.1%
Financial District — 45.0%

Hosts in these areas average 9–10 years on the platform, indicating long-tenured inactive supply rather than newly created listings.

Comparison:

London peak: 35.7%
Amsterdam peak: 20.8%

NYC demonstrates materially higher structural non-conversion.

2️⃣ London Revenue Is Highly Concentrated Among Professional Hosts

Revenue distribution in London is strongly top-heavy:

Top 1% of hosts (559 hosts) generate 45.2% of total estimated revenue.
Top 5% generate over 70%.
Bottom 50% generate only 5.4%.

Top hosts average 23.4 listings each, suggesting professional operators managing multi-unit portfolios.

Amsterdam shows lower concentration:

Top 1% generate 24.4% of revenue.

Regulatory constraints (night caps and permits) appear to limit operator dominance compared with London.

3️⃣ Listing Conversion Is Extremely Slow Across Markets

Across cities and room types, the most common outcome is:

Listings taking over one year to receive their first booking.

Examples:

Amsterdam entire homes: 72.2% take >1 year
London: 59.0%
NYC: 50.1%

Median time-to-first-booking for Amsterdam entire homes exceeds 7 years.

Fastest converting category:

Amsterdam private rooms — 14.4% convert within 30 days.

NYC hotel rooms show particularly weak performance:

61.4% never booked.
Project Structure
airbnb-growth-analysis/
│
├── data/                          # Raw source CSVs (not committed)
├── queries/
│   ├── host_retention.sql
│   ├── revenue_concentration.sql
│   └── listing_to_booking_funnel.sql
├── outputs/                       # Generated query outputs
├── scripts/
│   └── run_queries.py
├── assets/
│   ├── dashboard_screenshot.png
│   └── airbnb-growth-analysis.twb
├── requirements.txt
└── README.md
SQL Skills Demonstrated
Technique	Application
Common Table Expressions (CTEs)	Multi-step analytical transformations
Window Functions (RANK, SUM OVER)	Host ranking & cumulative revenue share
Conditional Aggregation	Activity classification logic
Date Arithmetic	Tenure and funnel timing calculations
CROSS JOIN	Dataset-level totals for Pareto analysis
Data Cleaning (TRY_CAST, REGEXP_REPLACE)	Mixed currency formats
Funnel Stage Classification	Booking lifecycle segmentation
Methodology & Limitations

Reviews as booking proxy
Airbnb booking counts are not public. Review activity is used as an indicator of bookings. This undercounts guests who do not leave reviews but remains directionally accurate.

Snapshot data
Inside Airbnb publishes periodic scrapes. Analysis reflects a single snapshot rather than longitudinal tracking.

Listing creation proxy
host_since is used as a proxy for listing creation date due to dataset limitations.

NYC revenue unavailable
estimated_revenue_l365d is null for NYC listings. Review counts are used as a relative activity proxy. NYC revenue comparisons are excluded from dashboard revenue analysis.

Neighbourhood filtering
Neighbourhoods with fewer than 50 listings are excluded to reduce statistical noise.

Data Source

Inside Airbnb
https://insideairbnb.com/get-the-data

Public datasets used:

New York City — 36,261 listings
London — 106,512 listings
Amsterdam — 10,456 listings

Raw datasets are not committed due to file size.

Download listings.csv.gz for each city and place in /data/ as:

listings_nyc.csv
listings_london.csv
listings_amsterdam.csv
Setup & Running the Analysis

Requirements

Python 3.11+
Anaconda recommended
# Clone repository
git clone https://github.com/Sam4larin/airbnb-growth-analysis.git
cd airbnb-growth-analysis

# Create environment
conda create -n airbnb-analysis python=3.11
conda activate airbnb-analysis

# Install dependencies
pip install -r requirements.txt

# Run analysis
python scripts/run_queries.py

Outputs will be generated in /outputs/ as CSV files.

Why This Project Matters

Marketplace analytics requires understanding not only growth metrics but also structural risks such as inactive supply, operator concentration, and conversion friction. This project demonstrates how publicly available data can be transformed into decision-ready insights using SQL, Python, and Tableau.