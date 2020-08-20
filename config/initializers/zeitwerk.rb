Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "publishing_api" => "PublishingAPI",
  )
end
