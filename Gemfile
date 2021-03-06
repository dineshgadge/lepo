source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'autosize', '~> 2.4'
gem 'bootstrap', '~> 4.0.0.alpha6.0'
# gem "chartkick"
gem 'coffee-rails', '~> 4.2.0'
gem 'font-awesome-rails', '~> 4.7'
gem 'http_accept_language', '~> 2.1.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
gem 'jquery-hotkeys-rails', '~> 0.7.9'
gem 'jquery-rails', '~> 4.2.0'
gem 'jquery-ui-rails', '~> 6.0.0'
gem 'net-ldap', '~> 0.16.0'
gem 'paperclip', '~> 5.1.0'
gem 'rails', '~> 5.0.4'
gem 'rails-assets-tether', '~> 1.1'
gem 'rails_autolink'
gem 'remotipart', '~> 1.3.1'
# FIXME: PushNotification
gem 'rest-client', '~> 2.0.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 3.0.0'

group :development, :test do
  gem 'sqlite3', '~> 1.3.0'
end

group :development do
  gem 'annotate', '~> 2.7.0'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'i18n_generators', '~> 2.1'
  gem 'listen', '~> 3.0.5'
  # meta_request is necessary for rails_panel chrome extension
  gem 'meta_request'
  gem 'rubocop', require: false
  gem 'scss_lint', require: false
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '~> 2.14'
  gem 'chromedriver-helper'
  gem 'database_cleaner', '~> 1.6'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'minitest-capybara'
  gem 'selenium-webdriver', '~> 3.4'
end

group :production do
  gem 'mysql2', '~> 0.4.0'
  # Use Puma as the app server
  # gem 'puma', '~> 3.0'
  # Use Unicorn as the app server
  gem 'unicorn', '~> 5.2.0'
end
