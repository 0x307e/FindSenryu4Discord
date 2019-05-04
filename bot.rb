require 'yaml'
require 'ikku'
require 'json'
require 'mongo'
require 'redis'
require 'discordrb'
require 'securerandom'

Dir.glob('lib/*').each { |r| require_relative r}
Dir.glob('model/*').each { |r| require_relative r}

config = YAML.load_file('config.yml')
redis = Redis.new(host: config['redis']['db_host'], port: config['redis']['db_port'])
bot = Discordrb::Commands::CommandBot.new token: config['discord']['token'], client_id: config['discord']['client_id'], prefix: config['discord']['prefix']

bot.ready do
  bot.game = '川柳&短歌検出'
end

bot.message do |event|
  author_id = event.author.id
  if author_id == !config['discord']['client_id']
    return
  elsif event.server == nil
    event.send_message('個チャはダメです')
  elsif event.content == '詠め'
    ikkus = []
    senryus = Senryu.where(server_id: event.server.id)
    kamigo = []
    nakashichi = []
    simogo = []
    author = []
    senryus.each do |row|
      kamigo.push(row[:sentence][:kamigo])
      nakashichi.push(row[:sentence][:nakashichi])
      simogo.push(row[:sentence][:simogo])
      author.push(row[:author_name])
    end
    unless author.length == 0
      event.send_message("ここで一句\n「#{kamigo.shuffle.shuffle.shuffle.sample} #{nakashichi.shuffle.shuffle.shuffle.sample} #{simogo.shuffle.shuffle.shuffle.sample}」\n詠み手: #{author.sort.uniq.join(', ')}")
    else
      event.send_message('先に誰か詠め')
    end
  elsif event.content == '詠むな'
    lp = redis.get("server/#{event.server.id}/last_poet")
    last_poet = Senryu.find(lp) unless lp == nil
    if last_poet == nil
      event.send_message('まだ誰も詠んでないぞ')
    elsif last_poet[:author_id].to_i == author_id.to_i
      event.send_message("<@#{author_id}> お前が「#{last_poet[:sentence].values.join(' ')}」と詠んだのが最後やぞ")
    else
      event.send_message("<@#{last_poet[:author_id]}> が「#{last_poet[:sentence].values.join(' ')}」と詠んだのが最後やぞ")
    end
  else
    senryu = senryu(event)
    if senryu
      event.channel.send_message("<@#{author_id}> 川柳を検出しました！\n「#{senryu[:sentence].values.join(' ')}」") if senryu
      redis.set("server/#{event.server.id}/last_poet", senryu[:id])
      redis.zincrby("server/#{event.server.id}/rank", 1, author_id)
      redis.zincrby("user/#{author_id}/rank", 1, event.server.id)
    end
  end
end

bot.run
