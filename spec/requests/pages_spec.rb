require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /index" do
    pending "add some examples (or delete) #{__FILE__}"
  end

  describe "GET /show" do
    it "return HTTP 200" do
      get root_path
      expect(response).to have_http_status(:ok)
    end
  end
end
