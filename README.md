# wthr
this is a bare-bones, no security or configuration, demo of nuxt-postgraphile setup in the context of a basic IOT scenario; capturing and analyzing weather station readings.
## db schema
![wthr schema](db/wthr.png)
## tldr video
https://www.youtube.com/watch?v=exrHwvlsAk8
## major components
- https://www.postgresql.org/
- https://www.graphile.org/postgraphile/
- https://nuxtjs.org/
- https://apollo.vuejs.org/
- https://vue-chartjs.org/
## to run the demo
first, edit the *config.js* file to reflect your environment:
```
module.exports = {
  dbSuperUserConnectionConfig: {   // used to rebase the db
    connectionString: 'postgres://postgres:1234@0.0.0.0:5432/template1'
  },
  connectionConfig: {  // db connection for the app
    connectionString: 'postgres://postgres:1234@0.0.0.0:5432/wthr'
  }
}
```
then:
```bash
# install dependencies
$ yarn install

# build the database - uses dbSuperUserConnectionConfig from config
$ yarn rebase-db

# serve with hot reload at localhost:3000
$ yarn dev
```
at http://localhost:3000 you should see an empty screen.
at http://localhost:3000/graphiql you can query the api and browse the published schema via docs
## create some fake data
in a second terminal:
```bash
# start the fake-data-maker
$ yarn fake-data
```
in browser, you will now see a list of stations. selecting one will show you a graph of the collected readings
