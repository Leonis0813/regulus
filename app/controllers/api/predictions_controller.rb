module Api
  class PredictionsController < ApplicationController
    def index
      query = Query.new(index_param)
      if query.valid?
        @predictions = Prediction.where(index_param.slice(:means, :pair))
                                 .order(created_at: :desc)
                                 .page(query.page)
                                 .per(query.per_page)
        render status: :ok, template: 'predictions/predictions'
      else
        error_codes = query.errors.messages.keys.map {|key| "invalid_param_#{key}" }
        raise BadRequest, error_codes
      end
    end

    private

    def index_param
      @index_param ||= params.permit(:means, :page, :pair, :per_page)
    end
  end
end
