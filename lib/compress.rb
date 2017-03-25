require 'fileutils'
require 'minitar'
require 'zlib'

TARGET_MONTH = Date.today - 1

FileUtils.mkdir_p("tmp/#{TARGET_MONTH.strftime('%Y%m')}")

Zlib::GzipWriter.open("#{TARGET_MONTH.strftime('%Y%m')}.tar.gz", Zlib::BEST_COMPRESSION) do |gz|
  out = Minitar::Output.new(gz)

  FileUtils.cp(Dir["backup/#{TARGET_MONTH.strftime('%Y-%m')}-*.csv"], "tmp/#{TARGET_MONTH.strftime('%Y%m')}")

  Dir["tmp/#{TARGET_MONTH.strftime('%Y%m')}/*"].each do |file|
    Minitar::pack_file(file, out)
  end

  FileUtils.rm_rf("tmp/#{TARGET_MONTH.strftime('%Y%m')}")

  out.close
end

FileUtils.mv("#{TARGET_MONTH.strftime('%Y%m')}.tar.gz", 'backup')
