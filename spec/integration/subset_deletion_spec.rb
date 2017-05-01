# frozen_string_literal: true
require "spec_helper"
require "job_helper"
require "datasets"
require_relative "../../config/hathitrust_config"
require "yaml"
require "fileutils"

module Datasets
  RSpec.describe "subset deletion", integration: true do
    include_context "integration" do
      old_timestamp = Time.at(55)
      new_timestamp = Time.at(9999)

      subject { SafeRun.new(:pd).execute }

      context "no previous report exists" do
        context "a volume has mismatched rights" do
          include_context "with volume1 as", :ic, :open , old_timestamp
          include_context "with volume1 paths for", :pd, "ht_text_pd", old_timestamp
          include_context "relative report paths"
          before(:each) do
            volume1_dest_dir.mkpath
            FileUtils.touch(volume1_dest_zip, mtime: new_timestamp)
            FileUtils.touch(volume1_dest_mets, mtime: new_timestamp)
          end

          it "deletes the mismatched volume" do
            subject
            expect(volume1_dest_dir.exist?).to be false
          end

          it "writes a correct report from epoch until now" do
            subject
            expect(File.read(pd_root + saved_report))
              .to be_empty
            expect(File.read(pd_root + deleted_report).split("\n"))
              .to match_array [
                "#{volume1_rights_tuple[:namespace]}.#{volume1_rights_tuple[:id]}"
              ]
            expect(YAML.load_file(pd_root + summary_report))
              .to eql(
                { saved: 0, deleted: 1,
                  start_time: Time.at(0), end_time: Time.now
                }
              )
          end
        end
      end



    end
  end
end
