require 'rails_helper'

describe Notifier do
  describe 'furl_requested' do
    let!(:users) { [ create(:furl_manager) ] }
    let(:furl_request_from) { "/somewhere" }
    let(:furl_request_to) { "/somewhere/else" }
    let(:furl_request_requester) { create(:furl_requester) }
    let(:furl_request_contact_email) { "furl_requester@example.com" }
    let(:furl_request_organisation_title) { "Ministry of beards" }
    let(:furl_request_reason) { "because furls" }
    let(:furl_request) {
      create :furl_request, from: furl_request_from,
                            to: furl_request_to,
                            requester: furl_request_requester,
                            contact_email: furl_request_contact_email,
                            organisation_title: furl_request_organisation_title,
                            reason: furl_request_reason
    }
    let(:mail) { Notifier.furl_requested(furl_request) }

    it "should send from <Friendly URL manager> noreply+furl-manager@digital.cabinet-office.gov.uk" do
      expect(mail.from).to eql "<Friendly URL manager> noreply+furl-manager@digital.cabinet-office.gov.uk"
    end

    it "should set a subject showing the from and applicable organisation" do
      expect(mail.subject).to eql "Furl request for '#{furl_request_from}' by #{furl_request_organisation_title}"
    end

    it "should include all relevant data in the body" do
      expect(mail).to have_body_content "From: #{furl_request_from}"
      expect(mail).to have_body_content "To: #{furl_request_to}"
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
end
