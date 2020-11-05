const { postgraphile } = require("postgraphile");

export default postgraphile(
  "postgres://postgres:1234@0.0.0.0/things_demo",
  ['things'],
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
