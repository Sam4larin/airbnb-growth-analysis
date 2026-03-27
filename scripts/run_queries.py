import duckdb
import pandas as pd
from pathlib import Path

ROOT = Path(__file__).parent.parent

DATA_DIR    = ROOT / "data"
QUERIES_DIR = ROOT / "queries"
OUTPUT_DIR  = ROOT / "outputs"

CITIES = {
    "NYC":       DATA_DIR / "listings_nyc.csv",
    "London":    DATA_DIR / "listings_london.csv",
    "Amsterdam": DATA_DIR / "listings_amsterdam.csv",
}

QUERIES = {
    "host_retention":           QUERIES_DIR / "host_retention.sql",
    "revenue_concentration":    QUERIES_DIR / "revenue_concentration.sql",
    "listing_to_booking_funnel": QUERIES_DIR / "listing_to_booking_funnel.sql",
}


def load_query(path: Path) -> str:
    """Read a .sql file and return its contents as a string."""
    with open(path, "r") as f:
        return f.read()


def run_query(sql: str, file_path: Path) -> pd.DataFrame:
    """
    Replacing the {file_path} placeholder in the SQL with the
    actual path, then execute it using DuckDB.
    """
    safe_path = str(file_path).replace("\\", "/")
    filled_sql = sql.replace("{file_path}", safe_path)

    con = duckdb.connect()
    result = con.execute(filled_sql).df()
    con.close()
    return result


def save_result(df: pd.DataFrame, query_name: str, city: str) -> Path:
    filename = f"{query_name}_{city.lower()}.csv"
    output_path = OUTPUT_DIR / filename
    df.to_csv(output_path, index=False)
    return output_path


def print_result(df: pd.DataFrame, query_name: str, city: str) -> None:
    print(f"\n{'='*60}")
    print(f"  {query_name.upper().replace('_', ' ')} — {city}")
    print(f"{'='*60}")
    with pd.option_context(
        "display.max_rows", None,
        "display.max_columns", None,
        "display.width", None,
        "display.float_format", "{:,.2f}".format
    ):
        print(df.to_string(index=False))
    print(f"\nRows returned: {len(df)}")



def main():
    print("Starting Airbnb Growth Analysis")
    print(f"Queries to run: {list(QUERIES.keys())}")
    print(f"Cities: {list(CITIES.keys())}")

    # Load all SQL query templates once upfront
    query_templates = {
        name: load_query(path)
        for name, path in QUERIES.items()
    }

    # Loop through every combination of query x city
    for query_name, sql_template in query_templates.items():
        for city, file_path in CITIES.items():

            print(f"\nRunning: {query_name} on {city}...")

            try:
                df = run_query(sql_template, file_path)

                print_result(df, query_name, city)

                # Save to outputs/
                saved_path = save_result(df, query_name, city)
                print(f"Saved to: {saved_path}")

            except Exception as e:
                print(f"\n ERROR in {query_name} / {city}:")
                print(f"  {type(e).__name__}: {e}")
                print("  Skipping and continuing...\n")

    print("\n" + "="*60)
    print("All queries complete.")
    print(f"Results saved in: {OUTPUT_DIR}")
    print("="*60)


if __name__ == "__main__":
    main()