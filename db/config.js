module.exports = {
  dbSuperUserConnectionConfig: {   // used to rebase the db
    connectionString: 'postgres://postgres:1234@0.0.0.0:5432/template1'
  },
  connectionConfig: {  // db connection for the app
    connectionString: 'postgres://postgres:1234@0.0.0.0:5432/wthr'
  }
}
