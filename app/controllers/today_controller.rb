class TodayController < ApplicationController
  skip_before_action :require_login, only: :show

  def show
    return redirect_to login_path unless logged_in?

    @today_trips = current_user.trips
                              .where(departure_date: ..Date.current)
                              .where(return_date: Date.current..)
                              .order(:departure_date)

    @trip =
      if params[:trip_id].present?
        @today_trips.find(params[:trip_id])
      else
        @today_trips.first
      end

    @trip_recipients = @trip&.trip_recipients&.includes(recipient: :tags)
  end
end
