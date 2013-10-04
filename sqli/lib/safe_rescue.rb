module SafeRescue
  def exec_with_safe_rescue
    begin
      yield
    rescue => e
      # Rescue everything and then check if the exception e should be safe rescued or not
      if (error = safe_rescue_error(e))
        # This exception should be safely rescued to prevent false positives for the dynamic scanners
        # Log the exception
        logger.debug " Automatic handled " + e.class.to_s + ": " + e.message + " to prevent false positive"
        # Return empty array as if nothing was found
        return []
      else
        # This exception should not be safe rescued (possible SQL injection!). Simply raise the exception again to display an error.
        raise e
      end
    end
  end

  def safe_rescue_error(e)
    errors = [
      { type: ActiveRecord::RecordNotUnique, messages: [] },
      { type: ActiveRecord::StatementInvalid, messages: ["PG::InvalidTextRepresentation: ERROR:  invalid input syntax for type"] },
      { type: ActiveRecord::StatementInvalid, messages: ["PG::InvalidDatetimeFormat: ERROR:  invalid input syntax for type"] },
      { type: ActiveRecord::StatementInvalid, messages: ["PG::DatetimeFieldOverflow: ERROR:  date/time field value out of range"] },
      { type: ActiveRecord::StatementInvalid, messages: ["PG::SyntaxError: ERROR:  syntax error at or near \"DISTINCT\"", "DISTINCT DISTINCT"] },
      { type: ActiveRecord::ConfigurationError, messages: ["Association named", "was not found"] },
    ]
    errors.each do |error|
      if e.is_a?(error[:type])
        match = true
        error[:messages].each do |message|
          unless e.message.scan(message).present?
            match = false
            break
          end
        end
        return true if match
      end
    end
    false
  end
end