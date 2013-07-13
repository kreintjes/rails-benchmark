class HomeController < ApplicationController
  def index
    @objects = AllTypesObject.order(:id).all
    @amounts = 1..3
  end
end