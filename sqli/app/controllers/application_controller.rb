class ApplicationController < ActionController::Base
  #protect_from_forgery
  respond_to :html

  def reload_objects(objects)
    if @all_types_object.respond_to?(:map)
      @all_types_object.map(&:reload)
    else
      @all_types_object.reload
    end
  end
end
