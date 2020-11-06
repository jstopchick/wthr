begin;
create extension if not exists pgcrypto;
drop schema if exists wthr cascade;
drop schema if exists util_fn cascade;

create schema util_fn;
CREATE FUNCTION util_fn.generate_ulid() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  -- Crockford's Base32
  encoding   BYTEA = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
  timestamp  BYTEA = E'\\000\\000\\000\\000\\000\\000';
  output     TEXT = '';

  unix_time  BIGINT;
  ulid       BYTEA;
BEGIN
  -- 6 timestamp bytes
  unix_time = (EXTRACT(EPOCH FROM NOW()) * 1000)::BIGINT;
  timestamp = SET_BYTE(timestamp, 0, (unix_time >> 40)::BIT(8)::INTEGER);
  timestamp = SET_BYTE(timestamp, 1, (unix_time >> 32)::BIT(8)::INTEGER);
  timestamp = SET_BYTE(timestamp, 2, (unix_time >> 24)::BIT(8)::INTEGER);
  timestamp = SET_BYTE(timestamp, 3, (unix_time >> 16)::BIT(8)::INTEGER);
  timestamp = SET_BYTE(timestamp, 4, (unix_time >> 8)::BIT(8)::INTEGER);
  timestamp = SET_BYTE(timestamp, 5, unix_time::BIT(8)::INTEGER);

  -- 10 entropy bytes
  ulid = timestamp || gen_random_bytes(10);

  -- Encode the timestamp
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 0) & 224) >> 5));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 0) & 31)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 1) & 248) >> 3));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 1) & 7) << 2) | ((GET_BYTE(ulid, 2) & 192) >> 6)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 2) & 62) >> 1));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 2) & 1) << 4) | ((GET_BYTE(ulid, 3) & 240) >> 4)));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 3) & 15) << 1) | ((GET_BYTE(ulid, 4) & 128) >> 7)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 4) & 124) >> 2));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 4) & 3) << 3) | ((GET_BYTE(ulid, 5) & 224) >> 5)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 5) & 31)));

  -- Encode the entropy
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 6) & 248) >> 3));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 6) & 7) << 2) | ((GET_BYTE(ulid, 7) & 192) >> 6)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 7) & 62) >> 1));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 7) & 1) << 4) | ((GET_BYTE(ulid, 8) & 240) >> 4)));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 8) & 15) << 1) | ((GET_BYTE(ulid, 9) & 128) >> 7)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 9) & 124) >> 2));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 9) & 3) << 3) | ((GET_BYTE(ulid, 10) & 224) >> 5)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 10) & 31)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 11) & 248) >> 3));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 11) & 7) << 2) | ((GET_BYTE(ulid, 12) & 192) >> 6)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 12) & 62) >> 1));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 12) & 1) << 4) | ((GET_BYTE(ulid, 13) & 240) >> 4)));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 13) & 15) << 1) | ((GET_BYTE(ulid, 14) & 128) >> 7)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 14) & 124) >> 2));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 14) & 3) << 3) | ((GET_BYTE(ulid, 15) & 224) >> 5)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 15) & 31)));

  RETURN output;
END
$$;




create schema wthr;
-- user defined types

create type wthr.wind_direction as enum (
  'N','NNW','NW','WNW','W','WSW','SW','SSW','S','SSE','SE','ESE','E','ENE','NE','NNE'
);

create type wthr.station_info as (
  identifier text,
  name text,
  latitude text,
  longitude text
);

create type wthr.reading_info as (
  station_info wthr.station_info,
  reading_identifier text,
  reading_timestamp timestamptz,
  temperature numeric(7,3),
  humidity numeric(7,3),
  wind_direction wthr.wind_direction,
  wind_speed integer
);



-- tables
create table wthr.station (
    identifier text not null unique,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name text,
    latitude text,
    longitude text
);

create table wthr.reading (
  id text DEFAULT util_fn.generate_ulid() UNIQUE NOT NULL,
  station_identifier text NOT NULL,
  reading_identifier text,
  captured_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
  reading_timestamp timestamptz,
  temperature numeric(7,3),
  humidity numeric(7,3),
  wind_direction wthr.wind_direction,
  wind_speed integer
);
ALTER TABLE ONLY wthr.reading
    ADD CONSTRAINT pk_reading PRIMARY KEY (id);
ALTER TABLE ONLY wthr.reading
    ADD CONSTRAINT uq_reading UNIQUE (station_identifier, reading_identifier);
ALTER TABLE ONLY wthr.reading
    ADD CONSTRAINT fk_reading_thing FOREIGN KEY (station_identifier) REFERENCES wthr.station (identifier);

-- functions
-- fake-data-maker uses this function directly
-- it is also published as a mutation on the graphql schema
CREATE FUNCTION wthr.capture_reading(_reading_info wthr.reading_info) RETURNS wthr.reading
    LANGUAGE plpgsql
    AS $$
DECLARE
  _station_info wthr.station_info;
  _reading wthr.reading;
BEGIN
  _station_info := _reading_info.station_info::wthr.station_info;
  insert into wthr.station(
    identifier
    ,name
    ,latitude
    ,longitude
  )
  values (
    _station_info.identifier
    ,_station_info.name
    ,_station_info.latitude
    ,_station_info.longitude
  )
  on conflict (identifier)
  do nothing
  ;

  insert into wthr.reading(
    station_identifier
    ,reading_identifier
    ,reading_timestamp
    ,temperature
    ,humidity
    ,wind_direction
    ,wind_speed
  )
  values (
    _station_info.identifier::text
    ,_reading_info.reading_identifier::text
    ,_reading_info.reading_timestamp::timestamptz
    ,_reading_info.temperature::numeric(20,3)
    ,_reading_info.humidity::numeric(20,3)
    ,_reading_info.wind_direction::wthr.wind_direction
    ,_reading_info.wind_speed::integer
  )
  on conflict (station_identifier, reading_identifier)
  do nothing
  returning *
  into _reading;

  RETURN _reading;
END
$$;


-- charting stuff

-- https://www.chartjs.org/docs/latest/charts/line.html
-- these two interfaces are used to allow us to query directly
-- into the chart data so there is no mapping required in the ui
-- might not be desired in all situation, but you could
-- theoretically implement all the types from a given library (chart.js, highcharts.js, etc)
-- to support some rich and fast charting features
create type wthr.line_chart_dataset as (
  label text,
  fill boolean,
  border_color text,
  data text[]
);
create type wthr.line_chart_data as (
  labels text[],
  datasets wthr.line_chart_dataset[]
);

-- this will become a computed column in the graphql schema
-- see the query in:  graphql/query/allStations.graphql
-- currentChartData is a child of station
CREATE FUNCTION wthr.station_current_chart_data(_station wthr.station)
RETURNS wthr.line_chart_data
    LANGUAGE plpgsql stable
    AS $$
DECLARE
  _reading wthr.reading;
  _line_chart_data wthr.line_chart_data;
  _temperature_dataset wthr.line_chart_dataset;
  _humidity_dataset wthr.line_chart_dataset;
BEGIN
  _temperature_dataset.label := 'temperature';
  _humidity_dataset.label := 'humidity';

  _temperature_dataset.fill := false;
  _humidity_dataset.fill := false;

  _temperature_dataset.border_color := '#f87979';
  _humidity_dataset.border_color := '#3482cd';

  for _reading in
    SELECT *
    FROM (
      select *
      from wthr.reading
      where station_identifier = _station.identifier
      order by reading_timestamp desc
      limit 100
    ) r
    order by reading_timestamp asc
  loop
    _line_chart_data.labels := array_append(_line_chart_data.labels, to_char(_reading.reading_timestamp, 'HH24:MI:SS'));
    _temperature_dataset.data := array_append(_temperature_dataset.data, _reading.temperature::text);
    _humidity_dataset.data := array_append(_humidity_dataset.data, _reading.humidity::text);

  end loop;

  _line_chart_data.datasets := array_append(_line_chart_data.datasets, _temperature_dataset);
  _line_chart_data.datasets := array_append(_line_chart_data.datasets, _humidity_dataset);

  RETURN _line_chart_data;
END
$$;


grant select on wthr.station to public;
grant select on wthr.reading to public;

commit;

