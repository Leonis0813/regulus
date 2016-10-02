class RatesController < ApplicationController
  def show
    pair = params[:pair] || 'USDJPY'
    interval = params[:interval] || '5-min'
    @rates = Rate.get_rates(pair, interval)
    @averages = Rate.get_moving_average(pair, interval)
  end

  def update
    @rates = Rate.get_rates(params[:pair], params[:interval])
    @averages = Rate.get_moving_average(params[:pair], params[:interval])
    respond_to do |format|
      format.js
    end
  end
end
