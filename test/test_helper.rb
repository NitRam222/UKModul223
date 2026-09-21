ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Helper method to log in a user during integration / controller tests
    def sign_in_as(user, password = "password123")
      post login_path, params: { email: user.email, password: password }
    end

    def sign_out
      delete logout_path
    end
  end
end
