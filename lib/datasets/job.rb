require "resque"
require "resque-retry"
require "resque/failure/redis"

Resque::Failure::MultipleWithRetrySuppression.classes = [Resque::Failure::Redis]
Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression

module Datasets
  class Job
    extend Resque::Plugins::Retry
    extend Resque::Plugins::ExponentialBackoff
    @backoff_strategy = [60, 300, 600, 3600, 7200]
    @expire_retry_key_after = @backoff_strategy.last + 3600
    @retry_limit = 10

    def self.perform(*args)
      new(*deserialize(*args)).perform
    end

    def enqueue
      Resque.enqueue(self.class, *serialize)
    end

    def serialize
      raise NotImplementedError
    end

    def self.deserialize(*args)
      raise NotImplementedError
    end

  end
end