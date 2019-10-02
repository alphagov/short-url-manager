require "rspec/expectations"

RSpec::Matchers.define :have_body_content do |expected_text|
  # Use this matcher to test whether an email has body text in both the HTML and text mail parts.

  match do |sent_mail|
    html_part, text_part = get_mail_body_parts(sent_mail)

    html_part.include?(expected_text) && text_part.include?(expected_text)
  end

  match_when_negated do |sent_mail|
    html_part, text_part = get_mail_body_parts(sent_mail)

    !html_part.include?(expected_text) && !text_part.include?(expected_text)
  end

  failure_message do |sent_mail|
    html_part, text_part = get_mail_body_parts(sent_mail)

    message = "Expected the email to include \"#{expected_text}\".\n"
    if !html_part.include?(expected_text)
      message << "The HTML part did not include \"#{expected_text}\". HTML content: \n"
      message << "-------------------------------------------------------------\n"
      message << "#{html_part}\n"
      message << "-------------------------------------------------------------\n\n"
    end
    if !text_part.include?(expected_text)
      message << "The text part did not include \"#{expected_text}\". Text content: \n"
      message << "-------------------------------------------------------------\n"
      message << "#{text_part}\n"
      message << "-------------------------------------------------------------\n\n"
    end
    message
  end

  failure_message_when_negated do |sent_mail|
    html_part, text_part = get_mail_body_parts(sent_mail)

    message = "Expected the email not to include \"#{expected_text}\".\n"
    if html_part.include?(expected_text)
      message << "The HTML part included \"#{expected_text}\". HTML content: \n"
      message << "-------------------------------------------------------------\n"
      message << "#{html_part}\n"
      message << "-------------------------------------------------------------\n\n"
    end
    if text_part.include?(expected_text)
      message << "The text part included \"#{expected_text}\". Text content: \n"
      message << "-------------------------------------------------------------\n"
      message << "#{text_part}\n"
      message << "-------------------------------------------------------------\n\n"
    end
    message
  end

  def get_mail_body_parts(sent_mail)
    html_part = compact_content Nokogiri::HTML.parse(sent_mail.html_part.decoded).content
    text_part = compact_content sent_mail.text_part.decoded
    [html_part, text_part]
  end

  def compact_content(raw_content)
    raw_content.gsub(/[\r\n]/, " ").gsub(/\s+/, " ").strip
  end
end
