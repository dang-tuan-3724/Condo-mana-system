class Condo < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :units, dependent: :destroy
  has_many :facilities, dependent: :destroy
  has_many :users, dependent: :restrict_with_error
end