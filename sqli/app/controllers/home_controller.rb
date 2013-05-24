class HomeController < ApplicationController
  def index
    @objects = AllTypesObject.order(:id).limit(10).all
    @amounts = 0..3
    @tests = {
      'create_test' => {
        'class_new' => ['create', 'create_array', 'save'],
      },
      #'read_test' => {
      #  'void' => ['void'],
      #},
      'update_test' => {
        'object_single_edit' => ['update_attribute', 'update_column', 'increment', 'decrement', 'toggle', 'touch', 'save'],
        'object_multi_edit' => ['update_attributes', 'save'],
        'class_update_edit' => ['single', 'multi'],
        'class_update_all_edit' => ['string', 'array', 'hash']
      },
      'delete_test' => {
        'class_delete_form' => ['single', 'multi'],
        'class_destroy_form' => ['single', 'multi'],
        'class_delete_all_form' => ['string', 'array', 'hash'],
        'class_destroy_all_form' => ['string', 'array', 'hash'],
        'object_remove' => ['delete', 'destroy']
      },
    }
  end
end
