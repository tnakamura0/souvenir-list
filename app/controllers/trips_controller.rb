class TripsController < ApplicationController
  def index
    @trips = current_user.trips
  end
end
