import os
import sedona.db

VERSION = "2025-11-19.0"
PREFIX = f"s3://overturemaps-us-west-2/release/{VERSION}"
os.environ["AWS_SKIP_SIGNATURE"] = "true"
os.environ["AWS_DEFAULT_REGION"] = "us-west-2"

sd = sedona.db.connect()

sd.read_parquet(f"{PREFIX}/theme=divisions/type=division_area/").to_view("areas")
sd.read_parquet(f"{PREFIX}/theme=buildings/type=building/").to_view("buildings")

sd.sql(
    """
SELECT b.*
FROM buildings b
JOIN areas a
  ON a.country IN ('AS','CK','FM','FJ','PF','GU','KI','MH','NR','NC','NU','MP','PW','PG','PN','WS','SB','TK','TO','TV','VU', 'WF')
 AND ST_Intersects(b.geometry, a.geometry)
"""
).to_pandas().to_crs(3832).to_file(f"data/dep_overture_buildings_{VERSION}.gpkg")
