#!/usr/bin/env bash

ogr2ogr australia-oceania-latest.osm.gpkg /vsicurl/https://download.geofabrik.de/australia-oceania-latest.osm.pbf
ogr2ogr -wrapdateline country_boundary_eez.gpkg /vsicurl/https://pacificdata.org/data/dataset/964dbebf-2f42-414e-bf99-dd7125eedb16/resource/dad3f7b2-a8aa-4584-8bca-a77e16a391fe/download/country_boundary_eez.geojson
ogr2ogr dep_buildings.gpkg australia-oceania-latest.osm.gpkg -sql 'SELECT a.*, b.ISO_Ter1 FROM multipolygons a LEFT JOIN "country_boundary_eez.gpkg"."EEZ_IncludingLandMasses" b ON ST_Intersects(a.geom, b.geom) WHERE a.building is not null' -nln dep_buildings -dialect INDIRECT_SQLITE -clipsrc country_boundary_eez.gpkg
ogr2ogr dep_buildings_small.gpkg dep_buildings.gpkg -sql 'SELECT ISO_Ter1, geom FROM dep_buildings' -dialect sqlite -clipsrc country_boundary_eez.gpkg
