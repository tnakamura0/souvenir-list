class TodayController < ApplicationController
  def show
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
