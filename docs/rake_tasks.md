# Rake tasks

## Create and apply a redirect

This Rake task allows you to create and immediately apply a redirect without going through the normal approval workflow.

It is intended for operational use on support tasks, e.g. if having to bulk import a number of redirects, or patch in a redirect where there is no workflow to do so in the original publishing app.

### Usage

Run the task with the following arguments:

```bash
bundle exec rake redirects:create_and_apply[contact_email,from_path,to_path,reason,override_existing,route_type,segments_mode,organisation_slug,organisation_title]
```

Example

```bash
bundle exec rake redirects:create_and_apply[a@gov.uk,/from-path,/to-path,"Manual redirect needed as not supported in publishing app",true,exact,ignore,government-digital-service,"Government Digital Service"]
```

### Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| contact_email | Yes | Email address of the person creating the redirect |
| from_path | Yes | The base path to redirect from (must start with /) |
| to_path | Yes | The destination path (must start with /) |
| reason | Yes | Explanation for why the redirect is needed |
| override_existing | Yes | true or false – whether to override an existing redirect |
| route_type | No | "exact" (default) or "prefix" |
| segments_mode | No | "ignore" (default) or "preserve" |
| organisation_slug | No | Defaults to "government-digital-service" |
| organisation_title | No | Defaults to "Government Digital Service" |
