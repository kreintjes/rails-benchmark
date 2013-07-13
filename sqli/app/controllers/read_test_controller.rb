class ReadTestController < ApplicationController
  before_filter :only => [:class_objects_perform, :class_value_perform, :class_by_sql_perform] { @show_last_queries = true }

  FIND_SUB_METHODS = ['all', 'first', 'last']
  CALCULATE_SUB_METHODS = ['average', 'count', 'minimum', 'maximum', 'sum']
  ASSOCIATIONS = ['belongs_to', 'has_one', 'has_many', 'has_and_belongs_to_many']

  # We want a form to read multiple objects through a class method.
  def class_objects_form
    case params[:method]
    when "first", "last"
      @partial = "amount"
    when "dynamic_find_by", "dynamic_find_by!"
      @partial = "dynamic_find_by"
    when "find_each", "find_in_batches"
      @partial = "batches"
    when "first_or_initialize", "first_or_create", "first_or_create!"
      @partial = "attributes"
    when "find"
      @partial = parse_option
    end
  end

  # We want to read multiple objects through a class method.
  def class_objects_perform
    # Build the relation depending on the various options (query methods).
    relation = AllTypesObject.scoped
    # Extract and apply query methods
    relation = apply_query_methods(relation, params)

    # Perform the query
    case params[:method]
    when "first", "last"
      amount = params[:amount].to_i if params[:amount].present?
      @results = relation.send(params[:method], *amount)
    when "to_a", "all", "first!", "last!"
      @results = relation.send(params[:method])
    when "select"
      @results = relation.send(params[:method]) { true } # Select with a block acts as a finder method. The block simply returns true to not futher limit the results.
    when "find"
      case params[:option]
      when "sub_method"
        raise "Unknown sub method '#{params[:sub_method]}'" unless FIND_SUB_METHODS.include?(params[:sub_method])
        @results = relation.send(params[:method], params[:sub_method].to_sym)
      when "single_id"
        @results = relation.send(params[:method], params[:id])
      when "id_list"
        @results = relation.send(params[:method], *params[:id])
      when "id_array"
        @results = relation.send(params[:method], params[:id])
      end
    when "dynamic_find_by", "dynamic_find_by!"
      method = "find_by_#{params[:attribute]}" + (params[:method] == "dynamic_find_by!" ? "!" : "")
      @results = relation.send(method, params[:value])
    when "find_each", "find_in_batches"
      @results = []
      options = {}
      options[:start] = params[:start].to_i if params[:start].present?
      options[:batch_size] = params[:batch_size].to_i if params[:batch_size].present?
      relation.send(params[:method], options) { |results| @results << results }
    when "first_or_initialize", "first_or_create", "first_or_create!"
      @results = relation.send(params[:method], params[:attributes].presence)
    else
      raise "Unknown method '#{params[:method]}'"
    end

    # Wrap the result(s) in array and flatten (since the template expects an array of results)
    @all_types_objects = [@results].flatten

    @includes = relation.eager_load_values + relation.includes_values + relation.preload_values

    respond_with(@all_types_objects)
  end

  # We want a form to determine some value from a database table through a class method.
  def class_value_form
    case params[:method]
    when "exists?"
      @partial = parse_option
    when "average", "count", "maximum", "minimum", "sum", "calculate", "pluck"
      # Render the column name field.
      @partial = "calculate"
      @sub_method = true, @column_name_nil = true, @distinct = true if params[:method] == 'calculate'
      @column_name_nil = true, @distinct = true if params[:method] == 'count'
    end
  end

  # We want to determine some value from a database table through a class method.
  def class_value_perform
    # Build the relation depending on the various options (query methods).
    relation = AllTypesObject.scoped
    # Extract and apply query methods
    relation = apply_query_methods(relation, params)

    # Perform the query
    case params[:method]
    when "any?", "empty?", "many?", "size", "explain"
      @result = relation.send(params[:method])
    when "exists?"
      case params[:option]
      when "id"
        @result = relation.send(params[:method], params[:id])
      when "conditions_array"
        @result = relation.send(params[:method], build_conditions('joined', 'array', params[:conditions]).flatten)
      when "conditions_hash"
        @result = relation.send(params[:method], *build_conditions('joined', 'hash', params[:conditions]).flatten)
      else
        @result = relation.send(params[:method])
      end
    when "average", "count", "maximum", "minimum", "sum", "calculate", "pluck"
      options = [{ :distinct => (params[:distinct] == "true") }] if params[:distinct].present? # Only count and calculate take distinct (and actually only calculate with sub_method=count used distinct)
      sub_method = [params[:sub_method].to_sym] if params[:method] == "calculate" # Only calculate takes a sub_method. For other methods sub method is ignored and not used as an argument.
      @result = relation.send(params[:method], *sub_method, params[:column_name].presence, *options)
    else
      raise "Unknown method '#{params[:method]}'"
    end

    respond_with(@result)
  end

  # We want a form to read through the class ..._by_sql methods.
  def class_by_sql_form
    # Nothing to do here
  end

  # We want to read through the class ..._by_sql methods.
  def class_by_sql_perform
    # Determine the base query
    case params[:method]
    when "find_by_sql"
      query = "SELECT * FROM all_types_objects"
    when "count_by_sql"
      query = "SELECT COUNT(*) FROM all_types_objects"
    else
      raise "Unknown method '#{params[:method]}'"
    end

    case params[:option]
    when 'string'
      # Build the conditions.
      conditions = build_conditions('joined', 'string', params[:conditions]).first
      # And append them to the query
      query += ' WHERE ' + conditions.first if conditions.present?
    when 'array'
      # Build the conditions.
      conditions = build_conditions('joined', 'array', params[:conditions]).first
      # And rebuild the query such that it is an array with a statement and bind values for that statement.
      query = [query + ' WHERE ' + conditions.first.shift, *conditions.first] if conditions.present?
    end

    # Perform the query
    @result = AllTypesObject.send(params[:method], query)

    respond_with(@result)
  end

  # Helper functions
private
  # Determine the needed partial for the option
  def parse_option
    case params[:option]
    when "id", "single_id"
      # Render the id select field.
      "shared/id_select"
    when "id_list", "id_array"
      # Render the id multi select field.
      "shared/id_multi_select"
    when "conditions_array", "conditions_hash"
      # Render the conditions fields.
      @partial = "conditions"
    when "sub_method", "amount", "dynamic_find_by", "batches", "attributes"
      # Render the corresponding option field(s).
      params[:option]
    end
  end

  # Extract query methods (finder options) from params and apply them to the relation.
  def apply_query_methods(relation, params)
    # Simple options
    # Add the limit option (numeric value).
    relation = relation.limit(params[:limit]) if params[:limit].present?
    # Add the offset option (numeric value).
    relation = relation.offset(params[:offset]) if params[:offset].present?
    # Add the unique option (boolean value).
    relation = relation.uniq(params[:uniq]) if params[:uniq].present?

    # Conditions
    # Build and apply the where conditions.
    relation = build_and_apply_conditions(relation, :where, params[:where]) if params[:where].present?
    # Build and apply the having conditions.
    if params[:having].present?
      relation = build_and_apply_conditions(relation, :having, params[:having])
      # relation the database columns used in the having clause to the group clause or else an exception will occur.
      having_columns = params[:having].select { |column, value| value.present? }.keys
      relation = relation.group(having_columns.join(',')) if having_columns.present?
    end

    # Associations
    # Add the eager_load option (string value).
    relation = relation.eager_load(*params[:eager_load]) if params[:eager_load].present? # We only test the list argument type were we supply a list of strings. This is equivalent to calling the method with a single, list or array of strings/symbols.
    # Add the includes option (string value).
    relation = relation.includes(*params[:includes]) if params[:includes].present? # We only test the list argument type were we supply a list of strings. This is equivalent to calling the method with a single, list or array of strings/symbols.
    # Add the joins option (string value).
    relation = relation.joins(*params[:joins].map(&:to_sym)) if params[:joins].present? # We only test the list argument type were we supply a list of symbols (since supplying strings is not safe). This is equivalent to calling the method with a single, list or array of symbols.
    # Add the preload option (string value).
    relation = relation.preload(*params[:preload]) if params[:preload].present? # We only test the list argument type were we supply a list of strings. This is equivalent to calling the method with a single, list or array of strings/symbols.

    # Others
    relation = relation.create_with(params[:create_with]) if params[:create_with].present?

    relation
  end

  # Build and apply the conditions (in data) on relation using method.
  # Uses all the global @condition_options.
  def build_and_apply_conditions(relation, method, values)
    # Build the conditions
    conditions = build_conditions(values)
    # Apply the formatted conditions on the relation using method.
    apply_conditions(relation, method, conditions)
  end

  # Apply formatted conditions (method arguments) on the relation using method.
  def apply_conditions(relation, method, conditions)
    conditions.each { |condition| relation = relation.send(method, *condition) if condition.present? }
    relation
  end

  # Build/format conditions, either separated or joined.
  def build_conditions(apply_method = nil, argument_type = nil, values)
    apply_method = @condition_options[:apply_method] if apply_method.nil?
    if(apply_method == 'separated')
      # We want to apply the conditions separated (one where call per condition). Build an array containing all the separate conditions in the right format.
      conditions = build_separated_conditions(argument_type, values)
    else
      # We want to apply the conditions joined (one where call for all conditions). Build an array containing one large condition in the right format.
      conditions = build_joined_conditions(argument_type, values)
    end
    conditions = conditions.delete_if { |c| c.nil? } # Delete conditions that resulted in nil (there was no value set for that column).
    log_query(conditions.map(&:inspect).to_sentence, 'Conditions Built') if conditions.present? # Log the conditions in the query log, so we know what is going on.
    conditions
  end

  # Build/format separated conditions. Returns an array with a (formatted) element for each condition.
  def build_separated_conditions(argument_type, values)
    values.map { |column, value| build_condition(argument_type, column, value) }
  end

  # Build/format joined conditions. Returns an array with one formatted element representing all the conditions.
  def build_joined_conditions(argument_type, values)
    conditions = nil
    values.each do |column, value|
      # Format the next condition
      condition = build_condition(argument_type, column, value)
      # And merge it with the already existing conditions.
      conditions = merge_conditions(conditions, condition) if condition.present?
    end
    # Wrap the single large condition in an array (with one element), because apply_conditions expects the conditions to be an array.
    [conditions]
  end

  # This methods builds a condition using the given argument_type on "column = value" (or for hash conditions probably "column IN values" or "column BETWEEN value AND value).
  # We do not extract the argument type from the @condition_options, since we need to be able to overwrite it for the exists? and ..._by_sql methods.
  # It returns a list (array) of arguments for the where (or similar method) call on the relation.
  def build_condition(argument_type = nil, column, value)
    return nil if value.blank? # Reject blank values (this means we do not want to filter on this column)
    argument_type = @condition_options[:argument_type] if argument_type.nil?
    case argument_type
    when "string"
      # We want to represent the condition as a string. Rails does not apply the sanitization for us (it considers the string safe), so we apply sanitization ourselves using Rails' helper methods.
      ["#{column} = #{AllTypesObject.connection.quote(value)}"]
    when "list"
      # We want to represent the condition as a list (with a string SQL statement and bind values). Rails applies the sanitization for us.
      build_list_condition(column, value)
    when "array"
      # We want to represent the condition as an array (with the bind values in an array). Rails applies the sanitization for us.
      # This is very similar to the list argument_type (actually, a list with a string SQL statement and bind values is mapped to an array in Rails), we only need to wrap the result in an array.
     [build_list_condition(column, value)]
    when "hash"
      # We want to represent the conditions as a hash. Rails applies the sanitization for us.
      # Placeholder style is ignored for hash arguments (it has no meaning)
      build_hash_condition(column, value)
    else
      raise "Condition option argument type '#{argument_type}' not supported (it is possible Rails supports this type, but we do not)."
    end
  end

  # Builds a list/array condition for colum and value using the set placeholder style.
  def build_list_condition(column, value)
     case @condition_options[:placeholder_style]
      when "question_mark"
        # Use question mark placeholders. The bind variables are a list/array.
        ["#{column} = ?", value]
      when "named"
        # Use named placeholders. The bind variables are a hash.
        ["#{column} = :#{column}", {column.to_sym => value}]
      when "sprintf"
        # Use sprintf placeholders. The bind variables are a list/array.
        ["#{column} = '%s'", value] # Rails applies the sanitization, but we still have to put quotes around the variable ourselves
      else
        raise "Condition option placeholder style '#{@condition_options[:placeholder_style]}' not supported."
      end
  end

  # Builds a hash condition for colum and value using the set hash style.
  def build_hash_condition(column, value)
     case @condition_options[:hash_style]
      when "equality"
        # We want an equality condition. Directly use value.
        [{ column => value }]
      when "range"
        # We want a range condition. Wrap value in a range.
        [{ column => value..value }]
      when "subset"
        # We want a subset condition. Wrap value in an array.
        [{ column => [value] }]
      else
        raise "Condition option hash style '#{@condition_options[:hash_style]}' not supported."
      end
  end

  # This methods merges the already existing formatted conditions (list) with the new formatted condition (list).
  # For string and array conditions this means the statements are concatenated with the logical AND operator as glue and the bind variables are merged (array addition for question mark and sprintf placeholders, hash merge for named placeholders)
  # For hash conditions this is a simple hash merge (which Rails will map to conditions also joined by the logical AND operator)
  def merge_conditions(conditions, condition)
    return condition if conditions.blank?
    case condition.first
    when String
      # We want to represent the conditions as an AND concatenated string followed by the (possible) bind values in a list.
      # Merge the statement (head of the array) with a simple string concatenation
      statement = conditions.shift + ' AND ' + condition.shift
      # Merge the bind variables (tail of the array).
      if conditions.one? && conditions.first.is_a?(Hash) && condition.one? && conditions.first.is_a?(Hash)
        # The bind variables are in Hash format. Perform a hash merge and put the result in a list. In this case the bind variables are a simple list consisting of one element (which is a hash)
        bind_vars = [conditions.first.merge(condition.first)]
      else
        # The bind variables are lists of values. Merge the lists with an array addition. In this case the bind variables are a large list consisting of multiple elements.
        bind_vars = conditions + condition
      end
      [statement, *bind_vars]
    when Array
      # We want to represent the conditions as an array with an AND concatened string as the first value and all the bind values as the remaining values.
      # This is very similar to the strsing merging argument_type (actually, a string with bind values is mapped to an array in Rails), we only need to wrap the result in an array one more time.
     [merge_conditions(conditions.first, condition.first)]
    when Hash
      # We want to represent the conditions as a hash. Simply merge the hashes.
      [conditions.first.merge(condition.first)]
    else
      raise "Unknown conditions format #{conditions.first.class}"
    end
  end
end
