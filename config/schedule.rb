# default cron env is "/usr/bin:/bin" which is not sufficient as govuk_env is in /usr/local/bin
env :PATH, "/usr/local/bin:/usr/bin:/bin"

# We need Rake to use our own environment
job_type :rake, "cd :path && govuk_setenv short-url-manager bundle exec rake :task :output"

set :output, error: "log/cron.error.log", standard: "log/cron.log"

# every :day, at: "4am" do
#   rake "organisations:import"
# end
