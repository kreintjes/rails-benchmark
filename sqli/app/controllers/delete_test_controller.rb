class DeleteTestController < ApplicationController
  # We want a form to delete an object/multiple objects through the class method delete.
  def class_delete_form
    params[:method] = "single" if params[:method].nil?
    # Setting some data for the view.
    @multi = (params[:method] == "multi")
    @name = (@multi ? AllTypesObject.model_name.human.pluralize : AllTypesObject.model_name.human)
  end

  # We want to delete an object/multiple objects through the class method delete.
  def class_delete_perform
    # Find and delete the object(s) by its/their ID(s).
    success = AllTypesObject.delete(params[:id])
    objects = (params[:method] == 'single' ? "object #{params[:id]}" : "objects #{params[:id].to_sentence}")
    if success
      redirect_to root_path, :notice => "#{objects} deleted!".capitalize
    else
      redirect_to root_path, :alert => "Deleting #{objects} failed... :("
    end
  end

  # We want a form to destroy an object/multiple objects through the class method destroy.
  def class_destroy_form
    params[:method] = "single" if params[:method].nil?
    # Setting some data for the view.
    @multi = (params[:method] == "multi")
    @name = (@multi ? AllTypesObject.model_name.human.pluralize : AllTypesObject.model_name.human)
  end

  # We want to destroy an object/multiple objects through the class method destroy.
  def class_destroy_perform
    # Find and destroy the object(s) by its/their ID(s).
    success = AllTypesObject.destroy(params[:id])
    objects = (params[:method] == 'single' ? "object #{params[:id]}" : "objects #{params[:id].to_sentence}")
    if success
      redirect_to root_path, :notice => "#{objects} destroyed!".capitalize
    else
      redirect_to root_path, :alert => "Destroying #{objects} failed... :("
    end
  end

  # We want a form to delete objects through the class method delete_all.
  def class_delete_all_form
    @all_types_object = AllTypesObject.new
    params[:method] = "string" if params[:method].nil?
  end

  # We want to delete objects through the class method delete_all.
  def class_delete_all_perform
    # Determine the conditions
    case params[:method]
    when "string"
      # We want to represent the conditions as a string. Rails considers the string to be safe, so we apply our own sanitization through Rails quote method.
      conditions = params[:all_types_object].reject { |k, v| v.blank? }.map { |k, v| "#{k} = #{AllTypesObject.connection.quote(v)}" }.join(",")
    when "array"
      # We want to represent the conditions as an array. Rails applies the sanitization for us.
      conditions = params[:all_types_object].reject { |k, v| v.blank? }.map { |k, v| ["#{k} = ?", v] }.flatten
    when "hash"
      # We want to represent the conditions as a hash. Rails applies the sanitization for us.
      conditions = params[:all_types_object].reject { |k, v| v.blank? }
    else
      raise "Unknown method '#{params[:method]}'"
    end
    # Perform the delete_all
    if conditions.present?
      affected = AllTypesObject.delete_all(conditions)
    else
      affected = 0
      affected = AllTypesObject.delete_all # Enable/disable the delete all without conditions test?
    end
    redirect_to root_path, :notice => "#{affected} object(s) deleted!".capitalize
  end

  # We want a form to destroy objects through the class method destroy_all.
  def class_destroy_all_form
    @all_types_object = AllTypesObject.new
    params[:method] = "string" if params[:method].nil?
  end

  # We want to destroy objects through the class method destroy_all.
  def class_destroy_all_perform
    # Determine the conditions
    case params[:method]
    when "string"
      # We want to represent the conditions as a string. Rails considers the string to be safe, so we apply our own sanitization through Rails quote method.
      conditions = params[:all_types_object].reject { |k, v| v.blank? }.map { |k, v| "#{k} = #{AllTypesObject.connection.quote(v)}" }.join(",")
    when "array"
      # We want to represent the conditions as an array. Rails applies the sanitization for us.
      conditions = params[:all_types_object].reject { |k, v| v.blank? }.map { |k, v| ["#{k} = ?", v] }.flatten
    when "hash"
      # We want to represent the conditions as a hash. Rails applies the sanitization for us.
      conditions = params[:all_types_object].reject { |k, v| v.blank? }
    else
      raise "Unknown method '#{params[:method]}'"
    end
    # Perform the destroy_all
    if conditions.present?
      affected = AllTypesObject.destroy_all(conditions)
    else
      affected = []
      affected = AllTypesObject.destroy_all # Enable/disable the destroy all without conditions test?
    end
    affected = affected.map(&:id).to_sentence
    redirect_to root_path, :notice => "object(s) #{affected} destroyed!".capitalize
  end

  # We want to remove an object through its object methods.
  def object_remove
    # Find the object by its ID.
    @all_types_object = AllTypesObject.find(params[:id])
    case params[:method]
    when "delete", "destroy"
      # And destroy/delete it.
      success = @all_types_object.send(params[:method]);
    else
      raise "Unknown method '#{params[:method]}'"
    end
    if success
      method = params[:method] == 'delete' ? 'deleted' : 'destroyed'
      redirect_to root_path, :notice => "Object #{params[:id]} #{method}!"
    else
      method = params[:method] == 'delete' ? 'Deleting' : 'Destroying'
      redirect_to root_path, :alert => "#{method} object #{params[:id]} failed... :("
    end
  end
end
