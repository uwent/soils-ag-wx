# AgWeather/Soils website

This codebase generates the agweather website which serves in part as a frontend for the agweather backend API.

## Dependencies

`Ruby 3.0.x`
```bash
# install rbenv
sudo apt -y install rbenv

# install ruby-build
mkdir -p "$(rbenv root)"/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

# or update ruby-build if already installed
git -C "$(rbenv root)"/plugins/ruby-build pull

# install ruby with rbenv
rbenv install 3.0.3 # or latest version

# update bundler to latest
gem install bundler
```

`Postgres 12` and `gem pg`
```bash
# install postgres
sudo apt -y install postgresql-12 postgresql-client-12 libpq-dev
sudo service postgresql start

# install gem pg
gem install pg

# Set postgres user password to 'password'
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
6. Run the server with `bundle exec rails s`
7. Launch the site with `localhost:3000`

## Running Tests

### Lint

```bash
# check code for style before commit
bundle exec standardrb --fix
```

### Test

Agweather must be running on port `8080` for some tests to pass.

```bash
bundle exec rake test TESTOPTS = "-v"
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
