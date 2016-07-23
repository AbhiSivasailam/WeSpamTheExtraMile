class Client
  include Mongoid::Document
  field :user, type: String
  field :first_name, type: String
  field :last_name, type: String
end