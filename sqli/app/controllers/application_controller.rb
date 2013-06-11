class ApplicationController < ActionController::Base
  #protect_from_forgery
  respond_to :html

  CONDITIONS_APPLY_METHODS = ['separated', 'joined']
  CONDITIONS_ARGUMENT_TYPES = ['string', 'array', 'hash']
  CONDITIONS_PLACEHOLDER_STYLES = ['question_mark', 'named', 'sprintf']

  def reload_objects(objects)
    if @all_types_object.respond_to?(:map)
      @all_types_object.map(&:reload)
    else
      @all_types_object.reload
    end
  end
end
