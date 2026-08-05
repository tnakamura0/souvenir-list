class RecipientsController < ApplicationController
  def index
    @recipients = current_user.recipients
  end

  def new
    @recipient = Recipient.new
    @tags = current_user.tags
  end

  def create
    @recipient = current_user.recipients.build(recipient_params)
    if @recipient.save
      redirect_to recipients_path, notice: t(".success")
    else
      @tags = current_user.tags
      flash.now[:alert] = t(".failure")
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @recipient = current_user.recipients.find(params[:id])
    @tags = current_user.tags
  end

  def update
    @recipient = current_user.recipients.find(params[:id])
    if @recipient.update(recipient_params)
      redirect_to recipients_path, notice: t(".success")
    else
      @tags = current_user.tags
      flash.now[:alert] = t(".failure")
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    recipient = current_user.recipients.find(params[:id])
    recipient.destroy!
    redirect_to recipients_path, notice: t(".success")
  end

  private

  def recipient_params
    permitted = params.require(:recipient).permit(:name, :kind, :people_count, :memo, tag_ids: [])

    permitted[:tag_ids] = current_user.tags.where(id: permitted[:tag_ids]).pluck(:id)

    permitted
  end
end
