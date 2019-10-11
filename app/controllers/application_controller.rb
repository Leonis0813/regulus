class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  rescue_from BadRequest do |e|
    render status: :bad_request, json: {errors: e.errors}
  end

  def valid_model?(model)
    model&.respond_to?(:original_filename) and model.original_filename.end_with?('.zip')
  end
end
