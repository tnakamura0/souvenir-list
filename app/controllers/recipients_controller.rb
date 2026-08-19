class RecipientsController < ApplicationController
  def index
    @tags = current_user.tags.order(:name)
    @selected_tag = current_user.tags.find_by(id: params[:tag_id])

    @recipients = current_user.recipients.includes(:tags)
    @recipients = @recipients.with_tag(@selected_tag.id) if @selected_tag
  end

  def new
    @recipient = Recipient.new
    @tags = current_user.tags
  end

  def create
    @recipient = current_user.recipients.build(recipient_params)
    if save_recipient_with_new_tag(@recipient)
      redirect_to recipients_path, notice: t(".success")
    else
      @tags = current_user.tags
      flash.now[:alert] = t(".failure")
      render :new, status: :unprocessable_content
    end
  end

  def show
    @recipient = current_user.recipients.find(params[:id])
    @souvenir_history = @recipient.trip_recipients
                                  .where(purchased: true)
                                  .where.not(souvenir_name: [ nil, "" ])
                                  .joins(:trip)
                                  .includes(:trip)
                                  .order("trips.departure_date DESC")
  end

  def edit
    @recipient = current_user.recipients.find(params[:id])
    @tags = current_user.tags
  end

  def update
    @recipient = current_user.recipients.find(params[:id])
    @recipient.assign_attributes(recipient_params)

    if save_recipient_with_new_tag(@recipient)
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
    permitted = params.require(:recipient).permit(:name, :kind, :people_count, :memo, :new_tag_name, tag_ids: [])

    permitted[:tag_ids] = current_user.tags.where(id: permitted[:tag_ids]).pluck(:id)

    permitted
  end

  def save_recipient_with_new_tag(recipient)
    ActiveRecord::Base.transaction do
      recipient.save!

      tag_name = recipient.new_tag_name.to_s.strip

      if tag_name.present?
        tag = current_user.tags.find_or_create_by!(name: tag_name)
        recipient.tags << tag unless recipient.tags.exists?(tag.id)
      end
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end
end
