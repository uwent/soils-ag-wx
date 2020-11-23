# AgWeather

## Description

Ruby version `2.6.5`
Rails version `6.0.3.2`

## Getting Started

1. Setup
```bash
# create database configuration (copy from template)
cp config/database.yml{.example,}

# create the databases
bundle exec rake db:create db:migrate db:seed db:test:prepare

# install dependencies
bundle install

# run the server!
bundle exec rails server
```
2. [ag-weather, link](https://github.com/adorableio/ag-weather) is set up and running on port 8080

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
