desc "Run govuk-lint with similar params to CI"
task "lint" do
  sh "govuk-lint-ruby --format clang Gemfile app config lib spec"
end
