require_relative './require'

class Senryu
  include Mongoid::Document
  field :id, type: String
  field :sentence, type: Object
  field :author_id, type: String
  field :author_name, type: String
  field :server_id, type: String
  field :server_name, type: String
end
