class Facility < ApplicationRecord
  belongs_to :condo
  has_many :bookings, dependent: :destroy
  validates :name, presence: true, uniqueness: { scope: :condo_id }
  
end
