module FormHelper
  def render_errors_for(model, leading_message: nil)
    if model.errors.any?
      render partial: "shared/form_errors", locals: { error_messages: model.errors.full_messages,
                                                      leading_message: leading_message || default_leading_error_message_for(model) }
    end
  end

private

  def default_leading_error_message_for(model)
    "The #{model.class.name.underscore.humanize(capitalize: false)} could not be saved for the following reasons:"
  end
end
