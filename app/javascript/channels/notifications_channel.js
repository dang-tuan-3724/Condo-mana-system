import consumer from "./consumer"

consumer.subscriptions.create("NotificationChannel", {
  connected() {
    console.log("Connected to user notification channel");
  },

  disconnected() {
    console.log("Disconnected from user notification channel");
  },

  received(data) {
    // Xử lý user notifications
    console.log("User notification received:", data);
    
    if (data.message) {
      showUserNotification(data);
    }
    
    // Update notification bell count nếu có
    updateNotificationBell();
  }
});

// Helper function để hiển thị user notification
function showUserNotification(data) {
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
  
  // Tự động ẩn sau 5 giây
  setTimeout(() => {
    if (notification.parentElement) {
      notification.remove();
    }
  }, 5000);
}

// Update notification bell (nếu có trong navbar)
function updateNotificationBell() {
  const bellElement = document.querySelector('#notification-bell-count');
  if (bellElement) {
    const currentCount = parseInt(bellElement.textContent) || 0;
    bellElement.textContent = currentCount + 1;
    bellElement.classList.remove('hidden');
  }
}