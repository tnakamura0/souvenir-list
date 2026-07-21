class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create failure]

  def new
  end

  def create
    user = User.find_or_create_from_auth_hash(auth_hash)

    if user.persisted?
      login user
      redirect_to root_path, notice: "ログインしました"
    else
      redirect_to login_path, alert: "ログインできませんでした"
    end
  end

  def destroy
    logout
    redirect_to login_path, notice: "ログアウトしました", status: :see_other
  end

  def failure
    redirect_to login_path, alert: "ログインできませんでした"
  end

  private

  def auth_hash
    request.env["omniauth.auth"]
  end
end
