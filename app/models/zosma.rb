module Zosma
  class Base < ApplicationRecord
    file_path = Rails.root.join('config/zosma/database.yml')
    establish_connection(YAML.load_file(file_path)[Rails.env])
    self.abstract_class = true
  end
end
