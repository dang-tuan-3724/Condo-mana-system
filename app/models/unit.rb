class Unit < ApplicationRecord
  belongs_to :condo
  belongs_to :house_owner, class_name: "User", optional: true
  has_many :unit_members, dependent: :destroy
  has_many :members, through: :unit_members, source: :user
  validates :unit_number, presence: true, uniqueness: { scope: :condo_id }
end
