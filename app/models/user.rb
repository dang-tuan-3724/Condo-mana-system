class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :condo, optional: true
  has_many :unit_members, dependent: :destroy
  has_many :units, foreign_key: :house_owner_id, dependent: :restrict_with_error
  has_many :bookings, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :approved_bookings, class_name: "Booking", foreign_key: :approved_by_id, dependent: :nullify

  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: %w[super_admin operation_admin house_owner house_member] }

  def self.serialize_into_session(record)
    [ record.id.to_s, record.authenticatable_salt ]
  end

  def self.serialize_from_session(id, salt)
    record = find_by(id: id)
    record if record && record.authenticatable_salt == salt
  end

  def condo_ids
    condo_id ? [ condo_id ] : []
  end
end
