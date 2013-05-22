class HomeController < ApplicationController
  def index
    @objects = AllTypesObject.order(:id).limit(3).all
    @amounts = 0..3
    @tests = {
      'create_test' => {
        'class_new' => ['create', 'create_array', 'save'],
      },
      'update_test' => {
        'object_single_edit' => ['update_attribute', 'update_column', 'increment', 'decrement', 'toggle', 'touch', 'save'],
        'object_multi_edit' => ['update_attributes', 'save'],
        'class_update_edit' => ['single', 'multi'],
        'class_update_all_edit' => ['string', 'array', 'hash']
      }
    }
  end
end
