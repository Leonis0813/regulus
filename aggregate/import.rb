require 'csv'
require 'fileutils'
require 'mysql2'
require_relative '../config/settings'

def import(date)
  rates = Dir[File.join(Settings.csv_dir, "*_#{date.strftime('%F')}.csv")].inject([]) do |rates, csv|
    rates += CSV.read(csv, :converters => :all)
  end

  rates.sort_by! {|rate| [rate[0], rate[1]] }
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
