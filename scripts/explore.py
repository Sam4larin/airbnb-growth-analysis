import duckdb
import pandas as pd

pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', 60)
pd.set_option('display.width', None)

files = {
    "NYC": "data/listings_nyc.csv",
    "London": "data/listings_london.csv",
    "Amsterdam": "data/listings_amsterdam.csv"
}

for city, path in files.items():
    print("\n" + "="*60)
    print(f"CITY: {city}")
    print("="*60)

    # Load just the first 5 rows
    df = pd.read_csv(path, nrows=5, low_memory=False)

    print(f"\nShape (rows x columns): {pd.read_csv(path, low_memory=False).shape}")
    print(f"\nColumn names:\n{list(df.columns)}")
    print(f"\nData types:\n{df.dtypes}")
    print(f"\nFirst 2 rows:\n{df.head(2)}")

    # Check for nulls across the full file using DuckDB
    con = duckdb.connect()
    null_check = con.execute(f"""
        SELECT
            COUNT(*) as total_rows,
            COUNT(id) as id_count,
            COUNT(host_id) as host_id_count,
            COUNT(host_since) as host_since_count,
            COUNT(neighbourhood_cleansed) as neighbourhood_count,
            COUNT(number_of_reviews) as reviews_count,
            COUNT(reviews_per_month) as reviews_per_month_count,
            COUNT(calculated_host_listings_count) as host_listings_count,
            COUNT(last_review) as last_review_count
        FROM read_csv_auto('{path}')
    """).df()

    print(f"\nNull check (count of non-null values vs total rows):")
    print(null_check.to_string(index=False))
    con.close()