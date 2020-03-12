require "rspec/expectations"

RSpec::Matchers.define :have_body_content do |expected_text|
  # Use this matcher to test whether an email has body text in both the HTML and text mail parts.

  match do |sent_mail|
    text_part = get_mail_body(sent_mail)
    text_part.include?(expected_text)
  end

  match_when_negated do |sent_mail|
    text_part = get_mail_body(sent_mail)
    !text_part.include?(expected_text)
  end

  failure_message do |sent_mail|
    text_part = get_mail_body(sent_mail)

    message = "Expected the email to include \"#{expected_text}\".\n"
    if !text_part.include?(expected_text)
      message << "The text part did not include \"#{expected_text}\". Text content: \n"
      message << "-------------------------------------------------------------\n"
      message << "#{text_part}\n"
      message << "-------------------------------------------------------------\n\n"
    end
    message
  end

  failure_message_when_negated do |sent_mail|
    text_part = get_mail_body(sent_mail)

    message = "Expected the email not to include \"#{expected_text}\".\n"
    if text_part.include?(expected_text)
      message << "The text part included \"#{expected_text}\". Text content: \n"
      message << "-------------------------------------------------------------\n"
      message << "#{text_part}\n"
      message << "-------------------------------------------------------------\n\n"
    end
    message
  end

  def get_mail_body(sent_mail)
    compact_content sent_mail.body.decoded
  end

  def compact_content(raw_content)
    raw_content.gsub(/[\r\n]/, " ").gsub(/\s+/, " ").strip
  end
end
