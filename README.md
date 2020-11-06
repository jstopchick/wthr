# wthr
this is a bare-bones demo of nuxt and postgraphile configuration in the context of a very basic IOT scenario.

## tldr low-quality video
https://www.youtube.com/watch?v=exrHwvlsAk8&feature=youtu.be

## major components
- https://www.postgresql.org/
- https://www.graphile.org/postgraphile/
- https://nuxtjs.org/
- https://apollo.vuejs.org/
- https://vue-chartjs.org/

## to run the demo
first, edit the *db/config* file to reflect your environment:
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

# build the database
$ yarn rebase-db

# serve with hot reload at localhost:3000
$ yarn dev
```
nav to http://localhost:3000.  you should see an empty screen.

in a second terminal:
```bash
# start the fake-data-maker
$ yarn fake-data
```
in browser, you will now see a list of station.  selecting one will show you a graph of the collected readings

## db schema
![wthr schema](db/wthr.png)
