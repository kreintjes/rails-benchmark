class CreateTestController < ApplicationController
  def class_new
    # Initiate new object
    params[:method] = "create" if params[:method].nil?
    case params[:method]
    when 'create_array'
      @all_types_object = Array.new(params[:amount].to_i) { AllTypesObject.new }
    else
      @all_types_object = AllTypesObject.new
    end
    respond_with(@all_types_object)
  end

  def class_create
    case params[:method]
    when "save"
      # Make new object, set attributes and save it.
      @all_types_object = AllTypesObject.new
      params[:all_types_object].each do |attribute, value|
        @all_types_object.send("#{attribute}=", value)
      end
      @all_types_object.save
    when "create", "create_array"
      # Insert the new object(s).
      @all_types_object = AllTypesObject.create(params[:all_types_object].presence || [])
    else
      raise "Unknown method '#{params[:method]}'"
    end

    # Retrieve the new object fresh from the database. This way the scanners can check if the response is as expected and if there might be an SQL injection.
    (@all_types_object.respond_to?(:map) ? @all_types_object.map(&:reload) : @all_types_object.reload)
    respond_with(@all_types_object)
  end
end
