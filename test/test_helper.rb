ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'
require 'capybara/minitest'
require 'database_cleaner'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  def assert_invalid(instance, property)
    assert instance.invalid?
    assert instance.errors.messages[property].any?
  end
end

class ActionDispatch::IntegrationTest
  # For all integration tests with FactoryGirl + Capybara + JS driver
  self.use_transactional_fixtures = false

  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  # Make `assert_*` methods behave like Minitest assertions
  include Capybara::Minitest::Assertions

  # Use chrome driver for Capybara
  Capybara.default_driver = :selenium
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  DatabaseCleaner.strategy = :truncation

  def setup
    # Database cleaner
    DatabaseCleaner.start
  end

  def teardown
    # Reset sessions and driver between tests
    Capybara.reset_sessions!
    Capybara.use_default_driver
    DatabaseCleaner.clean
  end

  def assert_invalid(instance, property)
    assert instance.invalid?
    assert instance.errors.messages[property].any?
  end

  def click_main_nav_item(link_text, assertion_selector)
    within('#main-nav') do
      click_on(link_text)
    end
    assert page.has_selector?(assertion_selector)
  end

  def signin_with(user_id, password)
    visit root_path
    within('#signin-form') do
      fill_in 'user_id', with: user_id
      fill_in 'password', with: password
      click_on 'signin-submit-btn'
    end
  end
end