class UpdateTestController < ApplicationController
  # We want a form to edit a single attribute of an object through its instance methods.
  def object_single_edit
    # Find the object we want to edit (by its ID).
    @all_types_object = AllTypesObject.find(params[:id])
    params[:method] = "update_attribute" if params[:method].nil?
    case params[:method]
    when "increment", "decrement"
      # Render the by field.
      @partial = "by"
    when "toggle", "touch"
      # Do not render extra fields.
      @partial = nil
    else
      # Render the value field.
      @partial = "value"
    end
  end

  # We want to update a single attribute of the object through its instance methods.
  def object_single_update
    # Find the object we want to update by its ID.
    @all_types_object = AllTypesObject.find(params[:id])
    case params[:method]
    when "increment", "decrement"
      # Increment the object's attribute :attribute by :by with Rails increment! method.
      begin
        # First try it with the raw data (which will be a string).
        @all_types_object.send("#{params[:method]}!", params[:attribute], params[:by])
      rescue TypeError=>e
        # This likely fails, since increment/decrement expects by to be an integer or nil. Try again with a typecast.
        if(params[:by].present?)
          @all_types_object.send("#{params[:method]}!", params[:attribute], params[:by].to_i)
        else
          @all_types_object.send("#{params[:method]}!", params[:attribute])
        end
      end
    when "toggle"
      # Toggle (boolean switch) the attribute :attribute with Rails toggle! method.
      @all_types_object.toggle!(params[:attribute])
    when "touch"
      # Touch (update with current timestamp) the attribute :attribute with Rails touch method.
      @all_types_object.touch(*params[:attribute].presence)
    when "save", "save!"
      # Update the attribute :attribute with value :value by using its setter and saving the object.
      @all_types_object.send("#{params[:attribute]}=", params[:value])
      @all_types_object.send(params[:method])
    when "update_attribute", "update_column"
      # Update the object's attribute :attribute with value :value with Rails update_attribute or update_column method.
      @all_types_object.send(params[:method], params[:attribute], params[:value])
    else
      raise "Unknown method '#{params[:method]}'"
    end
    # Retrieve the updated object fresh from the database. This way the scanners can check if the response is as expected and if there might be an SQL injection.
    reload_objects(@all_type_object)
    respond_with(@all_types_object)
  end

  # We want a form to edit multiple attributes of an object through its instance methods.
  def object_multi_edit
    # Find the object we want to edit by its ID.
    @all_types_object = AllTypesObject.find(params[:id])
    params[:method] = "update_attributes" if params[:method].nil?
  end

  # We want to update multiple attributes of the object through its instance methods.
  def object_multi_update
    # Find the object we want to edit by its ID.
    @all_types_object = AllTypesObject.find(params[:id])
    case params[:method]
    when "save", "save!"
      # Update the attributes by using their setters and saving the object.
      params[:all_types_object].each do |attribute, value|
        @all_types_object.send("#{attribute}=", value)
      end
      @all_types_object.send(params[:method])
    when "update_attributes", "update_attributes!"
      # Update the attributes for the object with Rails basic update_attributes method.
      @all_types_object.send(params[:method], params[:all_types_object])
    else
      raise "Unknown method '#{params[:method]}'"
    end
    # Retrieve the updated object fresh from the database. This way the scanners can check if the response is as expected and if there might be an SQL injection.
    reload_objects(@all_type_object)
    respond_with(@all_types_object)
  end

  # We want a form to edit multiple attributes of an object/multiple objects through the class method update.
  def class_update_edit
    @all_types_object = AllTypesObject.new
    params[:method] = "single" if params[:method].nil?
    # Setting some data for the view.
    @multi = (params[:method] == "multi")
    @name = (@multi ? AllTypesObject.model_name.human.pluralize : AllTypesObject.model_name.human)
  end

  # We want to update multiple attributes of an object/multiple objects through the class method update.
  def class_update_update
    if params[:method] == "multi"
      # Convert the attributes to an array of attributes (one for each of the objects we want to edit).
      params[:all_types_object] = Array.new(params[:id].size) { params[:all_types_object] }
    end
    # Find and update the object(s) by its/their ID(s) through the class update method.
    AllTypesObject.update(params[:id], params[:all_types_object])
    # Retrieve the updated object(s) fresh from the database. This way the scanners can check if the response is as expected and if there might be an SQL injection.
    @all_types_object = AllTypesObject.find(params[:id])
    respond_with(@all_types_object)
  end

  # We want a form to edit multiple attributes of objects through the class method update_all.
  def class_update_all_edit
    @all_types_object = AllTypesObject.new
    params[:method] = "string" if params[:method].nil?
  end

  # We want to update multiple attributes of objects through the class method update_all.
  def class_update_all_update
    # Determine the updates.
    case params[:method]
    when "string"
      # We want to represent the updates as a string. Rails considers the string to be safe, so we apply our own sanitization through Rails quote method.
      # XXX TODO This is a bit of an artificial use of this method. Should we even include this test or just stick with the safe array and hash methods (and test the quote method in some other way)?
      updates = params[:all_types_object].reject { |k, v| v.blank? }.map { |k, v| "#{k} = #{AllTypesObject.connection.quote(v)}" }.join(",")
    when "array"
      # We want to represent the updates as an array. Rails applies the sanitization for us.
      updates = params[:all_types_object].reject { |k, v| v.blank? }.map { |k, v| ["#{k} = ?", v] }.flatten
    when "hash"
      # We want to represent the updates as a hash. Rails applies the sanitization for us.
      updates = params[:all_types_object].reject { |k, v| v.blank? }
    else
      raise "Unknown method '#{params[:method]}'"
    end
    # Determine the conditions.
    conditions = nil # XXX TODO are we going to support this option? It is basically a where call, so we will consider it anyway with the Read tests.
    # Determine the options (limit and order).
    options = {}
    options[:limit] = params[:limit] if params[:limit].present?
    options[:order] = params[:order] if params[:order].present?
    # Perform the update_all
    AllTypesObject.update_all(updates, conditions, options)
    # Retrieve the updated objects fresh from the database. This way the scanners can check if the response is as expected and if there might be an SQL injection.
    begin
      @all_types_objects = AllTypesObject.where(conditions).apply_finder_options(options)
    rescue
       # The code above could insert an extra SQL injection. We try to capture this and show all (with a maximum of 100 records to prevent timeouts) objects as a fallback.
      @all_types_objects = AllTypesObject.order(:id).limit(100).all
    end
    respond_with(@all_types_objects)
  end
end
