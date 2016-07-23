class Lead
  include Mongoid::Document
  field :company_name, type: String
  field :source, type: String
  field :vendor_category, type: String
  field :message_used, type: String
  field :email_used, type: String
  field :response_received, type: Boolean
  field :sent_on, type: DateTime
end