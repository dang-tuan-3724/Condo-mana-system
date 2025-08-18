// Notification Manager - Quản lý việc subscribe các channels
import consumer from "./channels/consumer"

class NotificationManager {
  constructor() {
    this.userSubscription = null;
    this.adminSubscription = null;
  }

  // Subscribe to user notifications
  subscribeToUserNotifications(userId) {
    if (this.userSubscription) {
      return; // Đã subscribe rồi
    }

    this.userSubscription = consumer.subscriptions.create(
      { channel: "NotificationChannel" },
      {
        connected() {
          console.log("Connected to user notification channel");
        },

        disconnected() {
          console.log("Disconnected from user notification channel");
        },

        received(data) {
          console.log("User notification received:", data);
          
          if (data.message) {
            this.showUserNotification(data);
          }
          
          this.updateNotificationBell();
        },

        showUserNotification(data) {
          const notification = document.createElement('div');
          notification.className = 'fixed top-4 right-4 bg-blue-500 text-white px-6 py-4 rounded-lg shadow-lg z-50';
          notification.innerHTML = `
            <div class="flex items-center">
              <i class="fas fa-info-circle mr-2"></i>
              <span>${data.message}</span>
              <button class="ml-4 text-white hover:text-gray-200" onclick="this.parentElement.parentElement.remove()">
                <i class="fas fa-times"></i>
              </button>
            </div>
          `;
          
          document.body.appendChild(notification);
          
          setTimeout(() => {
            if (notification.parentElement) {
              notification.remove();
            }
          }, 5000);
        },

        updateNotificationBell() {
          const bellElement = document.querySelector('#notification-bell-count');
          if (bellElement) {
            const currentCount = parseInt(bellElement.textContent) || 0;
            bellElement.textContent = currentCount + 1;
            bellElement.classList.remove('hidden');
          }
        }
      }
    );
  }

  // Subscribe to admin notifications
  subscribeToAdminNotifications() {
    if (this.adminSubscription) {
      return; // Đã subscribe rồi
    }

    this.adminSubscription = consumer.subscriptions.create(
      { channel: "AdminNotificationChannel" },
      {
        connected() {
          console.log("Connected to admin notification channel");
        },

        disconnected() {
          console.log("Disconnected from admin notification channel");
        },

        received(data) {
          console.log("Admin notification received:", data);
          
          if (data.message) {
            this.showAdminNotification(data);
          }
        },

        showAdminNotification(data) {
          const notification = document.createElement('div');
          notification.className = 'fixed top-4 right-4 bg-red-500 text-white px-6 py-4 rounded-lg shadow-lg z-50';
          notification.innerHTML = `
            <div class="flex items-center">
              <i class="fas fa-exclamation-triangle mr-2"></i>
              <strong>Admin Alert:</strong> ${data.message}
              <button class="ml-4 text-white hover:text-gray-200" onclick="this.parentElement.parentElement.remove()">
                <i class="fas fa-times"></i>
              </button>
            </div>
          `;
          
          document.body.appendChild(notification);
          
          setTimeout(() => {
            if (notification.parentElement) {
              notification.remove();
            }
          }, 7000); // Admin notifications stay longer
        }
      }
    );
  }

  // Unsubscribe từ tất cả channels
  unsubscribeAll() {
    if (this.userSubscription) {
      this.userSubscription.unsubscribe();
      this.userSubscription = null;
    }
    
    if (this.adminSubscription) {
      this.adminSubscription.unsubscribe();
      this.adminSubscription = null;
    }
  }
}

// Export singleton instance
export default new NotificationManager();
