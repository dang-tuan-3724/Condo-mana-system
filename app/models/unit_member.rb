class UnitMember < ApplicationRecord
  belongs_to :unit
  belongs_to :user
  validates :unit_id, uniqueness: { scope: :user_id }
end