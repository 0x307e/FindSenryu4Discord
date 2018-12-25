require_relative './lib/require.rb'

bot = @bot

bot.ready do
  bot.game = '川柳&短歌検出'
end

bot.message do |event|
  config = @config
  author_id = event.author.id
  if author_id == !config['client_id']
    return
  elsif event.content == "詠め"
    ikkus = []
    @collection.find('server.id' => event.server.id).each { |row|
      ikkus.push(row['sentence'].join(' '))
    }
    event.send_message("ここで一句\n「#{ikkus.sample}」")
  elsif event.content == "詠むな"
    event.send_message("<@#{author_id}> 詠んでるのはお前やぞ")
  else
    senryu = senryu(event)
    if senryu
      event.channel.send_message("<@#{author_id}> 川柳を検出しました！\n「#{senryu[:sentence].join(' ')}」") if senryu
      tanka = tanka(event)
      if tanka
        event.channel.send_message("<@#{author_id}> 短歌を検出しました！\n「#{tanka[:sentence].join(' ')}」") if tanka
      end
    end
  end
end

bot.run
