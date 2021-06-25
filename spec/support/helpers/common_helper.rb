module CommonHelper
  def base_url
    ENV['REMOTE_HOST']
  end

  def http_client
    @http_client ||= HTTPClient.new
  end

  def app_auth_header
    return @app_auth_header if @app_auth_header

    credential =
      Base64.strict_encode64("#{Settings.application_id}:#{Settings.application_key}")
    @app_auth_header = {'Authorization' => "Basic #{credential}"}
  end

  def generate_test_case(params)
    [].tap do |test_cases|
      tmp_test_cases = [].tap do |tests|
        Array.wrap(params[params.keys.first]).each do |value|
          tests << {params.keys.first => value}
        end

        params.keys[1..-1].each do |key|
          tmp_tests = [].tap do |tmp_test|
            tests.each do |test|
              Array.wrap(params[key]).each do |value|
                tmp_test << test.merge(key => value)
              end
            end
          end
          tests = tmp_tests
        end
        break tests
      end
      test_cases << tmp_test_cases
    end.flatten
  end

  def generate_combinations(keys)
    [].tap do |combinations|
      keys.size.times do |i|
        combinations << keys.combination(i + 1).to_a
      end
    end.flatten(1)
  end

  module_function :generate_test_case, :generate_combinations
end
