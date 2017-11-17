class CreateRedirectsForDesignPrinciples < Mongoid::Migration
  def self.up
    # This URL has already been manually entered in short-url-manager
    # "/design-principles/performanceframework" => "/government/publications/gds-performance-framework"

    # These redirects taken from the current state of router and the routes
    # that design-principles still serves directly
    design_principles_redirects = {
      # existing router redirects
      '/design-principles'                                             => '/guidance/government-design-principles',
      '/design-principles/detailedguides'                              => '/guidance/content-design/content-types',
      '/design-principles/insidegovernment'                            => '/guidance/content-design/writing-for-gov-uk',
      '/design-principles/mainstream'                                  => '/topic/government-digital-guidance/content-publishing',
      '/design-principles/seo'                                         => '/guidance/content-design/writing-for-gov-uk',
      '/design-principles/style-guide'                                 => '/topic/government-digital-guidance/content-publishing',
      '/design-principles/style-guide/a-z'                             => '/guidance/style-guide/a-to-z-of-gov-uk-style',
      '/design-principles/style-guide/answers'                         => '/guidance/content-design/content-types',
      '/design-principles/style-guide/benefits-and-schemes'            => '/guidance/content-design/content-types',
      '/design-principles/style-guide/case-studies'                    => '/guidance/content-design/content-types',
      '/design-principles/style-guide/consultations'                   => '/guidance/content-design/content-types',
      '/design-principles/style-guide/corporate-information'           => '/guidance/content-design/content-types',
      '/design-principles/style-guide/detailed-guides'                 => '/guidance/content-design/content-types',
      '/design-principles/style-guide/document-collections'            => '/guidance/content-design/content-types',
      '/design-principles/style-guide/government-responses'            => '/guidance/content-design/content-types',
      '/design-principles/style-guide/groups'                          => '/guidance/content-design/content-types',
      '/design-principles/style-guide/guides'                          => '/guidance/content-design/content-types',
      '/design-principles/style-guide/images'                          => '/guidance/content-design/image-copyright-standards-for-gov-uk',
      '/design-principles/style-guide/news-stories-and-press-releases' => '/guidance/content-design/content-types',
      '/design-principles/style-guide/organisation-homepage'           => '/guidance/content-design/content-types',
      '/design-principles/style-guide/people-and-roles'                => '/guidance/content-design/content-types',
      '/design-principles/style-guide/policy-advisory-groups'          => '/guidance/content-design/content-types',
      '/design-principles/style-guide/policy-pages'                    => '/guidance/content-design/content-types',
      '/design-principles/style-guide/publications'                    => '/guidance/content-design/content-types',
      '/design-principles/style-guide/speeches'                        => '/guidance/content-design/content-types',
      '/design-principles/style-guide/statements-to-parliament'        => '/guidance/content-design/content-types',
      '/design-principles/style-guide/style-points'                    => '/guidance/style-guide/a-to-z-of-gov-uk-style',
      '/design-principles/style-guide/whats-new'                       => '/guidance/style-guide/updates',
      '/design-principles/style-guide/writing-for-govuk'               => '/guidance/content-design/writing-for-gov-uk',
      '/design-principles/style-guide/writing-for-the-web'             => '/guidance/content-design/writing-for-gov-uk',
      '/design-principles/whatsnew'                                    => '/guidance/style-guide/updates',
      '/designprinciples'                                              => '/guidance/government-design-principles',
      '/designprinciples/styleguide'                                   => '/topic/government-digital-guidance/content-publishing',
      # routes still served by design-principles
      '/design-principles/accessiblepdfs'                              => '/guidance/how-to-publish-on-gov-uk/accessible-pdfs',
      # This URL has already been manually entered in short-url-manager
      # '/design-principles/performanceframework'                        => '/government/publications/gds-performance-framework'
      # This URL will be turned into a gone to avoid polluting the formats (the updates page is not available as atom) (see below)
      # '/design-principles/style-guide.atom'                            => '/guidance/style-guide/updates'
    }

    murray = User.find_by(email: 'murray.steele@digital.cabinet-office.gov.uk')
    redirect_args = {
      override_existing: true,
      reason: 'Retiring design principles and making sure all redirects are consistent.  Note: this request is being created in a automated migration and will be automatically accepted.',
      organisation_slug: 'government-digital-service',
      confirmed: true
    }
    problems = {}
    say_with_time('Creating and accepting short_url_requests for design-principles urls') do
      design_principles_redirects.each do |from, to|
        Commands::ShortUrlRequests::Create.new(
          redirect_args.merge(from_path: from, to_path: to),
          murray
        ).call(
          success: -> (url_request) {
            Commands::ShortUrlRequests::Accept.new(
              url_request
            ).call(
              failure: -> (url_request) {
                problems[from] = 'Could not accept short_url_request'
              }
            )
          },
          confirmation_required: -> (url_request) {
            problems[from] = "Even though we said it didn't matter this url still requires confirmation because there are others like it."
          },
          failure: -> (url_request) {
            problems[from] = "Could not create short_url_request because: #{url_request.errors.full_messages}"
          }
        )
      end
    end

    say_with_time('Issuing a GONE redirect for /design-principles/style-guide.atom which has no appropriate redirect') do
      publishing_api.unpublish(
        # this content_id extracted from the design-principles special routes publishing rake task
        '7672ae7d-6efb-4816-bd74-c49a6cb43f04',
        {
          type: 'gone',
          explanation: 'The design-principles application is being retired and there is no alternative for this content published in the ATOM format.',
          alternative_path: '/guidance/style-guide/updates'
        }
      )
    end

    if problems.empty?
      say "Success!  All design-principles urls created as short_url_requests and accepted as redirects."
    else
      say "Warning!  The following redirects could not be completed\n\n#{problems.map { |route, problem| " * #{route} -> #{problem}" }.join("\n")}"
    end
  end

  def self.down
    # this migration is data only and can't really be un-done as there's no
    # concept in short-url-manager of deleting a redirect
  end

  def self.publishing_api
    @publishing_api ||= GdsApi::PublishingApiV2.new(
      Plek.current.find('publishing-api'),
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
    )
  end
end
