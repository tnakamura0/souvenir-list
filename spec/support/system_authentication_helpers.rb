module SystemAuthenticationHelpers
  def login_as(user)
    OmniAuth.config.test_mode = true

    OmniAuth.config.mock_auth[:google_oauth2] =
      OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: user.google_uid,
        info: {
          name: user.name,
          email: user.email,
          image: user.avatar_url
        }
      )

    visit login_path

    within("#hero") do
      click_button "Googleでログイン"
    end

    expect(page).to have_current_path(root_path)
  end
end

RSpec.configure do |config|
  config.include SystemAuthenticationHelpers, type: :system
end
