class RemovePartLeaveProfitTaxCreditsFromDatabase < Mongoid::Migration
  def self.up
    path = "/part-year-profit-tax-credits"

    if short_url_request = ShortUrlRequest.where(from_path: path).first
      short_url_request.destroy
    end

    if redirect = Redirect.where(from_path: path).first
      redirect.destroy
    end
  end

  def self.down
    # Intentionally blank. The removed redirect can be recreated in the web interface if required.
  end
end
