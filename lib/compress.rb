require 'fileutils'
require 'minitar'
require 'zlib'
require_relative 'logger'
require_relative '../config/settings'

TARGET_MONTH = (Date.today << 1).strftime('%Y-%m')
TMP_DIR = File.join(Settings.application_root, 'tmp')
COMPRESSED_DIR = File.join(TMP_DIR, TARGET_MONTH)
COMPRESSED_FILES = Dir[File.join(BACKUP_DIR, "#{TARGET_MONTH}-*.csv")]
BACKUP_DIR = File.join(Settings.application_root, 'backup')
GZIP_FILE = "#{TARGET_MONTH}.tar.gz"

FileUtils.mkdir_p(COMPRESSED_DIR)

Logger.write_with_runtime(:gzip_file => GZIP_FILE, :compressed_files => COMPRESSED_FILES.map {|file| File.basename(file) }) do
  Zlib::GzipWriter.open(File.join(BACKUP_DIR, GZIP_FILE), Zlib::BEST_COMPRESSION) do |gz|
    out = Minitar::Output.new(gz)

    FileUtils.cp(COMPRESSED_FILES, COMPRESSED_DIR)
    Dir.chdir(TMP_DIR)
    Dir["#{TARGET_MONTH}/*"].each {|file| Minitar::pack_file(file, out) }

    out.close
  end
end

FileUtils.rm_rf(COMPRESSED_DIR)
