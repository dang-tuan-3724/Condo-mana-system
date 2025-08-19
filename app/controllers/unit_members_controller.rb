class UnitMembersController < ApplicationController
  before_action :set_unit, only: [ :create ]
  def create
      @unit_member = @unit.unit_members.new(unit_member_params)
      authorize @unit_member
      if @unit_member.save
        redirect_to @unit, notice: "Member added successfully."
      else
        redirect_to @unit, alert: "Failed to add member."
      end
  end

  def destroy
    @unit_member = UnitMember.find(params[:id])
    @unit = @unit_member.unit
    authorize @unit_member

    if @unit_member.destroy
      redirect_to unit_path(@unit), notice: "Member removed from unit"
    else
      redirect_to unit_path(@unit), alert: "Failed to remove member"
    end
  end
  private
  def unit_member_params
    params.require(:unit_member).permit(:user_id, :unit_id)
  end
  def set_unit
    # unit may be provided either as unit_id param or inside unit_member
    unit_id = params[:unit_id] || (params[:unit_member] && params[:unit_member][:unit_id])
    @unit = Unit.find(unit_id)
  rescue ActiveRecord::RecordNotFound
    redirect_to units_path, alert: "Unit not found."
  end
end
