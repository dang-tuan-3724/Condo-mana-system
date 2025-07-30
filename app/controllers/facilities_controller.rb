class FacilitiesController < ApplicationController
  def index
    @facilities = Facility.all
  end

  def show
    @facility = Facility.find(params[:id])
  end

  def create
    @facilities = Facility.new(facility_params)
    if @facilities.save
      redirect_to @facilities, notice: "Facility was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end
  def new
    @facility = Facility.new
    @condos = Condo.all
  end

  def edit
    @facility = Facility.find(params[:id])
  end

  # def image_base64
  #   "data:image/jpeg;base64,#{Base64.strict_encode64(image)}" if image
  # end
  private

  def facility_params
    params.require(:facility).permit(:name, :description, :image, :condo_id)
  end
end
