require 'csv'
require 'fileutils'
require 'mysql2'
require_relative '../config/settings'

TMP_FILE = 'tmp/rates.csv'

def import(date)
  rates = Dir["/mnt/smb/*_#{date.strftime('%F')}.csv"].inject([]) do |rates, csv|
    rates += CSV.read(csv, :converters => :all)
  end

  rates.sort_by! {|rate| [rate[0], rate[1]] }
  rates.map! {|rate| [rate[0].strftime('%F %T'), rate[1], rate[2], rate[3]] }

  CSV.open(TMP_FILE, 'w') do |csv|
    rates.each {|rate| csv << rate }
  end

  client = Mysql2::Client.new(Settings.mysql)
  query = File.read(File.join(Settings.application_root, 'aggregate/import.sql'))
  client.query(query.gsub('$FILE', TMP_FILE))
  client.close

  FileUtils.rm(TMP_FILE)
end
