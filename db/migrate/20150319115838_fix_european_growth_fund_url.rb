class FixEuropeanGrowthFundUrl < Mongoid::Migration
  SOURCE = "/european-growth-funding"
  OLD_TARGET = "/england-2014-to-2020-european-structural-and-investment-funds-growth-programme"
  NEW_TARGET = "/european-structural-investment-funds"

  def self.up
    if furl = Redirect.where(from_path: SOURCE).first
      furl.to_path = NEW_TARGET
      furl.save!
      puts "Redirecting #{SOURCE} to #{NEW_TARGET}"
    end
  end

  def self.down
    if furl = Redirect.where(from_path: SOURCE).first
      furl.to_path = OLD_TARGET
      furl.save!
      puts "Redirecting #{SOURCE} to #{OLD_TARGET}"
    end
  end
end
