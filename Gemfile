source "http://rubygems.org"
ruby File.read(".ruby-version").chomp

gem "aws-sdk-s3", "~> 1"
gem "mysql2"
gem "puma"
gem "rake", "~> 13.0"
gem "require_all"
gem "sensible_logging", "~> 0.4.1"
gem "sentry-raven"
gem "sequel", "~> 5.35"
gem "sinatra"
gem "sinatra-contrib"

group :test do
  gem "rack-test"
  gem "rspec"
  gem "rubocop-govuk"
  gem "simplecov", require: false
  gem "timecop"
  gem "webmock"
end
