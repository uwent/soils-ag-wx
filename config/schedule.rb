# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, "/tmp/mailer_whenever.log"
set :env_path, '"$HOME/.rbenv/shims":"$HOME/.rbenv/bin"'
job_type :runner, %q( cd :path && PATH=:env_path:"$PATH" bundle exec rails runner -e :environment ':task' :output )

every :day, at: "7:00am" do
  runner "Subscriber.send_daily_mail"
end

every :day do
  runner "Tasks.purge_subs(delete:true)"
end

every "00,15,30,45 9,10,11 * * *" do
  runner "Hyd.load_file"
end

every "00 13,15,17,19,21 * * *" do
  runner "Hyd.load_file"
end
