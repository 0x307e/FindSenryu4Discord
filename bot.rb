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

bot.command :rank do |event|
  unless event.server == nil
    # サーバーのとき
    rank = redis.zrevrange("server/#{event.server.id}/rank", 0, 3, withscores: true)
    ranks = []
    rank.each do |r|
      senryu = Senryu.where(author_id: r[0]).first
      ranks.push(
        score: r[1].to_i,
        author_name: senryu[:author_name],
        author_id: senryu[:author_id]
      )
    end
    event.send_embed do |embed|
      embed.title = "サーバー内ランキング"
      embed.colour = color()
      ranks.each.with_index(1) do |r, i|
        embed.add_field(
          name: "#{i}位: #{r[:score]}回",
          value: r[:author_name],
          inline: true
        )
      end
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: 'https://media.makotia.me/img/icons/haiku_bot.png')
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(
        text: 'This bot was made by makotia.',
        icon_url: 'https://media.makotia.me/img/icons/makotia.jpg'
      )
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(
        name: event.author.name,
        url: "https://discordapp.com/channels/@me/#{event.author.id}",
        icon_url: event.author.avatar_url.sub(/(.*)webp/m, '\1png')
      )
      embed.timestamp = Time.new
    end
  else
    # 個チャの場合
    rank = redis.zrevrange("user/#{event.author.id}/rank", 0, 3, withscores: true)
    ranks = []
    rank.each do |r|
      senryu = Senryu.where(server_id: r[0]).first
      ranks.push(
        score: r[1].to_i,
        server_name: senryu[:server_name],
        server_id: senryu[:server_id]
      )
    end
    event.send_embed do |embed|
      embed.title = "サーバーランキング"
      embed.colour = color()
      ranks.each.with_index(1) do |r, i|
        embed.add_field(
          name: "#{i}位: #{r[:score]}回",
          value: r[:server_name],
          inline: true
        )
      end
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: 'https://media.makotia.me/img/icons/haiku_bot.png')
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(
        text: 'This bot was made by makotia.',
        icon_url: 'https://media.makotia.me/img/icons/makotia.jpg'
      )
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(
        name: event.author.name,
        url: "https://discordapp.com/channels/@me/#{event.author.id}",
        icon_url: event.author.avatar_url
      )
      embed.timestamp = Time.new
    end
  end
end

bot.message do |event|
  author_id = event.author.id
  prefix = config['discord']['prefix']
  if author_id == !config['discord']['client_id']
    next
  elsif event.content =~ /#{prefix}.*/
    next
  elsif event.server == nil
    event.send_message('個チャはダメです')
  elsif event.content == '詠め'
    ikkus = []
    senryus = Senryu.where(server_id: event.server.id)
    kamigo_random = senryus[0..senryus.length].shuffle.shuffle.shuffle.sample
    nakashichi_random = senryus[0..senryus.length].shuffle.shuffle.shuffle.sample
    simogo_random = senryus[0..senryus.length].shuffle.shuffle.shuffle.sample
    authors = [kamigo_random[:author_name], nakashichi_random[:author_name], simogo_random[:author_name]]
    unless senryus.length == 0
      event.send_message("ここで一句\n「#{kamigo_random[:sentence][:kamigo]} #{nakashichi_random[:sentence][:nakashichi]} #{simogo_random[:sentence][:simogo]}」\n詠み手: #{authors.sort.uniq.join(', ')}")
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
