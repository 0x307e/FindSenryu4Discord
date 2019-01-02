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
    data
  else
    return
  end
end

def tanka(event)
  tankareviewer = Ikku::Reviewer.new(rule: [5, 7, 5, 7, 7])
  tanka = tankareviewer.find(event.content)
  if tanka
    data = {
      type: 'tanka',
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
    @collection.insert_one(data) if @collection.find('sentence' => data[:sentence])
    data
  else
    return
  end
end
