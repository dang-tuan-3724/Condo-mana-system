class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :reference, polymorphic: true, optional: true
  validates :message, presence: true
  validates :status, inclusion: { in: %w[unread read] }
end
