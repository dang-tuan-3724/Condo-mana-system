class UnitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_unit, only: [ :show, :edit, :update, :destroy ]
  after_action :verify_authorized, except: [ :index ]

  def index
    @units = policy_scope(Unit)
    # Only filter within the authorized scope
    if params[:condo_id].present?
      # Only filter if the condo_id is within the authorized scope
      authorized_condo_ids = @units.distinct.pluck(:condo_id)
      if authorized_condo_ids.include?(params[:condo_id].to_i)
        @units = @units.where(condo_id: params[:condo_id])
      else
        # If trying to access unauthorized condo, ignore the filter
        flash.now[:alert] = "You don't have permission to view units from that condo."
      end
    end

    respond_to do |format|
      format.html
      format.json { render json: @units.select(:id, :unit_number) }
    end
  end

  def show
    @unit = Unit.find(params[:id])
    @unit_members = @unit.unit_members
    authorize @unit
  rescue ActiveRecord::RecordNotFound
    redirect_to units_path, alert: "Unit not found."
  end

  def new
    @unit = Unit.new
    authorize @unit
  end

  def create
    @unit = Unit.new(unit_params)
    authorize @unit

    if @unit.save
      redirect_to @unit, notice: "Unit created successfully."
    else
      render :new
    end
  end

  def edit
    @unit = Unit.find(params[:id])
    authorize @unit
  rescue ActiveRecord::RecordNotFound
    redirect_to units_path, alert: "Unit not found."
  end

  def update
    @unit = Unit.find(params[:id])
    authorize @unit

    if @unit.update(unit_params)
      redirect_to @unit, notice: "Unit updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @unit = Unit.find(params[:id])
    authorize @unit
    if @unit.destroy
      redirect_to units_path, notice: "Unit deleted successfully."
    else
      redirect_to @unit, alert: "Unit not deleted. Please try again."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to units_path, alert: "Unit not found."
  end

  private
  def unit_params
    params.require(:unit).permit(:unit_number, :floor, :condo_id, :house_owner_id, :size)
  end
  def set_unit
    @unit = Unit.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to units_path, alert: "Unit not found."
  end
end
