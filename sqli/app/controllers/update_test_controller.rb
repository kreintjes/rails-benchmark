class UpdateTestController < ApplicationController
  def object_single_edit
    # Find the object we want to edit (by its ID)
    @all_types_object = AllTypesObject.find(params[:id])
    params[:method] = "update_attribute" if params[:method].nil?
    case params[:method]
    when "increment", "decrement"
      @partial = "by"
    when "toggle", "touch"
      @partial = nil
    else
      @partial = "value"
    end
  end

  def object_single_update
    # Find the object we want to edit (by its ID)
    @all_types_object = AllTypesObject.find(params[:id])
    case params[:method]
    when "increment", "decrement"
      # Increment the object's attribute :attribute by :by (with Rails increment! method)
      begin
        @all_types_object.send("#{params[:method]}!", params[:attribute], params[:by])
      rescue TypeError=>e
        @all_types_object.send("#{params[:method]}!", params[:attribute], params[:by].to_i)
      end
    when "toggle"
      @all_types_object.toggle!(params[:attribute])
    when "touch"
      @all_types_object.touch(*params[:attribute].presence)
    when "save"
      @all_types_object.send("#{params[:attribute]}=", params[:value])
      @all_types_object.save
    when "update_attribute", "update_column"
      # Update the object's attribute :attribute with value :value (with Rails update_attribute or update_column method)
      @all_types_object.send(params[:method], params[:attribute], params[:value])
    else
      raise "Unknown method '#{params[:method]}'"
    end
    @all_types_object.reload
    respond_with(@all_types_object)
  end

  def object_multi_edit
    # Find the object we want to edit (by its ID)
    @all_types_object = AllTypesObject.find(params[:id])
    params[:method] = "update_attributes" if params[:method].nil?
  end

  def object_multi_update
    # Find the object we want to edit (by its ID)
    @all_types_object = AllTypesObject.find(params[:id])
    case params[:method]
    when "save"
      params[:all_types_object].each do |attribute, value|
        @all_types_object.send("#{attribute}=", value)
      end
      @all_types_object.save
    when "update_attributes"
      # Update the attributes for the object (with Rails basic update_attributes method)
      @all_types_object.send(params[:method], params[:all_types_object])
    else
      raise "Unknown method '#{params[:method]}'"
    end
    @all_types_object.reload
    respond_with(@all_types_object)
  end

  def class_update_edit
    @all_types_object = AllTypesObject.new
    params[:method] = "single" if params[:method].nil?
    @multi = (params[:method] == "multi")
    @name = (@multi ? AllTypesObject.model_name.human.pluralize : AllTypesObject.model_name.human)
  end

  def class_update_update
    if params[:method] == "multi"
      params[:all_types_object] = Array.new(params[:id].size) { params[:all_types_object] }
    end
    # Find the object we want to edit (by its ID)
    AllTypesObject.update(params[:id], params[:all_types_object])
    @all_types_object = AllTypesObject.find(params[:id])
    respond_with(@all_types_object)
  end

  def class_update_all_edit
    @all_types_object = AllTypesObject.new
    params[:method] = "string" if params[:method].nil?
  end

  def class_update_all_update
    now = DateTime.now
    case params[:method]
    when "string"
      updates = params[:all_types_object].reject { |k, v| v.blank? }.map { |k, v| "#{k} = #{AllTypesObject.connection.quote(v)}" }.join(",")
    when "array"
      updates = params[:all_types_object].reject { |k, v| v.blank? }.map { |k, v| ["#{k} = ?", v] }.flatten
    when "hash"
      updates = params[:all_types_object].reject { |k, v| v.blank? }
    else
      raise "Unknown method '#{params[:method]}'"
    end
    conditions = nil # XXX TODO?
    options = {}
    options[:limit] = params[:limit] if params[:limit].present?
    options[:order] = params[:order] if params[:order].present?
    AllTypesObject.update_all(updates, conditions, options)
    begin
      @all_types_objects = AllTypesObject.where(conditions).apply_finder_options(options)
    rescue
       # The code above could insert an extra SQL injection. We try to capture this and show all (with a maximum of 100 records to prevent timeouts) objects instead.
      @all_types_objects = AllTypesObject.limit(100).all
    end
    respond_with(@all_types_objects)
  end
end
