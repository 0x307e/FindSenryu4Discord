require 'yaml'
require 'mongo'
require 'mongoid'
require 'securerandom'

require_relative '../model/senryu'

config = YAML.load_file(File.expand_path('../config.yml', __dir__))
mconfig = YAML.load_file(File.expand_path('../mongoid.yml', __dir__))
mongo = ''
if ENV['CI']
  Mongoid.load!(File.expand_path('../mongoid.yml', __dir__), :test)
  mongo = Mongo::Client.new([mconfig['test']['clients']['default']['hosts'][0]], database: mconfig['test']['clients']['default']['database'])
else
  Mongoid.load!(File.expand_path('../mongoid.yml', __dir__), :development)
  mongo = Mongo::Client.new([mconfig['development']['clients']['default']['hosts'][0]], database: mconfig['development']['clients']['default']['database'])
end
ikku = mongo[:ikku]

namespace :db do
  desc 'Database Migration'
  task :migrate do
    ikku.find({}).each do |i|
      if i[:type] == 'senryu'
        Senryu.create(
          id: SecureRandom.hex,
          sentence: {
            kamigo: i[:sentence][0],
            nakashichi: i[:sentence][1],
            simogo: i[:sentence][2]
          },
          server_id: i[:server][:id],
          server_name: i[:server][:name],
          author_id: config['discord']['client_id'],
          author_name: 'Migration'
        )
      end
    end
    ikku.drop
  end
end
