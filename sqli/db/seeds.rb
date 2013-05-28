# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# This script will generate <amount> times three objects: a nil object, an object initialized with default values and an object initialized with random values.
amount = 5
amount.times do
  AllTypesObject.create
  AllTypesObject.create({
    :binary_col => 0x0,
    :boolean_col => false,
    :date_col => "0000-00-00",
    :datetime_col => "0000-00-00 00:00:00",
    :decimal_col => 0.00,
    :float_col => 0.0000000000,
    :integer_col => 0,
    :string_col => "",
    :text_col => "",
    :time_col => "00:00:00.000000",
    :timestamp_col => "0000-00-00 00:00:00.000000"
  })
  AllTypesObject.create({
    :binary_col => 0x0123456789ABCDEF,
    :boolean_col => true,
    :date_col => DateTime.now,
    :datetime_col => DateTime.now,
    :decimal_col => 123.45,
    :float_col => 123.4567890,
    :integer_col => 123,
    :string_col => "Dit is een string",
    :text_col => "Dit is hele lange teksssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssst",
    :time_col => Time.new,
    :timestamp_col => Time.new.utc
  })
end