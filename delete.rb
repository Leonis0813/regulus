require 'fileutils'

DAY = ARGV[1] ? ARGV[1] : Date.today.strftime('%F')

backup_file = "backup/#{DAY}.csv"
if File.exists?(backup_file)
  rate_files = Dir["/mnt/smb/*_#{DAY}.csv"]
  rates_count = rate_files.inject {|count, csv| File.read(csv).count("\n") }
  FileUtils.rm(rate_files) if rates_count = File.read(backup_file).count("\n")
end
