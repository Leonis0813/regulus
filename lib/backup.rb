require 'fileutils'

SRC_DIR = '/mnt/sakura/regulus'
DST_DIR = '/mnt/backup/regulus'

src_files = Dir[File.join(SRC_DIR, '*.tar.gz')].map {|file_path| File.basename(file_path) }
dst_files = Dir[File.join(DST_DIR, '*.tar.gz')].map {|file_path| File.basename(file_path) }

(src_files - dst_files).each {|file_name| FileUtils.cp(File.join(SRC_DIR, file_name), DST_DIR) }
