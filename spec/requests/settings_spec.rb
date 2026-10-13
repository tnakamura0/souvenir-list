require "rails_helper"

RSpec.describe "Settings", type: :request do
  describe "GET /settings/notifications" do
    let(:user) { create(:user) }

    before do
      login_as(user)
    end

    it "正常に表示される" do
      get notifications_settings_path

      expect(response).to have_http_status(:ok)
    end
  end
end
