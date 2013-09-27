class BaseTestController < ApplicationController
  include ERB::Util
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::SanitizeHelper

  def sanitizers_form
  end

  def sanitizers_perform
    case params[:method]
    when 'html_escape', 'escape_once', 'strip_tags'
      @result = self.send(params[:method], params[:input])
    when 'sanitize'
      case params[:option]
      when 'none'
        options = { :tags => [], :attributes => [] }
      when 'no_tags'
        options = { :tags => [] }
      when 'no_attributes'
        options = { :attributes => [] }
      when 'custom'
        options = { :tags => %w(table tr td b i u strong em p div span ul li), :attributes => %w(id class title) }
      when 'default'
        options = {}
      end
      @result = self.send(params[:method], params[:input], options)
    when 'automatic'
      @result = params[:input]
    else
      @result = params[:input].html_safe # So we will see if we forget to implement a method
    end
  end
end
