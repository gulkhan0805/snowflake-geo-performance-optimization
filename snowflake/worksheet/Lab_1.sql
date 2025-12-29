-- Snowflake Snowsight Worksheet
-- Lab 1: GEOGRAPHY column + ST_DWITHIN benchmark
-- Assumes: database GEOLAB, schema PERFORMANCE already exists
-- Source table: OPENCELLID.PUBLIC.RAW_CELL_TOWERS

-- Quick sample from source dataset
SELECT radio, mcc, cell, lon::FLOAT, lat::FLOAT, cell_range
FROM OPENCELLID.PUBLIC.RAW_CELL_TOWERS
LIMIT 10;

-- Materialize into lab schema + add GEOGRAPHY point
CREATE OR REPLACE TABLE GEOLAB.PERFORMANCE.RAW_CELL_TOWERS AS
SELECT
  *,
  ST_POINT(lon, lat) AS geog
FROM OPENCELLID.PUBLIC.RAW_CELL_TOWERS;

-- Benchmark 1 (compute point on the fly)
SELECT COUNT(1) AS towers_within_5km_on_the_fly
FROM GEOLAB.PERFORMANCE.RAW_CELL_TOWERS
WHERE ST_DWITHIN(ST_POINT(lon, lat), ST_POINT(0, 51.47684), 5000);

-- Benchmark 2 (use precomputed GEOGRAPHY column)
SELECT COUNT(1) AS towers_within_5km_precomputed_geog
FROM GEOLAB.PERFORMANCE.RAW_CELL_TOWERS
WHERE ST_DWITHIN(geog, ST_POINT(0, 51.47684), 5000);
