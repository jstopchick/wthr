const { Pool } = require('pg')

let pool

const initPool = async() => {
  const connectionString = 'postgres://postgres:1234@0.0.0.0/things_demo'

  if (!connectionString) throw new Error('config.connectionString required')

  pool = new Pool({
    connectionString: connectionString,
  })
}


const doQuery = async (sql, params) => {
  let client
  await initPool()
  try {
    client = await pool.connect()
    const result = await client.query(sql,params)
    return result
  } catch (e) {
    console.log('ERROR: PGCLIENT:', e.toString())
    throw e
  } finally {
    client.release()
  }
}

module.exports = {
  doQuery: doQuery
}
