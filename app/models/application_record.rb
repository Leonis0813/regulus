class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  STATE_PROCESSING = 'processing'.freeze
  STATE_COMPLETED = 'completed'.freeze
  STATE_ERROR = 'error'.freeze
  DEFAULT_STATE = STATE_PROCESSING
  STATE_LIST = [STATE_PROCESSING, STATE_COMPLETED, STATE_ERROR].freeze
end
