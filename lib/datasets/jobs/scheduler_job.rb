require "datasets/job"
require "datasets/safe_run"

module Datasets
  class SchedulerJob < Job

    def initialize(profile)
      @profile = profile
    end

    def enqueue(queue = :schedule)
      super(queue)
    end

    def perform
      SafeRun.new(profile).execute
    end

    def serialize
      [profile.to_s]
    end

    def self.deserialize(profile)
      new(profile.to_sym)
    end

    private
    attr_accessor :profile
  end
end