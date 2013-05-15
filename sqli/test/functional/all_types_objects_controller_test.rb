require 'test_helper'

class AllTypesObjectsControllerTest < ActionController::TestCase
  setup do
    @all_types_object = all_types_objects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:all_types_objects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create all_types_object" do
    assert_difference('AllTypesObject.count') do
      post :create, all_types_object: { binary_col: @all_types_object.binary_col, boolean_col: @all_types_object.boolean_col, date_col: @all_types_object.date_col, datetime_col: @all_types_object.datetime_col, decimal_col: @all_types_object.decimal_col, float_col: @all_types_object.float_col, integer_col: @all_types_object.integer_col, string_col: @all_types_object.string_col, text_col: @all_types_object.text_col, time_col: @all_types_object.time_col, timestamp_col: @all_types_object.timestamp_col }
    end

    assert_redirected_to all_types_object_path(assigns(:all_types_object))
  end

  test "should show all_types_object" do
    get :show, id: @all_types_object
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @all_types_object
    assert_response :success
  end

  test "should update all_types_object" do
    put :update, id: @all_types_object, all_types_object: { binary_col: @all_types_object.binary_col, boolean_col: @all_types_object.boolean_col, date_col: @all_types_object.date_col, datetime_col: @all_types_object.datetime_col, decimal_col: @all_types_object.decimal_col, float_col: @all_types_object.float_col, integer_col: @all_types_object.integer_col, string_col: @all_types_object.string_col, text_col: @all_types_object.text_col, time_col: @all_types_object.time_col, timestamp_col: @all_types_object.timestamp_col }
    assert_redirected_to all_types_object_path(assigns(:all_types_object))
  end

  test "should destroy all_types_object" do
    assert_difference('AllTypesObject.count', -1) do
      delete :destroy, id: @all_types_object
    end

    assert_redirected_to all_types_objects_path
  end
end
