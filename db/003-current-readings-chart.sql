begin;
-- drop type things.line_chart_dataset cascade;
-- drop type things.line_chart_data cascade;

create type things.line_chart_dataset as (
  label text,
  data text[]
);

create type things.line_chart_data as (
  labels text[],
  datasets things.line_chart_dataset[]
);

CREATE FUNCTION things.weather_station_current_chart_data(_weather_station things.weather_station)
RETURNS things.line_chart_data
    LANGUAGE plpgsql stable
    AS $$
DECLARE
  _line_chart_data things.line_chart_data;
  _reading things.ws_reading;
  _temperature_datasets things.line_chart_dataset;
BEGIN
  _temperature_datasets.label := 'temperature';

  for _reading in
    SELECT *
    FROM (
      select *
      from things.ws_reading
      where ws_identifier = _weather_station.identifier
      order by reading_timestamp desc
      limit 100
    ) r
    order by reading_timestamp asc
  loop
    _line_chart_data.labels := array_append(_line_chart_data.labels, to_char(_reading.reading_timestamp, 'HH24:MI:SS'));
    _temperature_datasets.data := array_append(_temperature_datasets.data, _reading.temperature::text);
  end loop;

  _line_chart_data.datasets := array_append(_line_chart_data.datasets, _temperature_datasets);

  RETURN _line_chart_data;
END
$$;


select * from things.weather_station;
\x on
select things.weather_station_current_chart_data(ws) from things.weather_station ws where identifier = 'WS-1';

commit;
