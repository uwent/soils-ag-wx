# AgWeather

## Description

Ruby version `2.7.2`

Rails version `6.0.3.4`

## Setup

1. create database configuration (copy from template)
`cp config/database.yml{.example,}`

2. create the databases
`bundle exec rake db:create db:migrate db:seed db:test:prepare`

3. install dependencies
`bundle install`

4. run the server!
`bundle exec rails server`

5. [ag-weather](https://github.com/uwent/ag-weather) is set up and running on port 8080

## Running Tests
```bash
bundle exec rake test
```

## Deployment
Work with db admin to authorize your ssh key for the deploy user, then run the following commands from the master branch:

Staging:
```
  cap staging deploy
```

Production:
```
  cap production deploy
```

## Migration Notes
When migrating from MySQL to PostgreSQL, need to translate:

* All e.g. 'w840' column names to 'w840'
* In all AWON and ASOS tables, old "id" field becomes "stnid"
* "stnid" pseudo-link field with AWON station number becomes real link, awon_station_id
* "stations" table in AWS becomes "awon_stations"
* "theDate" and "theTime" become just "date" and "time"
