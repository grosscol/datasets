require "datasets"
require "pathname"

module Datasets
  class SaveJob < Job
    @queue = :all

    # @param volume [Volume]
    # @param src_path [Pathname]
    # @param writer [VolumeWriter]
    def initialize(volume, src_path, writer)
      @volume = volume
      @src_path = src_path
      @writer = writer
    end

    def perform
      writer.save(volume, Pathname.new(src_path))
    end

    def serialize
      [volume.to_h, src_path.to_s, writer.id]
    end

    def self.deserialize(volume, src_path, writer_id)
      new(
        Volume.new(volume),
        Pathname.new(src_path),
        Datasets.config.volume_writer_repo.find(writer_id)
      )
    end

    private
    attr_accessor :volume, :src_path, :writer
  end
end