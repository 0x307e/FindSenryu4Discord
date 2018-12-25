require 'yaml'
require 'ikku'
require 'json'
require 'mongo'
require 'discordrb'
require_relative './ikku.rb'

config = YAML.load_file(File.expand_path('../config.yml', __dir__))
db = Mongo::Client.new(["#{config['mongo']['db_host']}:#{config['mongo']['db_port']}"], database: config['mongo']['db'])
@bot = Discordrb::Commands::CommandBot.new token: config['discord']['token'], client_id: config['discord']['client_id'], prefix: config['discord']['prefix']
@collection = db[:ikku]
@config = config
