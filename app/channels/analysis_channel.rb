class AnalysisChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'analysis'
  end

  def unsubscribed
  end
end
