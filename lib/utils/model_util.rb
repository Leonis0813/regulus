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
end
