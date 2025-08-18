class UnitMemberRequest < ApplicationRecord
  belongs_to :unit
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"

  validates :status, inclusion: { in: %w[pending accepted declined] }
  validate :no_existing_pending_request

  after_create :notify_recipient

  def accept!
    transaction do
      UnitMember.create!(unit: unit, user: recipient)
      update!(status: "accepted")
      create_notification(recipient, "You have been added to unit #{unit.unit_number}.")
      create_notification(sender, "#{recipient.first_name} #{recipient.last_name} accepted your invitation to join unit #{unit.unit_number}.")
    end
  end

  def decline!
    update!(status: "declined")
    create_notification(recipient, "You declined the request to join unit #{unit.unit_number}.")
    create_notification(sender, "#{recipient.first_name} #{recipient.last_name} declined your invitation to join unit #{unit.unit_number}.")
  end

  private

  def notify_recipient
    create_notification(recipient, "You have a request to join unit #{unit.unit_number} from #{sender.first_name} #{sender.last_name}.")
  end

  def no_existing_pending_request
    return unless unit_id && recipient_id

    existing = UnitMemberRequest.where(unit_id: unit_id, recipient_id: recipient_id, status: "pending")
    if persisted?
      existing = existing.where.not(id: id)
    end

    if existing.exists?
      errors.add(:recipient_id, "already has a pending request for this unit")
    end
  end

  def create_notification(user, message)
    Notification.create!(user: user, message: message, reference: self)
    # broadcast via ActionCable
    begin
      ActionCable.server.broadcast(
        "notifications:#{user.id}",
        {
          message: message,
          timestamp: Time.current.iso8601
        }
      )
    rescue => e
      Rails.logger.warn "Failed to broadcast notification: "+e.message
    end
  end
end
