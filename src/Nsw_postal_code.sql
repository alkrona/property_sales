-- Create schema
CREATE SCHEMA IF NOT EXISTS PTV;

-- NSW data filtering queries
-- Creating the necessary tables and loading data for NSW postcodes

-- Table creation and data loading for the agency
CREATE TABLE ptv.agency(
    agency_id numeric,
    agency_name varchar,
    agency_url varchar,
    agency_timezone varchar,
    agency_lang varchar
);

COPY ptv.agency(agency_id, agency_name, agency_url, agency_timezone, agency_lang)
FROM '/data/adata/gtfs/agency.txt'
DELIMITER ','
CSV HEADER;

-- Table creation and data loading for calendar
CREATE TABLE ptv.calendar (
    service_id VARCHAR PRIMARY KEY,
    monday numeric,
    tuesday numeric,
    wednesday numeric,
    thursday numeric,
    friday numeric,
    saturday numeric,
    sunday numeric,
    start_date DATE,
    end_date DATE
);

COPY ptv.calendar(service_id, monday, tuesday, wednesday, thursday, friday, saturday, sunday, start_date, end_date)
FROM '/data/adata/gtfs/calendar.txt'
DELIMITER ','
CSV HEADER;

-- Table creation and data loading for calendar_dates
CREATE TABLE ptv.calendar_dates (
    service_id VARCHAR,
    date DATE,
    exception_type numeric
);

COPY ptv.calendar_dates(service_id, date, exception_type)
FROM '/data/adata/gtfs/calendar_dates.txt'
DELIMITER ','
CSV HEADER;

-- Table creation and data loading for routes
CREATE TABLE ptv.routes(
    route_id VARCHAR,
    agency_id VARCHAR,
    route_short_name VARCHAR,
    route_long_name VARCHAR,
    route_type VARCHAR,
    route_color VARCHAR,
    route_text_color VARCHAR
);

COPY ptv.routes(route_id, agency_id, route_short_name, route_long_name, route_type, route_color, route_text_color)
FROM '/data/adata/gtfs/routes.txt'
DELIMITER ','
CSV HEADER;

-- Table creation and data loading for stops
CREATE TABLE ptv.stops(
    stop_id VARCHAR,
    stop_name VARCHAR,
    stop_lat FLOAT,
    stop_lon FLOAT
);

COPY ptv.stops(stop_id, stop_name, stop_lat, stop_lon)
FROM '/data/adata/gtfs/stops.txt'
DELIMITER ','
CSV HEADER;

-- Table creation and data loading for trips
CREATE TABLE ptv.trips(
    route_id VARCHAR,
    service_id VARCHAR,
    trip_id VARCHAR,
    shape_id VARCHAR,
    trip_headsign VARCHAR,
    direction_id NUMERIC
);

COPY ptv.trips(route_id, service_id, trip_id, shape_id, trip_headsign, direction_id)
FROM '/data/adata/gtfs/trips.txt'
DELIMITER ','
CSV HEADER;

-- Table creation and data loading for shapes
CREATE TABLE ptv.shapes(
    shape_id VARCHAR,
    shape_pt_lat FLOAT,
    shape_pt_lon FLOAT,
    shape_pt_sequence NUMERIC,
    shape_dist_traveled FLOAT
);

COPY ptv.shapes(shape_id, shape_pt_lat, shape_pt_lon, shape_pt_sequence, shape_dist_traveled)
FROM '/data/adata/gtfs/shapes.txt'
DELIMITER ','
CSV HEADER;

-- Table creation and data loading for stop_times
CREATE TABLE ptv.stop_times(
    trip_id VARCHAR,
    arrival_time VARCHAR,
    departure_time VARCHAR,
    stop_id VARCHAR,
    stop_sequence NUMERIC,
    stop_headsign VARCHAR,
    pickup_type NUMERIC,
    drop_off_type NUMERIC,
    shape_dist_traveled VARCHAR
);

COPY ptv.stop_times(trip_id, arrival_time, departure_time, stop_id, stop_sequence,
stop_headsign, pickup_type, drop_off_type, shape_dist_traveled)
FROM '/data/adata/gtfs/stop_times.txt'
DELIMITER ','
CSV HEADER;

-- Filtering NSW postcodes (assuming there is a field for NSW in the tables such as `state_name_2021`)
-- Creating a table for NSW data

-- For NSW-related data
DROP TABLE IF EXISTS ptv.nsw_data;
CREATE TABLE ptv.nsw_data AS
SELECT *
FROM ptv.mb_2021
WHERE state_name_2021 = 'New South Wales';

SELECT COUNT(*) FROM ptv.nsw_data;

-- Filtering the stops related to NSW
DROP TABLE IF EXISTS ptv.stops_nsw;
CREATE TABLE ptv.stops_nsw AS
SELECT s.*
FROM ptv.stops s
JOIN ptv.nsw_data n ON ST_Contains(n.geometry, ST_SetSRID(ST_MakePoint(s.stop_lon, s.stop_lat), 4326));

SELECT * FROM ptv.stops_nsw;

-- Filtering stop_times for NSW stops
DROP TABLE IF EXISTS ptv.stop_times_nsw;
CREATE TABLE ptv.stop_times_nsw AS
SELECT st.*
FROM ptv.stop_times st
WHERE st.stop_id IN (
    SELECT DISTINCT stop_id
    FROM ptv.stops_nsw
);

SELECT * FROM ptv.stop_times_nsw;

-- Trip count for NSW-related stops
SELECT s.state_name_2021, COUNT(DISTINCT t.trip_id) AS trip_count
FROM ptv.stop_times_nsw t
JOIN ptv.stops_nsw s ON t.stop_id = s.stop_id
GROUP BY s.state_name_2021
ORDER BY trip_count DESC;

-- Average number of trips per stop per LGA for NSW
SELECT s.state_name_2021, COUNT(DISTINCT t.trip_id) / COUNT(DISTINCT s.stop_id) AS avg_trips_per_stop
FROM ptv.stop_times_nsw t
JOIN ptv.stops_nsw s ON t.stop_id = s.stop_id
GROUP BY s.state_name_2021
ORDER BY avg_trips_per_stop DESC;

-- Total distance traveled per NSW LGA
SELECT s.state_name_2021, SUM(t.shape_dist_traveled) AS total_distance
FROM ptv.stop_times_nsw t
JOIN ptv.stops_nsw s ON t.stop_id = s.stop_id
GROUP BY s.state_name_2021
ORDER BY total_distance DESC;

-- Most common pickup/drop-off type in NSW
SELECT s.state_name_2021, 
       COUNT(CASE WHEN t.pickup_type = 0 THEN 1 END) AS regular_pickups,
       COUNT(CASE WHEN t.drop_off_type = 0 THEN 1 END) AS regular_dropoffs
FROM ptv.stop_times_nsw t
JOIN ptv.stops_nsw s ON t.stop_id = s.stop_id
GROUP BY s.state_name_2021
ORDER BY regular_pickups DESC, regular_dropoffs DESC;
