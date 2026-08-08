class TripRecipientsController < ApplicationController
  def new
    @trip = current_user.trips.find(params[:trip_id])
    @tags = current_user.tags.order(:name)
    @selected_tag = current_user.tags.find_by(id: params[:tag_id])

    @recipients = current_user.recipients.includes(:tags).where.not(id: @trip.recipient_ids)

    @recipients = @recipients.with_tag(@selected_tag.id) if @selected_tag
  end

  def create
    @trip = current_user.trips.find(params[:trip_id])
    recipient_ids = Array(params[:recipient_ids])

    if recipient_ids.empty?
      redirect_to new_trip_trip_recipient_path(@trip), alert: t(".empty")
      return
    end

    recipients = current_user.recipients.where(id: recipient_ids)

    # 送信されたIDと取得できた自分の相手の数が一致するか確認する
    # 他のユーザーが作成した相手が送信された場合を除外する
    if recipients.size != recipient_ids.size
      redirect_to new_trip_trip_recipient_path(@trip), alert: t(".invalid")
      return
    end

    recipients.each do |recipient|
      @trip.trip_recipients.find_or_create_by!(recipient:)
    end

    redirect_to trip_path(@trip), notice: t(".success")
  end

  def update
    @trip = current_user.trips.find(params[:trip_id])
    @trip_recipient = @trip.trip_recipients.find(params[:id])

    @trip_recipient.update!(trip_recipient_params)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to trip_path(@trip) }
    end
  end

  def destroy
    @trip = current_user.trips.find(params[:trip_id])
    @trip_recipient = @trip.trip_recipients.find(params[:id])

    @trip_recipient.destroy!

    redirect_to trip_path(@trip), notice: t(".success")
  end

  private

  def trip_recipient_params
    params.require(:trip_recipient).permit(:purchased)
  end
end
