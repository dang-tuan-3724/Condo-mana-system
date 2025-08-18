import consumer from "./consumer"

consumer.subscriptions.create("AdminNotificationChannel", {
  connected() {
    console.log("Connected to admin notification channel");
  },

  disconnected() {
    console.log("Disconnected from admin notification channel");
  },

  received(data) {
    // Xử lý admin notifications
    console.log("Admin notification received:", data);
    
    // Hiển thị notification cho admin
    if (data.message) {
      // Tạo notification toast hoặc popup cho admin
      showAdminNotification(data);
    }
  }
});

// Helper function để hiển thị admin notification
function showAdminNotification(data) {
  // Tạo element notification
  const notification = document.createElement('div');
  notification.className = 'fixed top-4 right-4 bg-red-500 text-white px-6 py-4 rounded-lg shadow-lg z-50';
  notification.innerHTML = `
    <div class="flex items-center">
      <i class="fas fa-exclamation-triangle mr-2"></i>
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
