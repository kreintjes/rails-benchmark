class CreateTestController < ApplicationController
  # We want a form to insert a new object/multiple new objects into the database through the Class methods.
  def class_new
    # Initiate new object.
    params[:method] = "create" if params[:method].nil?
    case params[:method]
    when 'create_array'
      # Build multiple (params[:amount]) new objects.
      @all_types_object = Array.new(params[:amount].to_i) { AllTypesObject.new }
    else
      # Build a single new object.
      @all_types_object = AllTypesObject.new
    end
    respond_with(@all_types_object)
  end

  # We want to insert the new object(s) into the database via the through methods.
  def class_create
    case params[:method]
    when "save"
      # Make new object, set attributes and save it.
      @all_types_object = AllTypesObject.new
      params[:all_types_object].each do |attribute, value|
        @all_types_object.send("#{attribute}=", value)
      end
      @all_types_object.save
    when "create_array"
      # Create and directly insert the new objects into the database.
      @all_types_object = AllTypesObject.create(params[:all_types_object].presence || [])
    when "create"
      # Create and directly insert the new object into the database.
      @all_types_object = AllTypesObject.create(params[:all_types_object])
    else
      raise "Unknown method '#{params[:method]}'"
    end

    # Retrieve the new object(s) fresh from the database. This way the scanners can check if the response is as expected and if there might be an SQL injection.
    reload_objects(@all_type_object)
    respond_with(@all_types_object)
  end
end
