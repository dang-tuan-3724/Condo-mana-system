class FacilitiesController < ApplicationController
  def index
    if params[:search].present?
      @facilities = Facility.joins(:condo).where("facilities.name ILIKE ? OR facilities.description ILIKE ? OR condos.name ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    else
      @facilities = Facility.all
    end
  end

  def show
    @facility = Facility.find(params[:id])
  end

  def create
    @facility = Facility.new(facility_params)
    @facility.availability_schedule = build_availability_schedule(params[:facility])

    authorize @facility

    if @facility.save
      redirect_to @facility, notice: "Facility was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end
  def new
    @facility = Facility.new
    
    authorize @facility
    @condos = Condo.all
  end

  def edit
    @facility = Facility.find(params[:id])
    @condos = Condo.all
    authorize @facility
  rescue ActiveRecord::RecordNotFound
    redirect_to facilities_path, alert: "Facility not found."
  end

  def update
    @facility = Facility.find(params[:id])
    authorize @facility
    if @facility.update(facility_params)
      @facility.update_column(:availability_schedule, build_availability_schedule(params[:facility]))
      redirect_to @facility, notice: "Facility was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  def destroy
    @facility = Facility.find(params[:id])
    authorize @facility
    if @facility.destroy
      redirect_to facilities_path, notice: "Facility was successfully deleted."
    else
      redirect_to @facility, alert: "Failed to delete facility."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to facilities_path, alert: "Facility not found."
  rescue Pundit::NotAuthorizedError
    redirect_to facilities_path, alert: "You are not authorized to delete this facility."
  rescue StandardError => e
    redirect_to facilities_path, alert: "An error occurred while deleting the facility: #{e.message}"
  end


  private
  # hàm này trả về hash, active record của rails tự động chuyển từ hash sang jsonb
  def build_availability_schedule(facility_params)
    days = facility_params[:availability_schedule_days] || []
    times = facility_params[:availability_schedule_times] || []
    schedule = Hash.new { |hash, key| hash[key] = [] }
    days.zip(times) do |day, time|
      next if day.blank? || time.blank?
      schedule[day] << time
    end
    schedule
  end
  def facility_params
    params.require(:facility).permit(:name, :description, :floor, :condo_id)
  end
end
