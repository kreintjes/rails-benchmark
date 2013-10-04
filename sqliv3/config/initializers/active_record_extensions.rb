ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
  attr_accessor :last_queries

  # This method has as function to log all queries
  def log_with_last_queries(sql, name, binds=[], &block)
    @last_queries ||= []
    @last_queries << [sql, name] unless name == "SCHEMA"
    begin
      log_without_last_queries(sql, name, binds, &block)
    rescue ActiveRecord::RecordNotUnique => e
      # The query resulted in a ActiveRecord::RecordNotUnique exception (id is already in use). This happens mainly with first_or_create when setting a value for where[id].
      logger.debug 'Automatic handled ActiveRecord::RecordNotUnique error to prevent false positive'
      []
    rescue ActiveRecord::StatementInvalid => e
      # The query resulted in an exception. We check if the exception was something harmless that could result into a false positive. If so, we simply return an empty array as if there were no objects found.
      if e.message.scan("PG::Error: ERROR:  invalid input syntax for type")
        # Error because of invalid input syntax for some type (for example timestamp).
        logger.debug 'Automatic handled ActiveRecord::StatementInvalid error "PG::Error: ERROR:  invalid input syntax for type" to prevent false positive'
        []
      elsif e.message.scan("PG::Error: ERROR:  date/time field value out of range")
        # Error because of out of range value for a date/time field.
        logger.debug 'Automatic handled ActiveRecord::StatementInvalid error PG::Error: ERROR:  date/time field value out of range" to prevent false positive'
        []
      elsif e.message.scan("PG::Error: ERROR:  syntax error at or near \"DISTINCT\"") && e.message.scan("DISTINCT DISTINCT")
        # Error because of double DISTINCT. This happens when we set a value for uniq and limit and eager_load is has_many or has_and_belongs_to_many (Rails bug?).
        logger.debug 'Automatic handled ActiveRecord::StatementInvalid error "PG::Error: ERROR:  syntax error at or near "DISTINCT" DISTINCT DISTINCT" to prevent false positive'
        []
      else
        # Unknown error. Probably we found an SQL injection. Simply raise the exception again.
        raise e
      end
    end
  end
  alias_method_chain :log, :last_queries
end

ActiveRecord::Relation.class_eval do
  # This method has as function to rescue all safe exceptions, meaning exceptions that do not indicate SQL injections, but could cause false positives.
  def exec_queries_with_safe_rescue
    begin
      exec_queries_without_safe_rescue
    rescue ActiveRecord::ConfigurationError => e
      # The query resulted in a ActiveRecord::ConfigurationError exception
      # Does not work
      if e.message.scan("Association named") && e.message.scan("was not found; perhaps you misspelled it?")
        # Association not found message. This happens because Rails prechecks the values set for associations (include, eager_load, join and preload values) before using it in the query.
        logger.debug 'Automatic handled ActiveRecord::ConfigurationError error "Association named ... was not found; perhaps you misspelled it?" to prevent false positive'
        []
      else
        # Unknown error. Probably we found an SQL injection. Simply raise the exception again.
        raise e
      end
    end
  end
  alias_method_chain :exec_queries, :safe_rescue
end