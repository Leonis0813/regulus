require 'mysql2'
require_relative 'config/settings'

def execute_sql(database, sql_file, param)
  query = File.read(sql_file)
  param.each {|key, value| query.gsub!(/$#{key.upcase}/, value) }
  client = Mysql2::Client.new(Settings.mysql.merge('database' => database))
  result = client.query(query)
  client.close
  result
end
