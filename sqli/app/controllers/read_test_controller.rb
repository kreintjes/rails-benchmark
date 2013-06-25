class ReadTestController < ApplicationController
  FIND_SUB_METHODS = ['all', 'first', 'last']
  CALCULATE_SUB_METHODS = ['average', 'count', 'minimum', 'maximum', 'sum']

  # We want a form to read multiple objects through the class method all.
  def class_all_form
    params[:method] = "all" if params[:method].nil?
    if params[:option]
      case params[:option]
      when "sub_method"
        # Render the sub_method field.
        @partial = "sub_method"
      when "single_id"
        # Render the id select field.
        @partial = "shared/id_select"
      when "id_list", "id_array"
        # Render the id multi select field.
        @partial = "shared/id_multi_select"
      when "amount"
        # Render the amount field.
        @partial = "amount"
      when "dynamic_find_by"
        # Render the attribute and value fields needed for the dynamic find by.
        @partial = "dynamic_find_by"
      end
    end
  end

  # We want to read multiple objects through the class method all.
  def class_all_perform
    # Build the relation depending on the various options (query methods).
    relation = AllTypesObject.scoped
    # Extract and apply query methods
    relation = apply_query_methods(relation, params)
    # Perform the query
    case params[:method]
    when "first", "last"
      if params[:option].present? && params[:option] == "amount"
        results = relation.send(params[:method], params[:amount].to_i)
      else
        results = relation.send(params[:method])
      end
    when "to_a", "all", "first!", "last!"
      results = relation.send(params[:method])
    when "find"
      case params[:option]
      when "sub_method"
        raise "Unknown sub method '#{params[:sub_method]}'" unless FIND_SUB_METHODS.include?(params[:sub_method])
        results = relation.send(params[:method], params[:sub_method].to_sym)
      when "single_id"
        results = relation.send(params[:method], params[:id])
      when "id_list"
        results = relation.send(params[:method], *params[:id])
      when "id_array"
        results = relation.send(params[:method], params[:id])
      end
    when "dynamic_find_by", "dynamic_find_by!"
      method = "find_by_#{params[:attribute]}" + (params[:method] == "dynamic_find_by!" ? "!" : "")
      results = relation.send(method, params[:value])
    else
      raise "Unknown method '#{params[:method]}'"
    end

    # Wrap the result(s) in array and flatten (since the template expects an array of results)
    @all_types_objects = [results].flatten

    respond_with(@all_types_objects)
  end

  # We want a form to determine some value from a database table through a class method.
  def class_value_form
    params[:method] = "any?" if params[:method].nil?
    if params[:option]
      case params[:option]
      when "id"
        # Render the id select field.
        @partial = "shared/id_select"
      when "conditions_array", "conditions_hash"
        # Render the conditions fields.
        @partial = "conditions"
      when "calculate"
        # Render the column name field.
        @partial = "calculate"
        @sub_method = true, @column_name_nil = true, @distinct = true if params[:method] == 'calculate'
        @column_name_nil = true, @distinct = true if params[:method] == 'count'
      end
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
      result = relation.send(params[:method])
    when "exists?"
      case params[:option]
      when "id"
        result = relation.send(params[:method], params[:id])
      when "conditions_array"
        result = relation.send(params[:method], build_joined_conditions('array', params[:conditions][:placeholder_style], params[:conditions][:values]).flatten)
      when "conditions_hash"
        result = relation.send(params[:method], *build_joined_conditions('hash', params[:conditions][:placeholder_style], params[:conditions][:values]).flatten)
      else
        result = relation.send(params[:method])
      end
    when "average", "count", "maximum", "minimum", "sum", "pluck"
      if params[:distinct].present?
        result = relation.send(params[:method], params[:column_name].presence, { :distinct => params[:distinct] == "true" })
      else
        result = relation.send(params[:method], params[:column_name].presence)
      end
    when "calculate"
      if params[:distinct].present?
        result = relation.send(params[:method], params[:sub_method].to_sym, params[:column_name].presence, { :distinct => params[:distinct] == "true" })
      else
        result = relation.send(params[:method], params[:sub_method].to_sym, params[:column_name].presence)
      end
    else
      raise "Unknown method '#{params[:method]}'"
    end

    # Make the result available for display
    @result = result

    respond_with(@result)
  end

  # Helper functions
private
  # Extract query methods (finder options) from params and apply them to the relation.
  def apply_query_methods(relation, params)
    # Add the unique option (boolean value).
    relation = relation.uniq(params[:uniq]) if params[:uniq].present?
    # Build and apply the where conditions.
    relation = build_and_apply_conditions(relation, :where, params[:where]) if params[:where].present?
    # Add the limit option (numeric value).
    relation = relation.limit(params[:limit]) if params[:limit].present?
    # Add the offset option (numeric value).
    relation = relation.offset(params[:offset]) if params[:offset].present?
    # Build and apply the having conditions.
    if params[:having].present?
      relation = build_and_apply_conditions(relation, :having, params[:having])
      # relation the database columns used in the having clause to the group clause or else an exception will occur.
      having_columns = params[:having][:values].select { |column, value| value.present? }.keys
      relation = relation.group(having_columns.join(',')) if having_columns.present?
    end
    relation
  end

  # Build and apply the conditions (in data) on relation using method.
  def build_and_apply_conditions(relation, method, data)
    # Extract the optonss
    apply_method = data[:apply_method]
    argument_type = data[:argument_type]
    placeholder_style = data[:placeholder_style]
    values = data[:values]
    if(apply_method == 'separated')
      # We want to apply the conditions separated (one where call per condition). Build an array containing all the separate conditions in the right format.
      conditions = build_separated_conditions(argument_type, placeholder_style, values)
    else
      # We want to apply the conditions joined (one where call for all conditions). Build an array containing one large condition in the right format.
      conditions = build_joined_conditions(argument_type, placeholder_style, values)
    end
    # Apply the formatted conditions on the relation using method.
    apply_conditions(relation, method, conditions)
  end

  # Apply formatted conditions (method arguments) on the relation using method.
  def apply_conditions(relation, method, conditions)
    conditions.each { |condition| puts "Applying " + condition.inspect if condition.present? } # Debug information
    conditions.each { |condition| relation = relation.send(method, *condition) if condition.present? }
    relation
  end

  # Build/format separated conditions. Returns an array with a (formatted) element for each condition.
  def build_separated_conditions(argument_type, placeholder_style, values)
    values.map { |column, value| build_condition(argument_type, placeholder_style, column, value) }
  end

  # Build/format joined conditions. Returns an array with one formatted element representing all the conditions.
  def build_joined_conditions(argument_type, placeholder_style, values)
    conditions = nil
    values.each do |column, value|
      # Format the next condition
      condition = build_condition(argument_type, placeholder_style, column, value)
      # And merge it with the already existing conditions.
      conditions = merge_conditions(conditions, condition) if condition.present?
    end
    # Wrap the single large condition in an array (with one element), because apply_conditions expects the conditions to be an array.
    [conditions]
  end

  # This methods builds a equality condition on column = value. It returns a list (array) of arguments for the where (or similar) call on the relation.
  # The argument type determines whether the arguments should be applied as a string (followed by a list with bind variables), an array (with a statement string and bind variables) or an hash.
  # The placeholder style determines whether we want to use question mark (?) placeholders, named placeholders (:id) or sprintf type placeholders (%s). This only has effect when argument type is string or array.
  def build_condition(argument_type, placeholder_style, column, value)
    return nil if value.blank? # Reject blank values (this means we do not want to filter on this column)
    case argument_type
    when "string"
      # We want to represent the condition as a string (with the bind values in a list). Rails applies the sanitization for us.
      case placeholder_style
      when "question_mark"
        # Use question mark placeholders. The bind variables are a list/array.
        ["#{column} = ?", value]
      when "named"
        # Use named placeholders. The bind variables are a hash.
        ["#{column} = :#{column}", {column.to_sym => value}]
      when "sprintf"
        # Use sprintf placeholders. The bind variables are a list/array.
        ["#{column} = '%s'", value] # XXX TODO we put quotes around %s ourselves, but it is doubtful if we should be responsible for this. However, at least this way things will not break for strings (but they might for other types).
      else
        raise "Placeholder style '#{placeholder_style}' not supported."
      end
    when "array"
      # We want to represent the condition as an array (with the bind values in an array). Rails applies the sanitization for us.
      # This is very similar to the string argument_type (actually, a string with bind values is mapped to an array in Rails), we only need to wrap the result in an array.
     [build_condition("string", placeholder_style, column, value)]
    when "hash"
      # We want to represent the conditions as a hash. Rails applies the sanitization for us.
      # Placeholder style is ignored for hash arguments (it has no meaning)
      [{ column => value }]
    else
      raise "Structure type '#{argument_type}' not supported (it is possible Rails supports this type, but we do not)."
    end
  end

  # This methods merges the already existing formatted conditions (list) with the new formatted condition (list).
  # For string and array conditions this means the statements are concatenated with the logical AND operator as glue and the bind variables are merged (array addition for question mark and sprintf placeholders, hash merge for named placeholders)
  # For hash conditions this is a simple hash merge (which Rails will map to conditions also joined by the logical AND operator)
  def merge_conditions(conditions, condition)
    return condition if conditions.blank?
    case condition.first
    when String
      # We want to represent the conditions as an AND concatenated string followed by the bind values in a list.
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
