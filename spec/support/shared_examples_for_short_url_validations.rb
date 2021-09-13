shared_examples_for "ShortUrlValidations" do |klass|
  describe "from_path" do
    it "is required" do
      expect(build(klass, from_path: "")).to_not be_valid
    end

    it "must be a relative path" do
      expect(build(klass, from_path: "/a-path")).to be_valid
      expect(build(klass, from_path: "http://www.somewhere.com/a-path")).to_not be_valid
    end
  end

  describe "to_path" do
    it "is required" do
      expect(build(klass, to_path: "")).to_not be_valid
    end

    it "may be a relative path" do
      expect(build(klass, to_path: "/a-path")).to be_valid
    end

    it "may be a gov.uk subdomain URL" do
      expect(build(klass, to_path: "https://my.service.gov.uk/path")).to be_valid
    end

    it "may not be a non HTTPS URL" do
      expect(build(klass, to_path: "http://my.service.gov.uk/path")).to_not be_valid
      expect(build(klass, to_path: "ftp://my.service.gov.uk")).to_not be_valid
    end

    it "may not be a www.gov.uk subdomain URL" do
      expect(build(klass, to_path: "https://www.gov.uk/path")).to_not be_valid
    end

    it "may be an nhs.uk subdomain URL" do
      expect(build(klass, to_path: "https://www.nhs.uk/path")).to be_valid
    end

    it "may be a judiciary.uk subdomain URL" do
      expect(build(klass, to_path: "https://www.judiciary.uk/path")).to be_valid
    end

    it "may be a ukri.org subdomain URL" do
      expect(build(klass, to_path: "https://www.ukri.org/path")).to be_valid
    end
  end
end
