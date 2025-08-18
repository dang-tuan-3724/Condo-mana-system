require "simplecov"
SimpleCov.start "rails" do
  add_filter "/config/" # Loại bỏ các thư mục không cần đo
  add_filter "/vendor/"
  minimum_coverage 85 #
end
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "support/factory_bot"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
    include FactoryBot::Syntax::Methods
    # Add more helper methods to be used by all tests here...
  end
end
