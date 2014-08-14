require 'rails_helper'

describe Notifier do
  describe 'furl_requested' do
    let!(:users) { [ create(:furl_manager) ] }
    let(:furl_request_from_path) { "/somewhere" }
    let(:furl_request_to_path) { "/somewhere/else" }
    let(:furl_request_requester) { create(:furl_requester) }
    let(:furl_request_contact_email) { "furl_requester@example.com" }
    let(:furl_request_organisation_title) { "Ministry of beards" }
    let(:furl_request_reason) { "because furls" }
    let(:furl_request) {
      create :furl_request, from_path: furl_request_from_path,
                            to_path: furl_request_to_path,
                            requester: furl_request_requester,
                            contact_email: furl_request_contact_email,
                            organisation_title: furl_request_organisation_title,
                            reason: furl_request_reason
    }
    let(:mail) { Notifier.furl_requested(furl_request) }

    it "should send from noreply+furl-manager@digital.cabinet-office.gov.uk" do
      expect(mail.from).to be == ["noreply+furl-manager@digital.cabinet-office.gov.uk"]
    end

    it "should set a subject showing the from and applicable organisation" do
      expect(mail.subject).to eql "Friendly URL request for '#{furl_request_from_path}' by #{furl_request_organisation_title}"
    end

    it "should include all relevant data in the body" do
      expect(mail).to have_body_content "From: #{furl_request_from_path}"
      expect(mail).to have_body_content "To: #{furl_request_to_path}"
      expect(mail).to have_body_content "Requester: #{furl_request_requester.name}"
      expect(mail).to have_body_content "Contact email: #{furl_request_contact_email}"
      expect(mail).to have_body_content "Organisation: #{furl_request_organisation_title}"
      expect(mail).to have_body_content "Reason: #{furl_request_reason}"
    end

    context "with several users with permissions to manage furls" do
      let!(:users) { 3.times.map { create :furl_manager } }

      it "should send to all users with the request_furls permission" do
        expect(mail.to).to include users[0].email
        expect(mail.to).to include users[1].email
        expect(mail.to).to include users[2].email
      end
    end
  end

  describe 'furl_request_accepted' do
    let!(:requester) { create :furl_requester, name: "Mr Bigglesworth" }
    let(:furl_request_contact_email) { "bigglesworth@example.com" }
    let(:redirect_from_path) { "/evilhq" }
    let(:redirect_to_path) { "/favourite-hangouts/evil-headquarters" }
    let(:furl_request) { create :furl_request, requester: requester,
                                               contact_email: furl_request_contact_email,
                                               redirect: build(:redirect, from_path: redirect_from_path,
                                                                          to_path: redirect_to_path) }
    let(:mail) { Notifier.furl_request_accepted(furl_request) }

    it "should send from noreply+furl-manager@digital.cabinet-office.gov.uk" do
      expect(mail.from).to be == ["noreply+furl-manager@digital.cabinet-office.gov.uk"]
    end

    it "should sent to the contact email address supplied with the initial request" do
      expect(mail.to).to be == ["bigglesworth@example.com"]
    end

    it "should set a subject" do
      expect(mail.subject).to eql "Friendly URL request approved"
    end

    it "should address the user by name, and give the from path and to path in the email body" do
      expect(mail).to have_body_content "Mr Bigglesworth"
      expect(mail).to have_body_content "/evilhq"
      expect(mail).to have_body_content "/favourite-hangouts/evil-headquarters"
    end
  end

  describe 'furl_request_rejected' do
    let!(:requester) { create :furl_requester, name: "Mr Bigglesworth" }
    let(:furl_request_contact_email) { "bigglesworth@example.com" }
    let(:furl_request_from_path) { "/evilhq" }
    let(:furl_request_to_path) { "/favourite-hangouts/evil-headquarters" }
    let(:furl_request_rejection_reason) { nil }
    let(:furl_request) { create :furl_request, requester: requester,
                                               contact_email: furl_request_contact_email,
                                               from_path: furl_request_from_path,
                                               to_path: furl_request_to_path,
                                               rejection_reason: furl_request_rejection_reason }
    let(:mail) { Notifier.furl_request_rejected(furl_request) }

    it "should send from noreply+furl-manager@digital.cabinet-office.gov.uk" do
      expect(mail.from).to be == ["noreply+furl-manager@digital.cabinet-office.gov.uk"]
    end

    it "should sent to the contact email address supplied with the initial request" do
      expect(mail.to).to be == ["bigglesworth@example.com"]
    end

    it "should set a subject" do
      expect(mail.subject).to eql "Friendly URL request denied"
    end

    it "should address the user by name, and give the from path and to path in the email body" do
      expect(mail).to have_body_content "Mr Bigglesworth"
      expect(mail).to have_body_content "/evilhq"
      expect(mail).to have_body_content "/favourite-hangouts/evil-headquarters"
    end

    context "when a reason is given" do
      let(:furl_request_rejection_reason) { "The British government does not negotiate with terrorists" }

      it "should include the reason in the body content" do
        expect(mail).to have_body_content "The British government does not negotiate with terrorists"
      end
    end

    context "when no reason is given" do
      let(:furl_request_rejection_reason) { nil }

      it "should state that no reason was given" do
        expect(mail).to have_body_content "No reason was given"
      end
    end
  end
end
