# Short URL manager

Publishing tool to request, approve and create Short URLs on GOV.UK.

## Technical documentation

Short URLs are a short and easy to type URL that redirects to a piece of content at a much longer URL.

They are often used on posters, in leaflets or over the phone, so they are easy to use. For example:

```
/dwp/cps5
```
to
```
/government/publications/your-state-pension-estimate-explained-cps5
```

## Dependencies
* MongoDB - main data store
* Redis - for distributed locking using
  [mlanett/redis-lock](https://github.com/mlanett/redis-lock)
* [alphagov/gds-sso](http://github.com/alphagov/gds-sso): Provides authentication OmniAuth adapter to allow apps to sign in via GOV.UK auth
* [alphagov/publishing-api](http://github.com/alphagov/publishing-api): the central store of published content on GOV.UK. Once a redirect has been accepted, redirects are registered to this API.

## Running the application

```
$ ./startup.sh
```

If you are using the GDS development virtual machine then the application will be available on the host at [http://short-url-manager.dev.gov.uk/](http://short-url-manager.dev.gov.uk/)

## Running the test suite

```
$ bundle exec rake
```

## Content Schema Validations

You will need a copy of [govuk-content-schemas](https://github.com/alphagov/govuk-content-schemas) on your file system. By default these should be in a sibling directory to your project. Alternatively, you can specify their location with the `GOVUK_CONTENT_SCHEMAS_PATH` environment variable.

## Permissions

Users must be given Signon permissions to access and use the features
of this tool. The available permissions are:
- `request_short_urls`: Can complete a form to request a new Short URL, which must be approved before being made
- `manage_short_urls`: Can approve requests for Short URLs, and create the redirects on GOV.UK
- `receive_notifications`: Will receive email notifications when a new short URL is requested.
- `advanced_options`: Can create and approve requests using advanced options (prefix type redirects, and non-default segments mode values).

## Licence

[MIT License](LICENCE)
