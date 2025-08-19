
# Condo-mana-system

Condo Management System — an internal application to manage buildings, apartments, facilities, bookings, and real-time notifications.

## Goals
- Provide tools to manage condos, units, facilities, and members.
- Support timeslot-based bookings for facilities with approval workflow and conflict resolution.
- Deliver real-time notifications to users and admins via ActionCable.

## Key technologies used

- Ruby on Rails 8 (web framework)
- PostgreSQL (primary database)
- Puma (web server)
- Sidekiq (background jobs)
- Redis (queue / cache / ActionCable adapter)
- Devise (authentication)
- Pundit (authorization / access policies)
- Hotwire (Turbo + Stimulus) & Importmap (lightweight dynamic UI)
- Propshaft (modern asset pipeline for Rails)
- Tailwind CSS (`tailwindcss-rails`) for styling — build script in `package.json`
- jQuery (available via `jquery-rails` for legacy interactions)
- ActionCable (websocket-based realtime notifications)
- Sidekiq Web UI (mounted at `/sidekiq`) for monitoring job queues
- Utility / deploy gems: Kamal (Docker deploy), Thruster (Puma optimizations), Bootsnap, Brakeman (security scanner), RuboCop (linting)
- Testing & QA: Capybara / Selenium, FactoryBot, SimpleCov
- Icons / fonts: Heroicon, Font Awesome

Notes: see `Gemfile` and `package.json` for the full list of gems and scripts.

## Implemented modules / features

1. Authentication & authorization
	- Registration and sign-in via `Devise`.
	- Role system: `super_admin`, `operation_admin`, `house_owner`, `house_member`.
	- Fine-grained access control using `Pundit` (policies in `app/policies`).

2. Condo management
	- CRUD for `Condo` (creation restricted to `super_admin`, `operation_admin` manages their condo).

3. Unit (apartment) management
	- CRUD for `Unit`.
	- Each unit has a `house_owner` (User) and many `unit_members`.
	- Filtering and role-based access enforced by `UnitPolicy`.

4. Users (members) management
	- Create / edit / delete members (subject to role permissions).
	- Assign users to condos/units; condo is synchronized when a unit is assigned.
	- When a user's unit changes, related owner/member relationships are updated.

5. Unit member invitations / requests
	- House owners (or admins) can invite users to join a unit (create `UnitMemberRequest`).
	- Recipients can accept or decline.
	- Accepting creates a `UnitMember` and generates notifications for sender and recipient.

6. Facilities
	- CRUD for `Facility` (e.g. pool, meeting room, sports court).
	- Each facility stores an `availability_schedule` (JSON/JSONB): map of date/day -> list of timeslots.
	- The controller builds schedules from `availability_schedule_days` and `availability_schedule_times` passed from forms.

7. Bookings (timeslot reservations)
	- `Booking` stores `booking_time_slots` as a hash (date/day => list of time slot strings).
	- Workflow: a user creates a booking (status `pending`) → admin/operation_admin may `approve` or `reject`, or the user may `cancel`.
	- Validations:
	  - Ensure `booking_time_slots` format is correct (hash of arrays of strings).
	  - Verify bookings fall within the facility's `availability_schedule`.
	  - Prevent overlaps: no bookings may claim the same timeslot when another booking is `pending` or `approved`.
	- When a booking is created, its timeslots are temporarily removed from the facility schedule to avoid conflicts.
	- When a booking is cancelled, rejected, or destroyed, the timeslots are restored to the facility schedule.
	- `BookingConflictResolutionJob` (ActiveJob + Sidekiq) handles conflict resolution asynchronously.

8. Notifications
	- `Notification` model stores messages (status `unread`/`read`, category, polymorphic reference).
	- Notifications are created for important events: booking creation/status changes, unit invitations, accept/decline, etc.
	- Real-time broadcasting via `ActionCable`:
	  - User-specific notifications are broadcast to `notifications:USER_ID` channels.
	  - Admin notifications (e.g. new booking needs approval) are broadcast to admin channels.
	- Test endpoints available: `notifications#test_user_notification` and `notifications#test_admin_notification`.

9. Background jobs & admin UI
	- Sidekiq processes background jobs (e.g. conflict resolution).
	- Sidekiq Web UI is available at `/sidekiq`.
	- ActionCable is mounted at `/cable` for realtime websocket connections.

10. API / JSON endpoints
	- Several controllers support JSON responses for search / autocomplete (for example, `UnitsController#index` returns id/unit_number in JSON).
	- `Jbuilder` is included for JSON view templates if APIs are expanded.

11. Health check
	- A health check endpoint is available at `GET /up` which maps to `rails/health#show`.

## Main models
- User: manages user accounts, roles, and relations to condos and unit_members.
- Condo: building entity; has many units and facilities.
- Unit: apartment; has a house_owner and unit_members.
- UnitMember / UnitMemberRequest: membership relations and invitation requests.
- Facility: building facility with `availability_schedule` stored as JSONB.
- Booking: reservation for facility timeslots with states and callbacks to update availability.
- Notification: stores and broadcasts notifications.

## Main routes (summary)
- root: `GET /` → `static_pages#home`
- Devise routes for authentication
- `resources :condos`
- `resources :units`
- `resources :facilities`
- `resources :bookings`
- `resources :users, path: "members"`
- `resources :unit_member_requests` (member routes: `accept`, `decline`)
- `resources :unit_members` (create/destroy)
- `resources :notifications` (includes test endpoints)
- Sidekiq Web UI: `/sidekiq`
- ActionCable mount point: `/cable`

## Run the application (development) — basic steps
1. Install gems & node dependencies

```bash
bundle install
yarn install # if needed (project uses Yarn as package manager)
```

2. Setup the database

```bash
rails db:create db:migrate db:seed
```

3. Build CSS (Tailwind)

```bash
yarn build:css
# or
rails css:build
```

4. Run the server & sidekiq

```bash
# terminal 1
rails server

# terminal 2
bundle exec sidekiq
```

5. Access the app

- App: http://localhost:3000
- Sidekiq Web UI: http://localhost:3000/sidekiq

## Where to look in the codebase
- Policies (authorization): `app/policies`
- Controllers: `app/controllers`
- Models: `app/models`
- Channels / notification helpers: check `app/javascript` and `app/helpers/notification_helper.rb` (if present)

## Testing
- Test-related gems are in the `Gemfile` (Capybara, Selenium, FactoryBot, SimpleCov). Run tests with:

```bash
rails test
```





