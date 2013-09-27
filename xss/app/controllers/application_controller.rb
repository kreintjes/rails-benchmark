class ApplicationController < ActionController::Base
  #protect_from_forgery
  respond_to :html

  before_filter :parse_method

  RUN_MODE = nil # Let the system decide based on the environment

  BASE_TESTS_ENABLED = true

  def running?
    return RUN_MODE if RUN_MODE.present?
    Rails.env.production?
  end
  helper_method :running?

  # In URLs we replace ? in the method with a -, so the scanners will not mess with it (because they think it is part of the GET query string).
  def parse_method
    params[:method].gsub!('-', '?') if params[:method].present?
  end
end
