require 'yaml'
require 'ikku'
require 'discordrb'

config = YAML.load_file('config.yml')
bot = Discordrb::Commands::CommandBot.new token: config['token'], client_id: config['client_id'], prefix: config['prefix']

bot.ready do
  bot.game = '川柳&短歌検出'
end

bot.message do |event|
  author_id = event.author.id
  if author_id == !config['client_id']
    return
  else
    senryureviewer = Ikku::Reviewer.new
    senryu = senryureviewer.find(event.content)
    tankareviewer = Ikku::Reviewer.new(rule: [5, 7, 5, 7, 7])
    tanka = tankareviewer.find(event.content)
    event.send_message("<@#{author_id}> 川柳を検出しました！\n「#{senryu.phrases[0].join("")} #{senryu.phrases[1].join("")} #{senryu.phrases[2].join("")}」") if senryu
    event.send_message("<@#{author_id}> 短歌を検出しました！\n「#{tanka.phrases[0].join("")} #{tanka.phrases[1].join("")} #{tanka.phrases[2].join("")} #{tanka.phrases[3].join("")} #{tanka.phrases[4].join("")}」") if tanka
  end
end

bot.run
