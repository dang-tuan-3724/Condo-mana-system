module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      Rails.logger.info "ActionCable connected for user: #{current_user.id}"
    end

    private

    def find_verified_user
      # Sử dụng warden từ Devise
      env["warden"]&.user || reject_unauthorized_connection
    end
  end
end
