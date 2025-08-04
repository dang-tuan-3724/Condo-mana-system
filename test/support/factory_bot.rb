# test/support/factory_bot.rb
require "factory_bot_rails"

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
end
