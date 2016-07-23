class Message
  include Mongoid::Document
  field :text, type: String
end