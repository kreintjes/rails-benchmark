class CreateTestController < ApplicationController
  MULTIPLE_AMOUNT = 3

  def new
    # Initiate new object
    @all_types_object = AllTypesObject.new
    respond_with(@all_types_object)
  end

  def create
    # Insert the new object
    AllTypesObject.create(params[:all_types_object])
    # Retrieve the new object fresh from the database. This way the scanners can check if the response is as expected and if there might be an SQL injection.
    @all_types_object = AllTypesObject.last
    respond_with(@all_types_object)
  end

  def new_multiple
    # Initiate <MULTIPLE_AMOUNT> new objects
    AllTypesObject.create({:string_col => ["Hoi", "Doei"]})
    @all_types_objects = Array.new(MULTIPLE_AMOUNT) { AllTypesObject.new }
    respond_with(@all_types_objects)
  end

  def create_multiple
    # Insert the <MULTIPLE_AMOUNT> new objects
    AllTypesObject.create(params[:all_types_objects])
    # Retrieve the <MULTIPLE_AMOUNT> new objects fresh from the database. This way the scanners can check if the response is as expected and if there might be an SQL injection.
    @all_types_objects = AllTypesObject.last(MULTIPLE_AMOUNT)
    respond_with(@all_types_objects)
  end
end
