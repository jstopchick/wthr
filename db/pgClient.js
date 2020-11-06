const config = require('./config')
const { Pool } = require('pg')

let pool

const initPool = async(connectionConfig) => {
  if (pool) return
  pool = new Pool(connectionConfig || config.connectionConfig)
}

const doQuery = async (sql, params, connectionConfig) => {
  let client
  await initPool(connectionConfig)
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
