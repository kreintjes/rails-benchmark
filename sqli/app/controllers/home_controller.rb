class HomeController < ApplicationController
  def index
    @objects = AllTypesObject.order(:id).all
    @amounts = 0..3
=begin
    @tests = {
#=begin
      'create_test' => {
        'class_new' => ['create', 'create_array', 'save'],
      },
#=end
#=begin
      'read_test' => {
        'class_all_form' => nil,
      },
#=end
#=begin
      'update_test' => {
        'object_single_edit' => ['update_attribute', 'update_column', 'increment', 'decrement', 'toggle', 'touch', 'save'],
        'object_multi_edit' => ['update_attributes', 'save'],
        'class_update_edit' => ['single', 'multi'],
        'class_update_all_edit' => ['string', 'array', 'hash']
      },
#=end
#=begin
      'delete_test' => {
        'class_delete_form' => ['single', 'multi'],
        'class_destroy_form' => ['single', 'multi'],
        'class_delete_all_form' => ['string', 'array', 'hash'],
        'class_destroy_all_form' => ['string', 'array', 'hash'],
        'object_remove' => ['delete', 'destroy']
      },
#=end
    }
=end
  end
end