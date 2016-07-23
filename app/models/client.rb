class Client
  include Mongoid::Document
  field :user, type: string
  field :first_name, type: string
  field :last_name, type: string
end