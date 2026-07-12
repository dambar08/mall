require "vcr"
require "webmock/rspec"

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"

  config.hook_into :webmock

  config.configure_rspec_metadata!

  config.ignore_localhost = true

  config.allow_http_connections_when_no_cassette = false

  config.default_cassette_options = {
    record: :once,
    match_requests_on: %i[method uri]
  }

  config.filter_sensitive_data("<API_KEY>") do
    ENV["API_KEY"]
  end

  config.filter_sensitive_data("<SECRET>") do
    ENV["SECRET"]
  end
end