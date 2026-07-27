class RecipientsController < ApplicationController
  def index
    @recipients = current_user.recipients
  end

  def new
    @recipient = Recipient.new
  end

  def create
    @recipient = current_user.recipients.build(recipient_params)
    if @recipient.save
      redirect_to recipients_path, notice: t(".success")
    else
      flash.now[:alert] = t(".failure")
      render :new, status: :unprocessable_content
    end
  end

  private

  def recipient_params
    params.require(:recipient).permit(:name, :kind, :people_count, :memo)
  end
end
