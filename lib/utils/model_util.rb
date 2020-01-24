require 'zip'

module ModelUtil
  def valid_model?(model)
    model&.respond_to?(:original_filename) and model.original_filename.end_with?('.zip')
  end

  def output_model(dir, model)
    FileUtils.mkdir_p(dir)
    File.open(File.join(dir, model.original_filename), 'w+b') do |file|
      file.write(model.read)
    end
  end

  def unzip_model(zip_path, output_dir)
    Zip::File.open(zip_path) do |zip|
      zip.each do |entry|
        zip.extract(entry, File.join(output_dir, entry.name))
      end
    end
  end

  def zip_model(entry_dir, zipfile_path)
    Zip::File.open(zipfile_path, ::Zip::File::CREATE) do |zipfile|
      write_entries(entry_dir, Dir[File.join(entry_dir, '*')], '', zipfile)
    end
  end

  private

  def write_entries(entry_dir, entries, path, zipfile)
    entries.each do |entry|
      zipfile_path = path == '' ? entry : File.join(path, entry)
      file_path = File.join(entry_dir, zipfile_path)

      if File.directory?(file_path)
        recursively_deflate_directory(entry_dir, file_path, zipfile, zipfile_path)
      else
        put_into_archive(file_path, zipfile, zipfile_path)
      end
    end
  end

  def recursively_deflate_directory(entry_dir, file_path, zipfile, zipfile_path)
    zipfile.mkdir(zipfile_path)
    sub_entries = Dir[File.join(file_path, '*')]
    write_entries(entry_dir, sub_entries, zipfile_path, zipfile)
  end

  def put_into_archive(file_path, zipfile, zipfile_path)
    zipfile.add(zipfile_path, file_path)
  end
end
