RSpec.configure do |config|
  # Controller specs
  config.include Devise::Test::ControllerHelpers, type: :controller

  # View specs
  config.include Devise::Test::ControllerHelpers, type: :view

  # Request specs
  config.include Devise::Test::IntegrationHelpers, type: :request

  # Feature/System specs
  config.include Warden::Test::Helpers, type: :system
  config.include Warden::Test::Helpers, type: :feature

  config.after(type: :system) do
    Warden.test_reset!
  end

  config.after(type: :feature) do
    Warden.test_reset!
  end
end