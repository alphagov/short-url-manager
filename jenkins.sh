#!/bin/bash -x

set -e

# Clone govuk-content-schemas depedency for contract tests
rm -rf tmp/govuk-content-schemas
git clone git@github.com:alphagov/govuk-content-schemas.git tmp/govuk-content-schemas
export GOVUK_CONTENT_SCHEMAS_PATH=tmp/govuk-content-schemas

export RAILS_ENV=test
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment
bundle exec rake --trace
