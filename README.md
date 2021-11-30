# Short URL manager

Publishing tool to request, approve and create Short URLs on GOV.UK. Short URLs are a short and easy-to-type URL that redirects to a piece of content at a much longer URL.

They are often used on posters, in leaflets or over the phone, so they are easy to use. For example:

```
/dwp/cps5
```
to
```
/government/publications/your-state-pension-estimate-explained-cps5
```

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions][].

You can use the [GOV.UK Docker environment][] to run the application and its tests with all the necessary dependencies.  Follow [the usage instructions][] to get started.

**Use GOV.UK Docker to run any commands that follow.**

[our Rails app conventions]: https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html
[GOV.UK Docker environment]: https://github.com/alphagov/govuk-docker
[the usage instructions]: https://github.com/alphagov/govuk-docker#usage

### Testing

The default `rake` task runs all the tests:

```sh
bundle exec rake
```

### Permissions

Users must be given Signon permissions to access and use the features
of this tool. The available permissions are:
- `request_short_urls`: Can complete a form to request a new Short URL, which must be approved before being made
- `manage_short_urls`: Can approve requests for Short URLs, and create the redirects on GOV.UK
- `receive_notifications`: Will receive email notifications when a new short URL is requested.
- `advanced_options`: Can create and approve requests using advanced options (prefix type redirects, and non-default segments mode values).

## Licence

[MIT License](LICENCE)
