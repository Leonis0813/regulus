require 'mysql2'

def import_rates(rate_file)
    client = Mysql2::Client.new(Settings.mysql)
    query = File.read(File.join(Settings.application_root, 'aggregate/import.sql'))
    client.query(query.gsub('$FILE', rate_file))
    client.close
end
