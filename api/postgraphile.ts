const config = require('../config')
const { postgraphile } = require("postgraphile");

export default postgraphile(
  config.connectionConfig,
  ['wthr'],
  {
    watchPg: true,
    graphiql: true,
    enhanceGraphiql: true,
    disableDefaultMutations: true,
    dynamicJson: true,
    disableQueryLog: process.env.DISABLE_QUERY_LOG !== "false",
    extendedErrors: ["detail", "errcode"],
    allowExplain: true,
  }
)
