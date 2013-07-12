class HomeController < ApplicationController
  def index
    @objects = AllTypesObject.order(:id).all
    @amounts = 0..3
  end
end