class ErrorsController < ApplicationController
  layout "error"

  skip_before_action :require_login

  def not_found
    render status: :not_found
  end
end
