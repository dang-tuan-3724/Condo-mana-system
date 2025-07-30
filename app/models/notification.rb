class Notification < ApplicationRecord
  belongs_to :user
  validates :message, presence: true
  validates :status, inclusion: { in: %w[unread read] }
end