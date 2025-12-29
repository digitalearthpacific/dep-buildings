LOAD spatial;
LOAD httpfs;
SET s3_region='us-west-2';

CREATE TEMP TABLE boundaries as 
    SELECT 
      geometry, 
    FROM read_parquet('s3://overturemaps-us-west-2/release/2025-11-19.0/theme=divisions/type=division_area/*')
  WHERE country in ('AS','CK','FM','FJ','PF','GU','KI','MH',
  'NR','NC','NU','MP','PW','PG','PN','WS',
  'SB','TK','TO','TV','VU', 'WF');


COPY (
  SELECT b.geometry
  FROM read_parquet('s3://overturemaps-us-west-2/release/2025-11-19.0/theme=buildings/type=building/*') AS b,
       boundaries AS d
  WHERE ST_Intersects(b.geometry, d.geometry)
)
TO 'buildings.gpkg'
WITH (FORMAT GDAL, DRIVER 'GPKG');
