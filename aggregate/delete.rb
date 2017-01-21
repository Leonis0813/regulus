require 'fileutils'
require_relative 'helper'

def delete
  date = Date.today - 2

  if File.exists?(backup_file(date))
    rates_count = rate_files(date).inject {|count, csv| File.read(csv).count("\n") }
    FileUtils.rm(rate_files) if rates_count = File.read(backup_file).count("\n")
  end
end
