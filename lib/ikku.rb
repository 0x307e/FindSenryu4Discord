require_relative './require.rb'

def senryu(event)
  senryureviewer = Ikku::Reviewer.new
  senryu = senryureviewer.find(event.content)
  if senryu
    data = {
      type: 'senryu',
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
    @collection.insert_one(data) if @collection.find('sentence' => data[:sentence])
    @collection.insert_one(data) if @collection.find('sentence' => data[:sentence])
    data
  else
    return
  end
end
