require "csv"
require "gds_api/publishing_api"

REDIRECTED_SPECIAL_ROUTES = [
  {
    content_id: "be88ff3e-deb3-4a6e-b6ac-d6d12b50ac3d",
    current_base_path: "/feedback",
    destination_path: "/contact",
  },
  {
    content_id: "16a89a3b-bd41-4bce-adaf-7505b844632f",
    current_base_path: "/feedback/contact",
    destination_path: "/contact/govuk",
  },
  {
    content_id: "a6d9bafd-f69b-4d2f-a002-c7547473e152",
    current_base_path: "/feedback/foi",
    destination_path: "/contact/foi",
  },
  {
    content_id: "d9f4ef65-4efb-4865-a562-c41d9794b796",
    current_base_path: "/contact/dvla",
    destination_path: "/contact-the-dvla",
  },
  {
    content_id: "80ea2f60-c900-4c73-a129-d5418fc7d12d",
    current_base_path: "/contact/passport-advice-line",
    destination_path: "/passport-advice-line",
  },
  {
    content_id: "4dee002d-6d26-47ff-b192-7e0392805f9f",
    current_base_path: "/contact/student-finance-england",
    destination_path: "/contact-student-finance-england",
  },
  {
    content_id: "b7f6e48e-9d2c-4789-a64f-455921dca0d0",
    current_base_path: "/contact/jobcentre-plus",
    destination_path: "/contact-jobcentre-plus",
  },
].freeze

namespace :redirects do
  desc "Create redirects for Feedback routes"
  task tmp_create_feedback_redirects: :environment do |_, _args|
    REDIRECTED_SPECIAL_ROUTES.each do |redirect_info|
      request = ShortUrlRequest.new(
        from_path: redirect_info[:current_base_path],
        to_path: redirect_info[:destination_path],
        reason: "Originally created in Feedback app task, moving to Short URL Manager",
        override_existing: true,
        contact_email: "govuk-patterns-and-pages@digital.cabinet-office.gov.uk",
        organisation_slug: "government-digital-service",
        organisation_title: "Government Digital Service",
      )

      if request.valid?
        logger.info("Registering redirect: '#{request.from_path}' -> '#{request.to_path}'")
        request.save!
        Commands::ShortUrlRequests::Accept.new(request).call
      else
        logger.info("Failed to register redirect: '#{request.from_path}' -> '#{request.to_path}'")
      end
    end
  end
end
