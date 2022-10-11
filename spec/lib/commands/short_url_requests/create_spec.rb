require "rails_helper"

describe Commands::ShortUrlRequests::Create do
  let(:user) { create(:short_url_manager_and_recipient) }
  subject(:command) { described_class.new(params, user) }

  let(:success) { double(:success, call: true) }
  let(:failure) { double(:failure, call: true) }
  let(:confirmation_required) { double(:confirmation_required, call: true) }
  let!(:organisation) { create(:organisation) }

  context "with valid data" do
    let(:params) do
      {
        from_path: "/a-friendly-url",
        to_path: "/somewhere/a-document",
        reason: "Because wombles",
        organisation_slug: organisation.slug,
      }
    end

    it "sends a notification email" do
      allow(Notifier).to receive(:short_url_requested).and_call_original

      command.call(
        success:,
        failure:,
        confirmation_required:,
      )

      expect(Notifier).to have_received(:short_url_requested)
    end

    it "calls the success callback" do
      command.call(
        success:,
        failure:,
        confirmation_required:,
      )

      expect(success).to have_received(:call).once.with(instance_of(ShortUrlRequest))
    end

    it "results in a new ShortUrlRequest" do
      command.call(
        success:,
        failure:,
        confirmation_required:,
      )

      expect(ShortUrlRequest.count).to eq(1)
    end
  end

  context "with invalid data" do
    let(:params) do
      {
        from_path: "/a-friendly-url",
        to_path: "",
        reason: "Because wombles",
        organisation_slug: nil,
      }
    end

    it "calls the failure callback" do
      command.call(
        success:,
        failure:,
        confirmation_required:,
      )

      expect(failure).to have_received(:call).once.with(instance_of(ShortUrlRequest))
    end
  end

  context "when a similar short url already exists" do
    let(:params) do
      {
        from_path: "/a-friendly-url",
        to_path: "/somewhere/a-document",
        reason: "Because wombles",
        organisation_slug: organisation.slug,
      }
    end

    before do
      create(:redirect, params.slice(:from_path))
    end

    it "calls the confirmation_required callback" do
      command.call(
        success:,
        failure:,
        confirmation_required:,
      )

      expect(confirmation_required).to have_received(:call).once.with(instance_of(ShortUrlRequest))
    end

    context "with invalid data" do
      let(:params) do
        {
          from_path: "/a-friendly-url",
          to_path: "",
          reason: "Because wombles",
          organisation_slug: nil,
        }
      end

      it "calls the failure callback" do
        command.call(
          success:,
          failure:,
          confirmation_required:,
        )

        expect(failure).to have_received(:call).once.with(instance_of(ShortUrlRequest))
      end
    end

    context "with confirmation" do
      let(:params) do
        {
          from_path: "/a-friendly-url",
          to_path: "/somewhere/a-document",
          reason: "Because wombles",
          organisation_slug: organisation.slug,
          confirmed: true,
        }
      end

      it "calls the success callback" do
        command.call(
          success:,
          failure:,
          confirmation_required:,
        )

        expect(success).to have_received(:call).once.with(instance_of(ShortUrlRequest))
      end
    end
  end

  context "with advanced options" do
    let(:params) do
      {
        from_path: "/a-friendly-url",
        to_path: "/somewhere/a-document",
        reason: "Because wombles",
        organisation_slug: organisation.slug,
        confirmed: true,
        route_type: "exact",
        segments_mode: "preserve",
        override_existing: false,
      }
    end

    it "creates a redirect with segment mode of 'preserve'" do
      command.call(
        success:,
        failure:,
        confirmation_required:,
      )

      expect(success).to have_received(:call).once.with(instance_of(ShortUrlRequest))
      request = ShortUrlRequest.find_by(from_path: "/a-friendly-url")

      expect(request.segments_mode).to eq("preserve")
    end
  end
end
