import os
import sedona.db

# PREFIX = "https://source.coop/vida/google-microsoft-osm-open-buildings/geoparquet/by_country_s2"
PREFIX = "s3://us-west-2.opendata.source.coop/vida/google-microsoft-osm-open-buildings/geoparquet/by_country_s2"
os.environ["AWS_SKIP_SIGNATURE"] = "true"
os.environ["AWS_DEFAULT_REGION"] = "us-west-2"

sd = sedona.db.connect()

for country in [
    "ASM",
    "COK",
    "FSM",
    "FJI",
    "PYF",
    "GUM",
    "KIR",
    "MHL",
    "NRU",
    "NCL",
    "NIU",
    "MNP",
    "PLW",
    "PNG",
    "PCN",
    "WSM",
    "SLB",
    "TKL",
    "TON",
    "TUV",
    "VUT",
    "WLF",
]:
    url = f"{PREFIX}/country_iso={country}/*"
    breakpoint()
    x = sd.read_parquet(f"{PREFIX}/country_iso={country}/*.parquet")
    # .to_view( "buildings").to_pandas().to_crs(3832).to_file("data/vida_{country}.gpkg")
    breakpoint()
