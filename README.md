# Condo-mana-system

Ứng dụng quản lý chung cư (Condo Management System) — một ứng dụng nội bộ để quản lý tòa nhà, căn hộ, tiện ích, đặt chỗ, và thông báo thời gian thực.

## Mục tiêu
- Cung cấp công cụ quản lý chung cư: quản lý condo, unit, tiện ích (facility), và thành viên.
- Hệ thống đặt chỗ theo khung giờ (time slots) cho các tiện ích, với quy trình phê duyệt và giải quyết xung đột.
- Thông báo thời gian thực cho user và admin thông qua ActionCable.

## Những công nghệ chính được sử dụng

- Ruby on Rails 8 (backend web framework)
- PostgreSQL (database chính)
- Puma (web server)
- Sidekiq (background jobs)
- Redis (queue / cache / ActionCable adapter)
- Devise (authentication)
- Pundit (authorization / chính sách quyền truy cập)
- Hotwire (Turbo + Stimulus) & Importmap (xây dựng trải nghiệm giao diện động nhẹ)
- Propshaft (asset pipeline hiện đại cho Rails)
- Tailwind CSS (thiết kế giao diện) — gem `tailwindcss-rails` và script build trong `package.json`
- jQuery (có hỗ trợ qua `jquery-rails` cho những tương tác cũ)
- ActionCable (websocket realtime notifications)
- Sidekiq Web UI (mounted at `/sidekiq`) để quan sát job queue
- Gems tiện ích/deploy: Kamal (docker deploy), Thruster (Puma optimizations), Bootsnap, Brakeman (security scan), RuboCop (linting)
- Test & QA: RSpec/Capybara/Selenium (test automation), FactoryBot, SimpleCov
- Icon/fonts: Heroicon, Font Awesome

Ghi chú: các gem và script chính có thể xem trong `Gemfile` và `package.json`.

## Các mô-đun / tính năng đã hiện thực

1. Xác thực & phân quyền
	- Đăng ký / đăng nhập bằng `Devise`.
	- Hệ thống vai trò: `super_admin`, `operation_admin`, `house_owner`, `house_member`.
	- Quyền truy cập chi tiết được quản lý qua `Pundit` (các policy nằm trong `app/policies`).

2. Quản lý Condo (tòa nhà)
	- CRUD cho `Condo` (chỉ super_admin có thể tạo, operation_admin quản lý condo của họ).

3. Quản lý Unit (căn hộ)
	- CRUD cho `Unit`.
	- Mỗi unit liên kết với `house_owner` (user) và nhiều `unit_members`.
	- Hỗ trợ lọc và quyền chỉ xem sửa xóa theo role (policy trong `UnitPolicy`).

4. Quản lý Thành viên (Users)
	- Tạo/ chỉnh sửa/ xóa thành viên (người có role phù hợp mới được tạo/xóa).
	- Gán user vào condo / unit, đồng bộ condo khi gán unit.
	- Khi thay đổi unit, cập nhật quan hệ house_owner / unit_members tương ứng.

5. Unit member invitations / requests
	- House owner (hoặc admin) có thể mời user tham gia unit (tạo `UnitMemberRequest`).
	- Recipient có thể `accept` hoặc `decline`.
	- Khi accept sẽ tạo `UnitMember` và tạo thông báo cho cả sender & recipient.

6. Facilities (Tiện ích tòa nhà)
	- CRUD cho `Facility` (ví dụ: hồ bơi, phòng họp, sân thể thao).
	- Mỗi facility có `availability_schedule` (stored as JSON/JSONB): map ngày -> danh sách time slots.
	- Khi tạo/cập nhật facility, UI có thể cung cấp `availability_schedule_days` và `availability_schedule_times` để xây dựng lịch.

7. Bookings (đặt chỗ theo khung giờ)
	- Bookings lưu trữ `booking_time_slots` (hash ngày => list time slot strings).
	- Quy trình: user tạo booking (status = `pending`) → admin/operation_admin có thể phê duyệt (`approved`) hoặc từ chối (`rejected`), hoặc user có thể hủy (`cancelled`).
	- Validation:
	  - Kiểm tra định dạng `booking_time_slots` (hash ngày => mảng string).
	  - Kiểm tra booking nằm trong `availability_schedule` của facility.
	  - Ngăn chặn xung đột: không cho phép booking trùng time slot với booking khác đang ở trạng thái `pending` hoặc `approved`.
	- Khi tạo booking, time slots được tạm khóa (loại khỏi `availability_schedule`) để tránh xung đột.
	- Khi booking bị hủy / từ chối / xóa, các time slots được khôi phục vào `availability_schedule`.
	- Có `BookingConflictResolutionJob` (ActiveJob/Sidekiq) dùng để xử lý xung đột bất đồng bộ.

8. Notifications (Thông báo)
	- Model `Notification` lưu thông báo (message, status: `unread`/`read`, category, reference polymorphic).
	- Thông báo được tạo khi các sự kiện quan trọng xảy ra: tạo booking, thay đổi trạng thái booking, invite unit member, accept/decline, v.v.
	- Real-time broadcasting via `ActionCable` (channels):
	  - Broadcast user-specific notifications to `notifications:USER_ID`.
	  - Broadcast admin notifications (ví dụ: thông báo admin khi có booking cần duyệt).
	- Có các endpoint thử nghiệm: `notifications#test_user_notification` và `notifications#test_admin_notification`.

9. Background jobs & admin UI
	- Sidekiq sử dụng cho job xử lý xung đột booking.
	- Sidekiq Web UI mounted at `/sidekiq`.
	- ActionCable mounted at `/cable`.

10. API / JSON endpoints
	- Một số controller trả về JSON cho tìm kiếm/auto-complete (ví dụ `UnitsController#index` support JSON trả về id/unit_number).
	- `Jbuilder` sẵn sàng phục vụ các view JSON nếu cần mở rộng API.

11. Health check
	- Endpoint `GET /up` trỏ tới `rails/health#show` để health checks.

## Các model chính
- User: quản lý người dùng, role, quan hệ với condo, unit_members.
- Condo: tòa nhà, chứa units và facilities.
- Unit: căn hộ, có house_owner và unit_members.
- UnitMember / UnitMemberRequest: quan hệ thành viên và lời mời/ yêu cầu tham gia.
- Facility: tiện ích của condo, có `availability_schedule` (JSONB).
- Booking: đặt chỗ theo time slots, có trạng thái và callbacks để cập nhật availability.
- Notification: lưu và phát thông báo.

## Các route chính (tóm tắt)
- root: `GET /` → `static_pages#home`
- Devise: user auth routes
- `resources :condos`
- `resources :units`
- `resources :facilities`
- `resources :bookings`
- `resources :users, path: "members"`
- `resources :unit_member_requests` (member: accept, decline)
- `resources :unit_members` (create/destroy)
- `resources :notifications` (test endpoints included)
- Sidekiq Web: `/sidekiq`
- ActionCable: `/cable`

## Chạy ứng dụng (phát triển) — các bước cơ bản
1. Cài gem & node deps

```bash
bundle install
yarn install # nếu cần (dựa vào package manager dự án)
```

2. Thiết lập database

```bash
rails db:create db:migrate db:seed
```

3. Build CSS (Tailwind)

```bash
yarn build:css
# hoặc
rails css:build
```

4. Chạy server & sidekiq

```bash
# terminal 1
rails server

# terminal 2
bundle exec sidekiq
```

5. Truy cập

- Ứng dụng: http://localhost:3000
- Sidekiq Web UI: http://localhost:3000/sidekiq

## Tài liệu & nơi cần xem mã nguồn
- Policies (quyền): `app/policies`
- Controllers: `app/controllers`
- Models: `app/models`
- Channels / Notification helper: xem `app/javascript` và `app/helpers/notification_helper.rb` (nếu có)

## Kiểm thử
- Các gem test có trong `Gemfile` (Capybara, Selenium, FactoryBot, SimpleCov). Chạy test bằng:

```bash
rails test
```



