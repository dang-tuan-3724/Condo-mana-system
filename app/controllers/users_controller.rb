class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]
  before_action :all_condos

  def index
    authorize User
    @users = policy_scope(User)
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @users = @users.left_joins(:condo)
                     .left_joins(:units) # house_owner units
                     .left_joins(:units_as_member) # member units
                     .where(
                       "users.first_name ILIKE :q OR users.last_name ILIKE :q OR users.email ILIKE :q OR condos.name ILIKE :q OR units.unit_number ILIKE :q OR units_as_members_users.unit_number ILIKE :q",
                       q: search_term
                     ).distinct
    else
      @users = @users.includes(:condo, :unit_members)
    end

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
        # If a unit_id is selected, create a UnitMember association
        unit_id = unit_id_param
        if unit_id.present?
          unit = Unit.find(unit_id)

          # Update user's condo to match the unit's condo
          @user.update!(condo_id: unit.condo_id)

          @user.unit_members.create!(unit: unit)

          # If the role is house_owner, update the house_owner_id of the unit
          if @user.role == "house_owner"
            unit.update!(house_owner: @user)
          end
        end

        redirect_to @user, notice: "Member was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    @user.errors.add(:base, "Could not associate with unit: #{e.message}")
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

      # Handle keeping the password unchanged if left blank
      filtered_params = user_params.dup
      if filtered_params[:password].blank? && filtered_params[:password_confirmation].blank?
        filtered_params.delete(:password)
        filtered_params.delete(:password_confirmation)
      end

      if @user.update(filtered_params)
        # Handle changing unit if present
        unit_id = unit_id_param

        Rails.logger.debug "Processing unit_id: #{unit_id}"

        # Save old units for logging
        old_units = @user.unit_members.pluck(:unit_id)
        Rails.logger.debug "Old units: #{old_units}"

        # Only update unit associations if unit_id is provided and different from current
        current_unit_id = @user.unit_members.first&.unit_id

        if unit_id.present? && unit_id.to_s != current_unit_id.to_s
          # Remove old unit associations
          @user.unit_members.destroy_all
          # Remove house_owner from old unit if present
          Unit.where(house_owner: @user).update_all(house_owner_id: nil)

          new_unit = Unit.find(unit_id)
          Rails.logger.debug "Found new unit: #{new_unit.id} - #{new_unit.unit_number}"

          # Update user's condo to match the unit's condo
          @user.update!(condo_id: new_unit.condo_id)

          # Create new unit association
          @user.unit_members.create!(unit: new_unit)

          # If the role is house_owner, update the house_owner_id of the new unit
          if @user.role == "house_owner"
            new_unit.update!(house_owner: @user)
            Rails.logger.debug "Updated house_owner for unit #{new_unit.id}"
          end

          Rails.logger.debug "Updated user condo_id to #{new_unit.condo_id} to match unit"
        elsif unit_id.blank? && @user.unit_members.any?
          # User explicitly wants to remove all unit associations
          Rails.logger.debug "Removing all unit associations as unit_id is blank"
          @user.unit_members.destroy_all
          Unit.where(house_owner: @user).update_all(house_owner_id: nil)
        else
          Rails.logger.debug "No unit changes needed"
        end

        redirect_to @user, notice: "User was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Error updating user unit association: #{e.message}"
    @user.errors.add(:base, "Could not update association with unit: #{e.message}")
    render :edit, status: :unprocessable_entity
  end

  def destroy
    authorize @user
    if @user.destroy
      redirect_to users_url, notice: "User was successfully deleted."
    else
      redirect_to @user, alert: "Could not delete member: #{@user.errors.full_messages.join(", ")}"
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Member not found"
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
