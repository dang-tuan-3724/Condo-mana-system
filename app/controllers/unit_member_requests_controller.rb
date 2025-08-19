class UnitMemberRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_unit_member_request, only: [ :accept, :decline ]

  def create
  @unit = Unit.find(params[:unit_id])
  # inviting a member is considered updating the unit permissions; authorize with :update?
  authorize @unit, :update?
    # only house_owner of the unit can invite
    unless (current_user.house_owner? && @unit.house_owner_id == current_user.id) || (current_user.admin?)
      return redirect_to @unit, alert: "Only the house owner can invite members."
    end

    recipient_id = params[:recipient_id]
    recipient = User.find_by(id: recipient_id)
    unless recipient
      return redirect_to @unit, alert: "Recipient not found"
    end

    # unit member request
    umr = UnitMemberRequest.new(unit: @unit, sender: current_user, recipient: recipient)
    if umr.save
      redirect_to @unit, notice: "Invitation sent to #{recipient.first_name} #{recipient.last_name}"
    else
      redirect_to @unit, alert: umr.errors.full_messages.to_sentence
    end
  end

  def accept
    # only recipient can accept
    unless @unit_member_request.recipient_id == current_user.id
      return redirect_back(fallback_location: root_path, alert: "Not authorized")
    end

    @unit_member_request.accept!
    redirect_to unit_path(@unit_member_request.unit), notice: "You joined the unit."
  rescue ActiveRecord::RecordInvalid => e
    redirect_back(fallback_location: root_path, alert: e.message)
  end

  def decline
    unless @unit_member_request.recipient_id == current_user.id
      return redirect_back(fallback_location: root_path, alert: "Not authorized")
    end

    @unit_member_request.decline!
    redirect_to root_path, notice: "You declined the request."
  end

  private

  def set_unit_member_request
    @unit_member_request = UnitMemberRequest.find(params[:id])
  end
end
