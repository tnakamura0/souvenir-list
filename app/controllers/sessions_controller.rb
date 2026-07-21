class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new
  end

  def create
    if (user = User.find_or_create_from_auth_hash(auth_hash))
      login user
      redirect_to root_path
    else
      render root_path, status: :unprocessable_entity
    end
  end

  def destroy
    logout
    redirect_to root_path, status: :see_other
  end

  private

  def auth_hash
    request.env["omniauth.auth"]
  end
end
