\c things_demo

begin;
create extension if not exists pgcrypto;
drop schema if exists things cascade;
create schema things;

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

create table things.weather_station (
    identifier text not null unique,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name text,
    latitude text,
    longitue text
);

create type things.wind_direction as enum (
  'N','NNW','NW','WNW','W','WSW','SW','SSW','S','SSE','SE','ESE','E','ENE','NE','NNE'
);


create type things.weather_station_info as (
  identifier text,
  name text,
  latitude text,
  longitude text
);

create type things.ws_reading_info as (
  ws_info things.weather_station_info,
  reading_identifier text,
  reading_timestamp timestamptz,
  temperature numeric(7,3),
  humidity numeric(7,3),
  wind_direction things.wind_direction,
  wind_speed integer
);

create table things.ws_reading (
  id text DEFAULT util_fn.generate_ulid() UNIQUE NOT NULL,
  ws_identifier text NOT NULL,
  reading_identifier text,
  captured_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
  reading_timestamp timestamptz,
  temperature numeric(7,3),
  humidity numeric(7,3),
  wind_direction things.wind_direction,
  wind_speed integer
);
ALTER TABLE ONLY things.ws_reading
    ADD CONSTRAINT pk_ws_reading PRIMARY KEY (id);
ALTER TABLE ONLY things.ws_reading
    ADD CONSTRAINT uq_ws_reading UNIQUE (ws_identifier, reading_identifier);
ALTER TABLE ONLY things.ws_reading
    ADD CONSTRAINT fk_ws_reading_thing FOREIGN KEY (ws_identifier) REFERENCES things.weather_station (identifier);


CREATE FUNCTION things.capture_reading(_ws_reading_info things.ws_reading_info) RETURNS things.ws_reading
    LANGUAGE plpgsql
    AS $$
DECLARE
  _weather_station_info things.weather_station_info;
  _reading things.ws_reading;
BEGIN
  _weather_station_info := _ws_reading_info.ws_info::things.weather_station_info;
  insert into things.weather_station(
    identifier
    ,name
    ,latitude
    ,longitue
  )
  values (
    _weather_station_info.identifier
    ,_weather_station_info.name
    ,_weather_station_info.latitude
    ,_weather_station_info.longitude
  )
  on conflict (identifier)
  do nothing
  ;

  insert into things.ws_reading(
    ws_identifier
    ,reading_identifier
    ,reading_timestamp
    ,temperature
    ,humidity
    ,wind_direction
    ,wind_speed
  )
  values (
    _weather_station_info.identifier::text
    ,_ws_reading_info.reading_identifier::text
    ,_ws_reading_info.reading_timestamp::timestamptz
    ,_ws_reading_info.temperature::numeric(20,3)
    ,_ws_reading_info.humidity::numeric(20,3)
    ,_ws_reading_info.wind_direction::things.wind_direction
    ,_ws_reading_info.wind_speed::integer
  )
  on conflict (ws_identifier, reading_identifier)
  do nothing
  returning *
  into _reading;

  RETURN _reading;
END
$$;

grant select on things.weather_station to public;
grant select on things.ws_reading to public;

commit;

