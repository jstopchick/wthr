const config = require('../config')
const pgClient = require ('./pgClient')
const fs = require('fs')

async function rebaseDb() {
  await pgClient.doQuery('drop database if exists wthr;',null,config.dbSuperUserConnectionConfig)
  await pgClient.doQuery('create database wthr;',null,config.dbSuperUserConnectionConfig)
  const sql = (await fs.readFileSync('./db/wthr-db.sql')).toString()
  await pgClient.doQuery(sql)

  return 'wthr db successfully rebuilt'
}

rebaseDb()
.then((result)=>{
  console.log(result)
})
.catch(e => {
  console.error(error)
})
.finally(() => {
  process.exit();
});
