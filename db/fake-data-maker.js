const pgClient = require ('./pgClient')
const interval = require('rxjs').interval

const stations = [
  { identifier: 'WS-1', name: 'weather station 1', latitude: '111.111', longitude: '111.111' },
  { identifier: 'WS-2', name: 'weather station 2', latitude: '222.222', longitude: '222.222' },
  { identifier: 'WS-3', name: 'weather station 3', latitude: '333.333', longitude: '333.333' },
  { identifier: 'WS-4', name: 'weather station 4', latitude: '444.444', longitude: '444.444' },
]

async function fakeOneReading(offset) {
  const weatherStation = stations[(offset % stations.length)]
  // console.log(offset, weatherStation)
  const sql = buildSql(weatherStation)
  // console.log(sql)
  const result = (await pgClient.doQuery(sql)).rows[0].capture_reading
  console.log(result)
}

function buildSql(weatherStation) {
  return `
select things.capture_reading((
  (
    '${weatherStation.identifier}',
    '${weatherStation.name}',
    '${weatherStation.latitude}',
    '${weatherStation.longitude}'
  ),
  null,
  now(),
  random() * 10 + 40,
  random() * 6 + 26,
  (SELECT wd FROM unnest(enum_range(NULL::things.wind_direction)) wd ORDER BY random() LIMIT 1),
  random() * 20 + 10
  )::things.ws_reading_info);
`
}

const timer = interval(400);

timer.subscribe(x => fakeOneReading(x))

// const fakeOne = numbers.pipe();

// fakeOne.subscribe(x => fakeOneReading(stations[((stations.length+1) % (x+1))-1]));

// async function start() {
//   await fakeOneReading(stations[0])
//   process.exit()
// }
// start()
