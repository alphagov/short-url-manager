# Short URL Manager

Publishing tool to request, approve and create Short URLs on GOV.UK.

Short URLs are a short and easy to type URL that redirects to a piece of content at a much longer URL.

They are often used on posters, in leaflets or over the phone, so they are easy to use. For example:

```
/dwp/cps5
```
to
```
/government/publications/your-state-pension-estimate-explained-cps5
```

Currently this tool allows departmental users to request redirects within the scope of their department, eg, under `dwp` above. Future versions may add workflow for requesting/managing top level Short URLs, eg, `/ebola` to `/government/topical-events/ebola-government-response`.

## Content Schema Validations

You will need a copy of govuk-content-schemas on your file system. By default these should be in a sibling directory to your project. Alternatively, you can specify their location with the GOVUK_CONTENT_SCHEMAS_PATH environment variable.

## Permissions

Users must be given sign on permissions to access and use the features of this tool. There are two kinds of permission:
- `request_short_urls`: Can complete a form to request a new Short URL, which must be approved before being made
- `manage_short_urls`: Can approve requests for Short URLs, and create the redirects on GOV.UK

## Dependencies
* [alphagov/gds-sso](http://github.com/alphagov/gds-sso): Provides authentication OmniAuth adapter to allow apps to sign in via GOV.UK auth
* [alphagov/content-store](http://github.com/alphagov/content-store): an alias of `publishing-api`, the central storage of published content on GOV.UK, once a redirect has been accepted, redirects are registered to this API.

## Running the application

```
$ ./startup.sh
```

If you are using the GDS development virtual machine then the application will be available on the host at [http://short-url-manager.dev.gov.uk/](http://short-url-manager.dev.gov.uk/)

## Running the test suite

```
$ bundle exec rake
```
