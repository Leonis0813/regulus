require 'fileutils'
require 'minitar'
require 'zlib'
require_relative '../config/settings'

TARGET_MONTH = (Date.today << 1).strftime('%Y-%m')
TMP_DIR = File.join(Settings.application_root, 'tmp')
COMPRESSED_DIR = File.join(TMP_DIR, TARGET_MONTH)
BACKUP_DIR = File.join(Settings.application_root, 'backup')

FileUtils.mkdir_p(COMPRESSED_DIR)

Zlib::GzipWriter.open(File.join(BACKUP_DIR, "#{TARGET_MONTH}.tar.gz"), Zlib::BEST_COMPRESSION) do |gz|
  out = Minitar::Output.new(gz)

  FileUtils.cp(Dir[File.join(BACKUP_DIR, "#{TARGET_MONTH}-*.csv")], COMPRESSED_DIR)
  Dir::chdir(TMP_DIR)
  Dir["#{TARGET_MONTH}/*"].each {|file| Minitar::pack_file(file, out) }

  out.close
end

FileUtils.rm_rf(COMPRESSED_DIR)
