const pgClient = require ('./pgClient')
const interval = require('rxjs').interval

const stations = [
  { identifier: 'WS-1', name: 'station 1', latitude: '111.111', longitude: '111.111' },
  { identifier: 'WS-2', name: 'station 2', latitude: '222.222', longitude: '222.222' },
  { identifier: 'WS-3', name: 'station 3', latitude: '333.333', longitude: '333.333' },
  { identifier: 'WS-4', name: 'station 4', latitude: '444.444', longitude: '444.444' },
]

async function fakeOneReading(offset) {
  const station = stations[(offset % stations.length)]
  const sql = buildSql(station)
  const result = (await pgClient.doQuery(sql)).rows[0].capture_reading
  console.log(result)
}

function buildSql(station) {
  return `
select wthr.capture_reading((
  (
    '${station.identifier}',
    '${station.name}',
    '${station.latitude}',
    '${station.longitude}'
  ),
  null,
  now(),
  random() * 10 + 40,
  random() * 6 + 26,
  (SELECT wd FROM unnest(enum_range(NULL::wthr.wind_direction)) wd ORDER BY random() LIMIT 1),
  random() * 20 + 10
  )::wthr.reading_info);
`
}

const timer = interval(400);

timer.subscribe(x => fakeOneReading(x))
