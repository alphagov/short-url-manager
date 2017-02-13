shared_examples_for "ShortUrlValidations" do |klass|
  describe "from_path" do
    it "is required" do
      expect(build(klass, from_path: '')).to_not be_valid
    end

    it "must be a relative path" do
      expect(build(klass, from_path: '/a-path')).to be_valid
      expect(build(klass, from_path: 'http://www.somewhere.com/a-path')).to_not be_valid
    end
  end

  describe "to_path" do
    it "is required" do
      expect(build(klass, to_path: '')).to_not be_valid
    end

    it "may be a relative path" do
      expect(build(klass, to_path: '/a-path')).to be_valid
    end

    it "may be a gov.uk campaign URL" do
      expect(build(klass, to_path: 'https://my.campaign.gov.uk')).to be_valid
      expect(build(klass, to_path: 'https://my.campaign.gov.uk/path')).to be_valid
    end

    it "must be either a relative path or a gov.uk campaign URL" do
      expect(build(klass, to_path: 'https://www.somewhere.com/a-path')).to_not be_valid
      expect(build(klass, to_path: 'https://.campaign.gov.uk')).to_not be_valid
      expect(build(klass, to_path: 'http://my.campaign.gov.uk')).to_not be_valid
      expect(build(klass, to_path: 'http://my.campaign.gov.uk/path')).to_not be_valid
      expect(build(klass, to_path: 'ftp://my.campaign.gov.uk')).to_not be_valid
    end
  end
end
