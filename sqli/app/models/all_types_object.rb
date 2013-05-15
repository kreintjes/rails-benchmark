class AllTypesObject < ActiveRecord::Base
  attr_accessible :binary_col, :boolean_col, :date_col, :datetime_col, :decimal_col, :float_col, :integer_col, :string_col, :text_col, :time_col, :timestamp_col
end
