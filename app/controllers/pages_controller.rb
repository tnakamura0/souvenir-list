class PagesController < ApplicationController
  skip_before_action :require_login

  def terms
  end

  def privacy
  end

  def sentry_test
    raise "Sentry test error"
  end
end
