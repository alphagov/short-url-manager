class UpdatePipToolkitShortUrl < Mongoid::Migration
  SOURCE = "/dwp/pip-toolkit".freeze
  OLD_TARGET = "/government/publications/the-personal-independence-payment-toolkit-for-partners/the-personal-independence-payment-pip-toolkit-for-partners".freeze
  NEW_TARGET = "/government/publications/the-personal-independence-payment-toolkit-for-partners".freeze

  def self.up
    if request = ShortUrlRequest.where(from_path: SOURCE).first
      request.to_path = NEW_TARGET
      request.save!
      puts "Updating request from #{SOURCE} to #{NEW_TARGET}"
    end

    if redirect = Redirect.where(from_path: SOURCE).first
      redirect.to_path = NEW_TARGET
      redirect.save!
      puts "Redirecting #{SOURCE} to #{NEW_TARGET}"
    end
  end

  def self.down
    if request = ShortUrlRequest.where(from_path: SOURCE).first
      request.to_path = OLD_TARGET
      request.save!
      puts "Updating request from #{SOURCE} to #{OLD_TARGET}"
    end

    if redirect = Redirect.where(from_path: SOURCE).first
      redirect.to_path = OLD_TARGET
      redirect.save!
      puts "Redirecting #{SOURCE} to #{OLD_TARGET}"
    end
  end
end
