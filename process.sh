#!/usr/bin/env bash

VERSION=0-1-1
AWS_PATH="s3://dep-public-staging/dep_osm_buildings"

ogr2ogr australia-oceania-latest.osm.gpkg \
  /vsicurl/https://download.geofabrik.de/australia-oceania-latest.osm.pbf

ogr2ogr -wrapdateline country_boundary_eez.gpkg \
  /vsicurl/https://pacificdata.org/data/dataset/964dbebf-2f42-414e-bf99-dd7125eedb16/resource/dad3f7b2-a8aa-4584-8bca-a77e16a391fe/download/country_boundary_eez.geojson

ogr2ogr dep_buildings_$VERSION.gpkg australia-oceania-latest.osm.gpkg \
  -sql 'SELECT a.*, b.ISO_Ter1 FROM multipolygons a LEFT JOIN "country_boundary_eez.gpkg"."EEZ_IncludingLandMasses" b ON ST_Intersects(a.geom, b.geom) WHERE a.building is not null' \
  -nln dep_buildings -dialect INDIRECT_SQLITE -clipsrc country_boundary_eez.gpkg

ogr2ogr dep_buildings_$VERSION.geojson dep_buildings_$VERSION.gpkg

tippecanoe -z13 -f -l buildings -o dep_buildings_$VERSION.pmtiles dep_buildings_$VERSION.geojson

ogr2ogr dep_buildings_small_$VERSION.gpkg dep_buildings_$VERSION.gpkg \
  -sql 'SELECT ISO_Ter1, geom FROM dep_buildings' \
  -dialect sqlite \
  -clipsrc country_boundary_eez.gpkg

aws s3 cp dep_buildings_$VERSION.gpkg $AWS_PATH/
aws s3 cp dep_buildings_$VERSION.pmtiles $AWS_PATH/
