class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # database_authenticatable xác thực user qua email, password trong DB
  # registerable dùng để user đăng ký tài khoản mới
  # recoverable đùng để user khôi phục mật khẩu
  # rememberable ghi nhớ thông tin đăng nhập
  # validatable dùng để xác thực email đúng format và password đủ dài, password/confirm match.

  belongs_to :condo, optional: true
  has_many :unit_members, dependent: :destroy
  # has_many :units, foreign_key: :house_owner_id, dependent: :restrict_with_error
  has_many :units, foreign_key: :house_owner_id, dependent: :destroy
  has_many :units_as_member, through: :unit_members, source: :unit
  has_many :bookings, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :approved_bookings, class_name: "Booking", foreign_key: :approved_by_id, dependent: :nullify

  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: %w[super_admin operation_admin house_owner house_member] }
  validate :condo_consistency_with_units

  def superadmin?
    role == "super_admin"
  end

  def operation_admin?
    role == "operation_admin"
  end

  def house_owner?
    role == "house_owner"
  end

  def house_member?
    role == "house_member"
  end

  def admin?
    superadmin? || operation_admin?
  end


  def all_related_units
    (units + units_as_member).uniq
  end

  def debug_unit_relationships
    {
      id: id,
      email: email,
      condo_id: condo_id,
      condo_name: condo&.name,
      units_as_owner: units.pluck(:id, :unit_number),
      units_as_member: units_as_member.pluck(:id, :unit_number),
      unit_members_count: unit_members.count,
      unit_members_details: unit_members.includes(:unit).map { |um|
        {
          unit_id: um.unit_id,
          unit_number: um.unit.unit_number,
          unit_condo_id: um.unit.condo_id
        }
      }
    }
  end

  # Get all other members in the same units as this user
  def unit_mates
    unit_ids = all_related_units.pluck(:id)
    return User.none if unit_ids.empty?

    User.joins(:unit_members)
        .where(unit_members: { unit_id: unit_ids })
        .where.not(id: id)
        .distinct
  end

  def self.serialize_into_session(record)
    [ record.id.to_s, record.authenticatable_salt ]
  end

  private

  def condo_consistency_with_units
    return unless condo_id.present? && unit_members.any?

    unit_condos = unit_members.joins(:unit).pluck("units.condo_id").uniq
    if unit_condos.any? && !unit_condos.include?(condo_id)
      errors.add(:condo_id, "must match the condo of associated units")
    end
  end

  def self.serialize_from_session(id, salt)
    record = find_by(id: id)
    record if record && record.authenticatable_salt == salt
  end

  def condo_ids
    condo_id ? [ condo_id ] : []
  end
end
