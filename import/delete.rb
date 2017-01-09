require 'fileutils'

def delete
  day = (Date.today - 2).strftime('%F')

  backup_file = "backup/#{day}.csv"
  if File.exists?(backup_file)
    rate_files = Dir["/mnt/smb/*_#{day}.csv"]
    rates_count = rate_files.inject {|count, csv| File.read(csv).count("\n") }
    FileUtils.rm(rate_files) if rates_count = File.read(backup_file).count("\n")
  end
end
