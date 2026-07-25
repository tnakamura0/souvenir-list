class TripsController < ApplicationController
  def index
    @trips = current_user.trips
  end

  def new
    @trip = Trip.new
  end

  def create
    @trip = current_user.trips.build(trip_params)
    if @trip.save
      redirect_to trips_path, notice: t(".success")
    else
      flash.now[:alert] = t(".failure")
      render :new, status: :unprocessable_content
    end
  end

  def show
    @trip = current_user.trips.find(params[:id])
  end

  def edit
    @trip = current_user.trips.find(params[:id])
  end

  def update
    @trip = current_user.trips.find(params[:id])
    if @trip.update(trip_params)
      redirect_to trip_path(@trip), notice: t(".success")
    else
      flash.now[:alert] = t(".failure")
      render :edit, status: :unprocessable_content
    end
  end

  private

  def trip_params
    params.require(:trip).permit(:name, :destination, :departure_date, :return_date)
  end
end
