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
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user

    if @user.save
      redirect_to @user, notice: "Thành viên đã được tạo thành công."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @user
  end

  def update
    authorize @user

    if @user.update(user_params)
      redirect_to @user, notice: "Thông tin thành viên đã được cập nhật."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user

    flash[:success] = "User deleted"
    @user.destroy
    redirect_to users_url, notice: "Thành viên đã được xóa."
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
end
