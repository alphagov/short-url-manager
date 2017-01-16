require 'rails_helper'

describe Notifier do
  shared_examples_for "indicating the deployed environment via the subject line" do
    it "includes an indicator of the deployed environment in the subject line" do
      allow(Rails.application.config).to receive(:instance_name).and_return('testing-123')
      expect(mail.subject).to match /^\[testing-123\] Short URL request/
    end

    it "does not include an indicator of the deployed environment in the subject line if it is blank (e.g. production)" do
      allow(Rails.application.config).to receive(:instance_name).and_return('')
      expect(mail.subject).to match /^Short URL request/
    end
  end

  describe 'short_url_requested' do
    let!(:users) { [ create(:short_url_manager) ] }
    let(:short_url_request_from_path) { "/somewhere" }
    let(:short_url_request_to_path) { "/somewhere/else" }
    let(:short_url_request_requester) { create(:short_url_requester) }
    let(:short_url_request_contact_email) { "short_url_requester@example.com" }
    let(:short_url_request_organisation_title) { "Ministry of beards" }
    let(:short_url_request_reason) { "because short_urls" }
    let(:short_url_request) {
      create :short_url_request, from_path: short_url_request_from_path,
                            to_path: short_url_request_to_path,
                            requester: short_url_request_requester,
                            contact_email: short_url_request_contact_email,
                            organisation_title: short_url_request_organisation_title,
                            reason: short_url_request_reason
    }
    let(:mail) { Notifier.short_url_requested(short_url_request) }

    it "should send from noreply+short-url-manager@digital.cabinet-office.gov.uk" do
      expect(mail.from).to be == ["noreply+short-url-manager@digital.cabinet-office.gov.uk"]
    end

    it "should set a subject showing the from and applicable organisation" do
      expect(mail.subject).to match /#{Regexp.escape("Short URL request for '#{short_url_request_from_path}' by #{short_url_request_organisation_title}")}$/
    end

    include_examples "indicating the deployed environment via the subject line"

    it "should include all relevant data in the body" do
      expect(mail).to have_body_content "From: #{short_url_request_from_path}"
      expect(mail).to have_body_content "To: #{short_url_request_to_path}"
      expect(mail).to have_body_content "Requester: #{short_url_request_requester.name}"
      expect(mail).to have_body_content "Contact email: #{short_url_request_contact_email}"
      expect(mail).to have_body_content "Organisation: #{short_url_request_organisation_title}"
      expect(mail).to have_body_content "Reason: #{short_url_request_reason}"
    end

    it "includes a link to the short url request" do
      expect(mail).to have_body_content "You can respond to this request here: #{Plek.current.find('short-url-manager') + short_url_request_path(short_url_request)}"
    end

    context "with several users with permissions to manage short_urls" do
      let!(:users) { 3.times.map { create :short_url_manager } }

      it "should send to all users with the request_short_urls permission" do
        expect(mail.to).to include users[0].email
        expect(mail.to).to include users[1].email
        expect(mail.to).to include users[2].email
      end
    end
  end

  describe 'short_url_request_accepted' do
    let!(:requester) { create :short_url_requester, name: "Mr Bigglesworth" }
    let(:short_url_request_contact_email) { "bigglesworth@example.com" }
    let(:redirect_from_path) { "/evilhq" }
    let(:redirect_to_path) { "/favourite-hangouts/evil-headquarters" }
    let(:short_url_request) { create :short_url_request, requester: requester,
                                                         contact_email: short_url_request_contact_email,
                                                         redirect: build(:redirect, from_path: redirect_from_path,
                                                                                    to_path: redirect_to_path) }
    let(:mail) { Notifier.short_url_request_accepted(short_url_request) }

    it "should send from noreply+short-url-manager@digital.cabinet-office.gov.uk" do
      expect(mail.from).to be == ["noreply+short-url-manager@digital.cabinet-office.gov.uk"]
    end

    it "should sent to the contact email address supplied with the initial request" do
      expect(mail.to).to be == ["bigglesworth@example.com"]
    end

    it "should set a subject" do
      expect(mail.subject).to match /Short URL request approved$/
    end

    include_examples "indicating the deployed environment via the subject line"

    it "should address the user by name, and give the from path and to path in the email body" do
      expect(mail).to have_body_content "Mr Bigglesworth"
      expect(mail).to have_body_content "/evilhq"
      expect(mail).to have_body_content "/favourite-hangouts/evil-headquarters"
    end
  end

  describe 'short_url_request_rejected' do
    let!(:requester) { create :short_url_requester, name: "Mr Bigglesworth" }
    let(:short_url_request_contact_email) { "bigglesworth@example.com" }
    let(:short_url_request_from_path) { "/evilhq" }
    let(:short_url_request_to_path) { "/favourite-hangouts/evil-headquarters" }
    let(:short_url_request_rejection_reason) { nil }
    let(:short_url_request) { create :short_url_request, requester: requester,
                                                         contact_email: short_url_request_contact_email,
                                                         from_path: short_url_request_from_path,
                                                         to_path: short_url_request_to_path,
                                                         rejection_reason: short_url_request_rejection_reason }
    let(:mail) { Notifier.short_url_request_rejected(short_url_request) }

    it "should send from noreply+short-url-manager@digital.cabinet-office.gov.uk" do
      expect(mail.from).to be == ["noreply+short-url-manager@digital.cabinet-office.gov.uk"]
    end

    it "should sent to the contact email address supplied with the initial request" do
      expect(mail.to).to be == ["bigglesworth@example.com"]
    end

    it "should set a subject" do
      expect(mail.subject).to match /Short URL request denied$/
    end

    include_examples "indicating the deployed environment via the subject line"

    it "should address the user by name, and give the from path and to path in the email body" do
      expect(mail).to have_body_content "Mr Bigglesworth"
      expect(mail).to have_body_content "/evilhq"
      expect(mail).to have_body_content "/favourite-hangouts/evil-headquarters"
    end

    context "when a reason is given" do
      let(:short_url_request_rejection_reason) { "The British government does not negotiate with terrorists" }

      it "should include the reason in the body content" do
        expect(mail).to have_body_content "The British government does not negotiate with terrorists"
      end
    end

    context "when no reason is given" do
      let(:short_url_request_rejection_reason) { nil }

      it "should state that no reason was given" do
        expect(mail).to have_body_content "No reason was given"
      end
    end
  end
end
