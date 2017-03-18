require 'fileutils'
require_relative 'helper'

TARGET_DATE = Date.today - 2
BACKUP_FILE = backup_file(TARGET_DATE)
REMOVED_FILES = rate_files(TARGET_DATE)

if File.exists?(BACKUP_FILE) and not REMOVED_FILES.empty?
  rates_count = REMOVED_FILES.inject {|count, csv| count + File.read(csv).lines.size }
  FileUtils.rm(REMOVED_FILES) if rates_count == File.read(BACKUP_FILE).lines.size
end
