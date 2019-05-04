def senryu(event)
  senryureviewer = Ikku::Reviewer.new
  senryu = senryureviewer.find(event.content)
  if senryu
    data = {
      id: SecureRandom.hex,
      sentence: {
        kamigo: senryu.phrases[0].join,
        nakashichi: senryu.phrases[1].join,
        simogo: senryu.phrases[2].join
      },
      author_id: event.author.id,
      author_name: event.author.name,
      server_id: event.server.id,
      server_name: event.server.name
    }
    Senryu.create(data)
    data
  else
    return
  end
end
