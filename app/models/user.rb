class User < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :google_uid, presence: true, uniqueness: true

  class << self
    def find_or_create_from_auth_hash(auth_hash)
      user_params = user_params_from_auth_hash(auth_hash)
      user = find_or_initialize_by(google_uid: user_params[:google_uid])
      user.update(user_params)
      user
    end

    private

    def user_params_from_auth_hash(auth_hash)
      {
        name: auth_hash.info.name,
        email: auth_hash.info.email,
        google_uid: auth_hash.uid,
        avatar_url: auth_hash.info.image
      }
    end
  end
end
