require 'safe_rescue'

ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
  include SafeRescue

  attr_accessor :last_queries

  # This method enables logging of all queries and Safe Rescue handling
  def log_with_last_queries_and_safe_rescue(sql, name, binds=[], &block)
    @last_queries ||= []
    @last_queries << [sql, name] unless name == "SCHEMA"
    exec_with_safe_rescue { log_without_last_queries_and_safe_rescue(sql, name, binds, &block) }
  end
  alias_method_chain :log, :last_queries_and_safe_rescue
end

ActiveRecord::Relation.class_eval do
  include SafeRescue
  # This method has as function to rescue all safe exceptions, meaning exceptions that do not indicate SQL injections, but could cause false positives.
  def load_with_safe_rescue
    exec_with_safe_rescue { load_without_safe_rescue }
  end
  alias_method_chain :load, :safe_rescue
end