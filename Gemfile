source 'https://rubygems.org'

# Declare your gem's dependencies in cohesive_admin.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]


group :development do
  gem "rails", '>= 6.0'

  # Refile
  gem 'refile', github: 'refile/refile', require: 'refile/rails'
  gem 'refile-mini_magick', github: 'refile/refile-mini_magick'
  gem 'sinatra', github: 'sinatra/sinatra', branch: 'master'

  # Shrine
  gem "shrine", '~> 2.2'
  gem 'image_processing'
  gem 'mini_magick'
  gem 'fastimage'

  gem 'web-console', '>= 3.4'
  gem 'rack'
end
