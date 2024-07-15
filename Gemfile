source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1', '>= 6.1.7.8'
# Use PostgreSQL as the database for Active Record
gem 'pg', '~> 1.5', '>= 1.5.6'
# Use Puma as the app server
gem 'puma', '~> 5.6', '>= 5.6.8'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.4', '>= 5.4.4'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.16'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '~> 1.18', require: false

gem 'activeadmin', '~> 3.2.2'
gem 'active_model_serializers', '~> 0.10.14'
gem 'caxlsx', '~> 3.4', '>= 3.4.1'
gem 'clearance', '~> 2.7', '>= 2.7.2'
gem 'country_select', '~> 8.0'
gem 'exception_notification', '~> 4.5'
gem 'groupdate', '~> 6.2'
gem 'matrix', '~> 0.4.2'
gem 'prawn', '~> 2.5'
gem 'rack-cors', '~> 1.1', '>= 1.1.1'
gem 'rswag-api', '~> 2.8'
gem 'rswag-ui', '~> 2.8'
gem 'sidekiq', '~> 6.5', '>= 6.5.10'
gem 'sorted_set', '~> 1.0', '>= 1.0.3'
gem 'twilio-ruby', '~> 5.59.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'annotate', '~> 3.1', '>= 3.1.1'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'faker', '~> 2.23'
  gem 'htmlbeautifier', '~> 1.4', '>= 1.4.2'
  gem 'rexml', '~> 3.2', '>= 3.2.5'
  gem 'rspec-rails', '~> 5.0', '>= 5.0.2'
  gem 'rswag-specs', '~> 2.8'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'listen', '~> 3.8'
  gem 'rack-mini-profiler', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 4.1', '>= 4.1.1'
  # Capistrano deployment
  gem 'bullet', '~> 6.1', '>= 6.1.5'
  gem 'capistrano', '~> 3.16', require: false
  gem 'capistrano-bundler', '~> 2.0', '>= 2.0.1'
  gem 'capistrano-passenger', '~> 0.2.1'
  gem 'capistrano-rails', '~> 1.6', '>= 1.6.1', require: false
  gem 'capistrano-rvm', '~> 0.1.2'
  gem 'rubocop', '~> 1.44', '>= 1.44.1', require: false
  gem 'rubocop-rails', require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 3.38'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
