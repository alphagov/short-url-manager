class UpdateEuropeanGrowthFundShortUrl < Mongoid::Migration
  SOURCE = "/european-growth-funding".freeze
  OLD_TARGET = "/european-structural-investment-funds".freeze
  NEW_TARGET = "/england-2014-to-2020-european-structural-and-investment-funds".freeze

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
