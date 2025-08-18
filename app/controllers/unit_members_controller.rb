class UnitMembersController < ApplicationController
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
end
