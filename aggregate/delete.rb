require 'fileutils'

def delete
  date_str = (Date.today - 2).strftime('%F')

  backup_file = File.join(Settings.application_root, Settings.backup_dir, "#{date_str}.csv")
  if File.exists?(backup_file)
    rate_files = Dir[File.join(Settings.csv_dir, "*_#{date_str}.csv")]
    rates_count = rate_files.inject {|count, csv| File.read(csv).count("\n") }
    FileUtils.rm(rate_files) if rates_count = File.read(backup_file).count("\n")
  end
end
