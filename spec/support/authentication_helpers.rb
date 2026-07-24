module AuthenticationHelpers
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

    get "/auth/google_oauth2/callback"
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
end
