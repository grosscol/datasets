require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "resque/tasks"
require "resque/pool/tasks"
require "resque/scheduler/tasks"

RSpec::Core::RakeTask.new(:spec)


namespace :resque do
  task :setup => :server_setup do
    require "datasets"
    require_relative "config/hathitrust_config.rb"
    config_yml = Pathname.new(__FILE__).expand_path.dirname + "config" + "config.yml"
    Datasets.config = Datasets::HathiTrust::Configuration.from_yaml(config_yml)
  end

  task :server_setup do
    require "resque/server"
    require "resque-retry"
    require "resque-retry/server"
    require "resque-scheduler"
    require "resque/scheduler/server"
  end

  namespace :pool do
    task :setup => "resque:setup" do
      Resque::Pool.after_prefork do |worker|
        # ensure workers don't share parent redis connection
        Resque.redis.client.reconnect
        # don't fork a new process for every job - in particular this prevents
        # using a new connection to redis for every job
        worker.fork_per_job = false
      end
    end
  end

  task :scheduler => :setup

end
