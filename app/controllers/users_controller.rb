class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]
  before_action :all_condos

  def index
    authorize User
    @users = policy_scope(User)

    if params[:condo_id].present?
      @users = @users.where(condo_id: params[:condo_id])
    end
  end

  def show
    authorize @user
    @related_units = @user.all_related_units
  rescue ActiveRecord::RecordNotFound
    redirect_to users_path, alert: "User not found."
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user

    ActiveRecord::Base.transaction do
      if @user.save
        # Nếu có unit_id được chọn, tạo liên kết UnitMember
        unit_id = unit_id_param
        if unit_id.present?
          unit = Unit.find(unit_id)
          @user.unit_members.create!(unit: unit)

          # Nếu role là house_owner, cập nhật house_owner_id của unit
          if @user.role == "house_owner"
            unit.update!(house_owner: @user)
          end
        end

        redirect_to @user, notice: "Thành viên đã được tạo thành công."
      else
        render :new, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    @user.errors.add(:base, "Không thể liên kết với unit: #{e.message}")
    render :new, status: :unprocessable_entity
  end

  def edit
    authorize @user
  end

  def update
    authorize @user

    ActiveRecord::Base.transaction do
      # Debug logging
      Rails.logger.debug "Update user params: #{params[:user]}"
      Rails.logger.debug "Unit ID param: #{unit_id_param}"

      # Xử lý giữ nguyên mật khẩu nếu để trống
      filtered_params = user_params.dup
      if filtered_params[:password].blank? && filtered_params[:password_confirmation].blank?
        filtered_params.delete(:password)
        filtered_params.delete(:password_confirmation)
      end

      if @user.update(filtered_params)
        # Xử lý thay đổi unit nếu có
        unit_id = unit_id_param

        Rails.logger.debug "Processing unit_id: #{unit_id}"

        # Lưu lại unit cũ để log
        old_units = @user.unit_members.pluck(:unit_id)
        Rails.logger.debug "Old units: #{old_units}"

        # Xóa liên kết unit cũ trước
        @user.unit_members.destroy_all
        # Xóa house_owner khỏi unit cũ nếu có
        Unit.where(house_owner: @user).update_all(house_owner_id: nil)

        if unit_id.present?
          new_unit = Unit.find(unit_id)
          Rails.logger.debug "Found new unit: #{new_unit.id} - #{new_unit.unit_number}"

          # Tạo liên kết unit mới
          @user.unit_members.create!(unit: new_unit)

          # Nếu role là house_owner, cập nhật house_owner_id của unit mới
          if @user.role == "house_owner"
            new_unit.update!(house_owner: @user)
            Rails.logger.debug "Updated house_owner for unit #{new_unit.id}"
          end
        else
          Rails.logger.debug "No unit_id provided, removed all unit associations"
        end

        redirect_to @user, notice: "Thông tin thành viên đã được cập nhật."
      else
        render :edit, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Error updating user unit association: #{e.message}"
    @user.errors.add(:base, "Không thể cập nhật liên kết với unit: #{e.message}")
    render :edit, status: :unprocessable_entity
  end

  def destroy
    authorize @user
    if @user.destroy
      flash[:success] = "Thành viên đã được xóa."
      redirect_to users_url
    else
      Rails.logger.error "Failed to delete user: #{@user.errors.full_messages.join(", ")}"
      flash[:error] = "Không thể xóa thành viên: #{@user.errors.full_messages.join(", ")}"
      redirect_to @user
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Không tìm thấy thành viên"
  end

  def all_condos
    @condos = Condo.all
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :role, :password, :password_confirmation, :condo_id)
  end

  def unit_id_param
    params.dig(:user, :unit_id)
  end
end
