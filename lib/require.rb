require 'yaml'
require 'ikku'
require 'json'
require 'mongo'
require 'redis'
require 'discordrb'
require_relative './ikku.rb'

config = YAML.load_file(File.expand_path('../config.yml', __dir__))
mongo = Mongo::Client.new(["#{config['mongo']['db_host']}:#{config['mongo']['db_port']}"], database: config['mongo']['db'])
@redis = Redis.new(host: config['redis']['db_host'], port: config['redis']['db_port'])
@bot = Discordrb::Commands::CommandBot.new token: config['discord']['token'], client_id: config['discord']['client_id'], prefix: config['discord']['prefix']
@collection = mongo[:ikku]
@config = config
