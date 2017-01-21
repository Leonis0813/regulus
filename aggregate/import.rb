require 'csv'
require 'fileutils'
require 'mysql2'
require_relative 'helper'
require_relative '../config/settings'

def import(date)
  rate_files(date).each do |rate_file|
    rates = CSV.read(rate_file, :converters => :all)
    rates.map! {|rate| [rate[0].strftime('%F %T'), rate[1], rate[2], rate[3]] }

    CSV.open(Settings.tmp_file, 'w') do |csv|
      rates.each {|rate| csv << rate }
    end

    client = Mysql2::Client.new(Settings.mysql)
    query = File.read(File.join(Settings.application_root, 'aggregate/import.sql'))
    client.query(query.gsub('$FILE', Settings.tmp_file))
    client.close

    FileUtils.rm(Settings.tmp_file)
  end
end
