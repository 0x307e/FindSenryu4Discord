require 'yaml'
require 'ikku'
require 'json'
require 'mongo'
require 'discordrb'

config = YAML.load_file('config.yml')
db = Mongo::Client.new(["#{config['mongo']['db_host']}:#{config['mongo']['db_port']}"], database: config['mongo']['db'])
bot = Discordrb::Commands::CommandBot.new token: config['discord']['token'], client_id: config['discord']['client_id'], prefix: config['discord']['prefix']
@collection = db[:ikku]


def tanka(event)
  tankareviewer = Ikku::Reviewer.new(rule: [5, 7, 5, 7, 7])
  tanka = tankareviewer.find(event.content)
  if tanka
    data = {
      sentence: [
        tanka.phrases[0].join(""),
        tanka.phrases[1].join(""),
        tanka.phrases[2].join(""),
        tanka.phrases[3].join(""),
        tanka.phrases[4].join("")
      ],
      server: {
        id: event.server.id,
        name: event.server.name
      }
    }
    @collection.insert_one(data)
    data
  else
    return
  end
end

def senryu(event)
  senryureviewer = Ikku::Reviewer.new
  senryu = senryureviewer.find(event.content)
  if senryu
    data = {
      sentence: [
        senryu.phrases[0].join(""),
        senryu.phrases[1].join(""),
        senryu.phrases[2].join("")
      ],
      server: {
        id: event.server.id,
        name: event.server.name
      }
    }
    @collection.insert_one(data)
    data
  else
    return
  end
end

bot.ready do
  bot.game = '川柳&短歌検出'
end

bot.message do |event|
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
