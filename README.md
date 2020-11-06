# wthr
this is a bare-bones demo of nuxt and postgraphile configuration in the context of a very basic IOT scenario.
## major components
- https://www.postgresql.org/
- https://www.graphile.org/postgraphile/
- https://nuxtjs.org/
- https://apollo.vuejs.org/
- https://vue-chartjs.org/

## database set
- create *wthr* database on your postgres server
- 

## build betup

```bash
# install dependencies
$ yarn install

# serve with hot reload at localhost:3000
$ yarn dev

# build for production and launch server
$ yarn build
$ yarn start

# generate static project
$ yarn generate
```

For detailed explanation on how wthr work, check out [Nuxt.js docs](https://nuxtjs.org).

# GraphQL query
```
query {
  allStations {
    nodes {
      identifier
      name
      latitude
      longitue
      currentChartData {
        labels
        datasets {
          label
          data
        }
      }
    }
  }
}
```
