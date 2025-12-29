#!/usr/bin/env bash

VERSION=0-1-1
AWS_PATH="s3://dep-public-staging/dep_osm_buildings"
EEZ_URL="https://dep-public-staging.s3.us-west-2.amazonaws.com/aoi/country_boundary_eez.gpkg"
DATA_FOLDER="data"

ogr2ogr australia-oceania-latest.osm.gpkg \
  /vsicurl/https://download.geofabrik.de/australia-oceania-latest.osm.pbf

ogr2ogr -wrapdateline $DATA_FOLDER/country_boundary_eez.gpkg /vsicurl/$EEZ_URL

ogr2ogr $DATA_FOLDER/dep_buildings_$VERSION.gpkg australia-oceania-latest.osm.gpkg \
  -sql 'SELECT a.*, b.ISO_Ter1 FROM multipolygons a LEFT JOIN "country_boundary_eez.gpkg"."EEZ_IncludingLandMasses" b ON ST_Intersects(a.geom, b.geom) WHERE a.building is not null' \
  -nln dep_buildings -dialect INDIRECT_SQLITE -clipsrc $DATA_FOLDER/country_boundary_eez.gpkg

ogr2ogr $DATA_FOLDER/dep_buildings_$VERSION.geojson $DATA_FOLDER/dep_buildings_$VERSION.gpkg

tippecanoe -z13 -f -l buildings -o $DATA_FOLDER/dep_buildings_$VERSION.pmtiles $DATA_FOLDER/dep_buildings_$VERSION.geojson

ogr2ogr $DATA_FOLDER/dep_buildings_small_$VERSION.gpkg $DATA_FOLDER/dep_buildings_$VERSION.gpkg \
  -sql 'SELECT ISO_Ter1, geom FROM dep_buildings' \
  -dialect sqlite \
  -clipsrc country_boundary_eez.gpkg

aws s3 cp $DATA_FOLDER/dep_buildings_$VERSION.gpkg $AWS_PATH/
aws s3 cp $DATA_FOLDER/dep_buildings_$VERSION.pmtiles $AWS_PATH/
