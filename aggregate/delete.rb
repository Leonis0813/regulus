require 'fileutils'
require_relative 'helper'
require_relative '../lib/logger'

TARGET_DATE = Date.today - 2
BACKUP_FILE = backup_file(TARGET_DATE)
REMOVED_FILES = rate_files(TARGET_DATE)

if File.exists?(BACKUP_FILE) and not REMOVED_FILES.empty?
  rates_count = REMOVED_FILES.inject(0) {|count, csv| count + File.read(csv).lines.size }
  if rates_count == File.read(BACKUP_FILE).lines.size
    FileUtils.rm(REMOVED_FILES)
    Logger.write(:backup_file => BACKUP_FILE, :removed_files => REMOVED_FILES, :num_of_rates => rates_count)
  end
end
