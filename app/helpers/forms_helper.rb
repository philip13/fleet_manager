module FormsHelper
  def form_field_error_class(object, field)
    output_html = ""
    object.errors.messages_for(field).each do |message|
      output_html += "<div style=\"color: red;\">#{message}</div>"
    end
    output_html.html_safe
  end
end
