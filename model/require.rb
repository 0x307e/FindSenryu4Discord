require 'mongoid'
Mongoid.load!(File.expand_path('../mongoid.yml', __dir__), :development)
Mongoid.load!(File.expand_path('../mongoid.yml', __dir__), :test) if ENV['CI']
