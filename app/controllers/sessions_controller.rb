class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create failure]

  def new
  end

  def create
    user = User.find_or_create_from_auth_hash(auth_hash)

    if user.persisted?
      login user
      redirect_to root_path, notice: t("sessions.login_success")
    else
      redirect_to login_path, alert: t("sessions.login_failure")
    end
  end

  def destroy
    logout
    redirect_to login_path, notice: t("sessions.logout_success"), status: :see_other
  end

  def failure
    redirect_to login_path, alert: t("sessions.login_failure")
  end

  private

  def auth_hash
    request.env["omniauth.auth"]
  end
end
