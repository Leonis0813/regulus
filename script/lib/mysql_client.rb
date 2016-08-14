require 'mysql2'

def execute_sql(database, sql_file, params)
  query = File.read(sql_file)
  params.each {|key, value| query.gsub!(/$#{key.upcase}/, value) }
  client = Mysql2::Client.new(Settings.mysql.merge('database' => database))
  result = client.query(query)
  client.close
  result
end
