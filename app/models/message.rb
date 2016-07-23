class Message
  include Mongoid::Document
  field :text, type: string
end