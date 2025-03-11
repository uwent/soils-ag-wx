# AgWeather/Soils website

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/uwent/soils-ag-wx/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/uwent/soils-ag-wx/tree/main)

This codebase generates the agweather website which serves in part as a frontend for the agweather backend API.

## Dependencies

### Ruby

```bash
# install rbenv
sudo apt -y install rbenv

# install ruby-build
mkdir -p "$(rbenv root)"/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

# or update ruby-build if already installed
git -C "$(rbenv root)"/plugins/ruby-build pull

# may need to force git to use https
# per https://stackoverflow.com/questions/70663523/the-unauthenticated-git-protocol-on-port-9418-is-no-longer-supported
git config --global url."https://github.com/".insteadOf git://github.com/

# install ruby with rbenv
rbenv install 3.4.2 # or latest version

# update bundler to latest
gem install bundler

# update gems...
bundle update

# OR if migrating to a new version of Ruby...
rm Gemfile.lock
bundle install
```

When upgrading Ruby versions, need to change the version number in the documentation above, in `.ruby-version`, and in `config/deploy.rb`.

### Rails

When upgrading to a new version of Rails, run the update task with `THOR_MERGE="code -d $1 $2" rails app:update`. This will use VSCode as the merge conflict tool.

### Postgres

```bash
# install postgres
sudo apt -y install postgresql-16 postgresql-client-16 libpq-dev
sudo service postgresql start

# Set postgres user password to 'password'
sudo su - postgres
psql -c "alter user postgres with password 'password'"
exit

# install gem pg
gem install pg
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

- `ssh deploy@dev.agweather.cals.wisc.edu -p 216`
- `ssh deploy@agweather.cals.wisc.edu -p 216`

Then run the following commands from the main branch to deploy:

- Staging: `cap staging deploy`
- Production: `cap production deploy`

Deployment targets:

- Staging: [https://dev.agweather.cals.wisc.edu/](https://dev.agweather.cals.wisc.edu/)
- Production: [https://agweather.cals.wisc.edu/](https://agweather.cals.wisc.edu/)
