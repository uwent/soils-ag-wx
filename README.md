# AgWeather/Soils website

This codebase generates the agweather website which serves in part as a frontend for the agweather backend API.

## Dependencies

Ruby 3.0.x
```bash
# install rbenv and ruby, then update bundler
sudo apt -y install rbenv
rbenv install 3.0.2 # or latest version
gem install bundler
```

Postgres 12 and gem pg
```bash
# install postgres and gem pg
sudo apt -y install postgresql-12 postgresql-client-12 libpq-dev
sudo service postgresql start
gem install pg

# set postgres user password to 'password'
sudo su - postgres
psql -c "alter user postgres with password 'password'"
exit
```

## Setup

1. Ensure project dependencies outlined above are satisfied
2. Clone the project
3. Install gems with `bundle install` in project directory
4. Create database and schema with `bundle exec rake db:setup`
5. Ensure [ag-weather](https://github.com/uwent/ag-weather) is set up and running on port `8080`
5. Run the server with `bundle exec rails s`
6. Launch the site with `localhost:3000`

## Running Tests

Agweather must be running on port `8080` for some tests to pass.

```bash
bundle exec rake test
```

## Deployment

Work with db admin to authorize your ssh key for the deploy user.
Confirm you can access the dev and production servers:

* `ssh deploy@dev.agweather.cals.wisc.edu -p 216`
* `ssh deploy@agweather.cals.wisc.edu -p 216`

Then run the following commands from the main branch to deploy:

* Staging: `cap staging deploy`
* Production: `cap production deploy`

Deployment targets:

* Staging: [https://dev.agweather.cals.wisc.edu/](https://dev.agweather.cals.wisc.edu/)
* Production: [https://agweather.cals.wisc.edu/](https://agweather.cals.wisc.edu/)

<!-- ## Migration Notes
When migrating from MySQL to PostgreSQL, need to translate:

* All e.g. 'w840' column names to 'w840'
* In all AWON and ASOS tables, old "id" field becomes "stnid"
* "stnid" pseudo-link field with AWON station number becomes real link, awon_station_id
* "stations" table in AWS becomes "awon_stations"
* "theDate" and "theTime" become just "date" and "time" -->
