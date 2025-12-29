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

-- We _could_ do this, but ISO values are set from geoboundaries which uses the colonial
-- codes for a lot of these.

-- SELECT country_iso, bf_source as source , count(*) as count,  
-- from read_parquet("s3://us-w est-2.opendata.source.coop/vida/google-microsoft-osm-open-buildings/geoparquet/by_country_s2/**/*") 
--  where country_iso in ('ASM', 'COK', 'FSM', 'FJI', 'PYF', 'GUM', 'KIR', 'MHL', 'NRU',
-- 'NCL', 'NIU', 'MNP', 'PLW', 'PNG', 'PCN', 'WSM', 'SLB', 'TKL', 'TON', 'TUV', 'VUT', 'WLF') 
-- group by country_iso, bf_source order by country_iso;

COPY (
  SELECT b.geometry, b.bf_source from
  read_parquet("s3://us-w est-2.opendata.source.coop/vida/google-microsoft-osm-open-buildings/geoparquet/by_country_s2/**/*") 
  where country_iso in ('ASM', 'COK', 'FSM', 'FJI', 'PYF', 'GUM', 'KIR', 'MHL', 'NRU',
 'NCL', 'NIU', 'MNP', 'PLW', 'PNG', 'PCN', 'WSM', 'SLB', 'TKL', 'TON', 'TUV', 'VUT', 'WLF' 'None') as b, boundaries as d
    WHERE ST_Intersects(b.geometry, d.geometry)
)
  TO 'vida_buildings.gpkg'
  WITH (FORMAT GDAL, DRIVER 'GPKG');
