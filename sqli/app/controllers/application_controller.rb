class ApplicationController < ActionController::Base
  #protect_from_forgery # Disabled as a precaution (it could hinder the dynamic scanners)
  respond_to :html

  before_filter { ActiveRecord::Base.connection.last_queries = [] } # Clear last queries.

  CONDITIONS_APPLY_METHODS = ["separated", "joined"]
  CONDITIONS_ARGUMENT_TYPES = ["string", "list", "array", "hash"]
  CONDITIONS_PLACEHOLDER_STYLES = ["question_mark", "named", "sprintf"]

  def reload_objects(objects)
    if @all_types_object.respond_to?(:map)
      @all_types_object.map(&:reload)
    else
      @all_types_object.reload
    end
  end
end
