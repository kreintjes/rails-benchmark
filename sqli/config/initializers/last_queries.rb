ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
  attr_accessor :last_queries

  # This method has two functions:
  # 1. To log all the queries in the query log for displaying
  # 2. To check errors for harmless stuff.
  def log_with_last_queries(sql, name, binds=[], &block)
    @last_queries ||= []
    @last_queries << [sql, name] unless name == "SCHEMA"
    begin
      log_without_last_queries(sql, name, binds, &block)
    rescue ActiveRecord::StatementInvalid => e
      # The query resulted in an exception. We check if the exception was something harmless that could result into a false positive. If so, we simply return an empty array as if there were no objects found.
      if e.message.scan("PG::Error: ERROR:  invalid input syntax for type").present?
        # Error because of invalid input syntax for some type (for example timestamp).
        logger.debug 'Automatic handled error "PG::Error: ERROR:  invalid input syntax for type"'
        []
      elsif e.message.scan("PG::Error: ERROR:  syntax error at or near \"DISTINCT\"\nLINE 1: SELECT  DISTINCT DISTINCT").present?
        # Error because of double DISTINCT. This happens when we set a value for uniq and limit and eager_load is has_many or has_and_belongs_to_many (Rails bug?).
        logger.debug 'Automatic handled error "PG::Error: ERROR:  syntax error at or near "DISTINCT"\nLINE 1: SELECT  DISTINCT DISTINCT"'
        []
      else
        # Unknown error. Probably we found an SQL injection. Simply raise the exception again.
        raise e
      end
    end
  end
  alias_method_chain :log, :last_queries
end