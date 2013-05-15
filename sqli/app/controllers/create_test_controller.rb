class CreateTestController < ApplicationController
  def new
    @all_types_object = AllTypesObject.new
    respond_with(@all_types_object)
  end

  def create
    @all_types_object = AllTypesObject.new(params[:all_types_object])
    @all_types_object.save
    respond_with(@all_types_object)
  end
end
