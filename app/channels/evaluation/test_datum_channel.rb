class Evaluation::TestDatumChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'evaluation_test_datum'
  end
end
