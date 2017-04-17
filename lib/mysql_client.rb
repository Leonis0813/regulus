require 'mysql2'
require_relative 'logger'
require_relative '../config/settings'

class MySQLClient
  SQL_PATH = File.join(Settings.application_root, 'aggregate')

  def initialize
    @client = Mysql2::Client.new(Settings.mysql)
  end

  def import_rates(rate_file)
    query = File.read(File.join(SQL_PATH, 'import.sql'))

    Logger.write_with_runtime(:param => {:file => rate_file}) do
      execute_query(query.gsub('$FILE', rate_file))
    end
  end

  def get_rates(date)
    query = File.read(File.join(SQL_PATH, 'backup.sql'))
    day = date.strftime('%F')

    Logger.write_with_runtime(:param => {:day => day}) do
      execute_query(query.gsub('$DAY', day))
    end
  end

  def create_candle_sticks(param)
    query = File.read(File.join(Settings.application_root, 'aggregate.sql'))
    param.each {|key, value| query.gsub!("$#{key.upcase}", value) }

    Logger.write_with_runtime(:param => param) do
      execute_query(query)
    end
  end

  private

  def execute_query(query)
    begin
      @client.query(query)
    rescue
    end
  end
end
