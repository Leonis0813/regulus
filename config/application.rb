require File.expand_path('boot', __dir__)

require 'rails/all'

Bundler.require(*Rails.groups)

module Regulus
  class Application < Rails::Application
    config.i18n.default_locale = :ja
    config.active_job.queue_adapter = :resque
    config.autoload_paths += ["#{config.root}/lib/errors", "#{config.root}/lib/utils"]
  end
end
