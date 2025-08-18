# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "jquery", integrity: "sha384-VlCj71LMLSNZ5b0MVT7pm3f5SZxz5s4bLP01b0r/ARBJcDvR7c04QjppG5nvye9m" # @3.7.1
pin "@rails/actioncable", to: "actioncable.esm.js"
pin_all_from "app/javascript/channels", under: "channels"
pin "notification_manager", to: "notification_manager.js"
