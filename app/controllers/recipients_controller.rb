class RecipientsController < ApplicationController
  def index
    @recipients = current_user.recipients
  end
end
