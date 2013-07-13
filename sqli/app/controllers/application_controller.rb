class ApplicationController < ActionController::Base
  #protect_from_forgery # Disabled as a precaution (it could hinder the dynamic scanners)
  respond_to :html

  before_filter :set_condition_options # Set the condition option modes.
  before_filter :reset_query_log # Clear last queries.

  CONDITION_OPTIONS_FILE = 'public/condition_options.set'

  def reset_query_log
    ActiveRecord::Base.connection.last_queries = []
  end

  def log_query(sql, name)
    ActiveRecord::Base.connection.last_queries << [sql, name]
  end

  # The apply method (separated/joined) determines whether the conditions should be applied seperately (using multiple where/having method calls) or joined in a large statement (using a single where/having method call).
  # The argument type (string/list/array/hash) determines whether the arguments should be applied as a string (one large statement string with values filled in), a list (statement string followed by a list with bind variables), an array (with a statement string and bind variables) or an hash.
  # The placeholder style (question_mark/named/sprintf) determines whether we want to use question mark (?) placeholders, named placeholders (:id) or sprintf type placeholders (%s). This only has effect when the argument type is list or array.
  # The hash style (equality/range/subset) determines whether we want to create an equality condition, range condition (BETWEEN) or subset condition (IN). This only has effect when the argument type is hash.
  def set_condition_options
    # Read condition options from file
    lines = []
    File.open(CONDITION_OPTIONS_FILE, "r").each_line do |l|
      lines << l.chomp
    end
    raise "Condition options file has unexpected number of lines" unless lines.size == 4
    # Set the condition options
    @condition_options = {
      apply_method: lines[0],
      argument_type: lines[1],
      placeholder_style: lines[2],
      hash_style: lines[3]
    }
  end

  def reload_objects(objects)
    if @all_types_object.respond_to?(:map)
      @all_types_object.map(&:reload)
    else
      @all_types_object.reload
    end
  end
end
