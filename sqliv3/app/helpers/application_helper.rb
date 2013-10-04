module ApplicationHelper
  def encode_method(method)
    # In URLs we replace ? in the method with a -, so the scanners will not mess with it (because they think it is part of the GET query string).
    method.gsub('?', '-')
  end
end
