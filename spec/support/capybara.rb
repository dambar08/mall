require "capybara/rspec"

RSpec.configure do |config|
  config.before(type: :system) do |example|
    if example.metadata[:js]
      driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
    else
      driven_by :rack_test
    end
  end
end
