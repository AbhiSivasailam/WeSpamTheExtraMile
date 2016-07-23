require 'infra/redshift_manager'

class HarrassmentManager
	def self.get_records_from_prospect_db(query)
		records = RedshiftManager.query(query || "SELECT vendor_category, source, company_name FROM prospect.prospect where vendor_category!='Venue' and source ILIKE '%weddingwir%'")
		records.each do |record|
			Lead.create!(record)
		end
	end

	def self.send_to_ww(batch_size=100)
		driver = Selenium::WebDriver.for :chrome

		leads = Lead.where(:sent.ne => true).limit(batch_size).shuffle

		leads.each do |lead|
			begin

				client = Client.skip(rand(Client.count)).first

				driver.navigate.to lead[:source]

				wait = Selenium::WebDriver::Wait.new(:timeout => 10)

				driver.find_element(:class, "testing-first-name").send_keys(client.first_name)

				driver.find_element(:class, "testing-last-name").send_keys(client.last_name)

				driver.find_element(:class, "testing-email").send_keys(client.user)

				calendar = driver.find_element(:class, "js-eventdate-picker")
				calendar.click

				12.times do
					cal_next = driver.find_element(:class, "next")
				end

				driver.find_element(:xpath, "//td[contains(text(), '30')]").click

				message = Message.skip(rand(Message.count)).first.message
				driver.find_element(:class, "testing-message-text").send_keys(message)

				submit = driver.find_element(:class, "testing-request-pricing").click
				lead.update!(:email_used => mailer.user, :message_used => message, :sent_on => DateTime.now, :response_received => false)
			rescue => e
				Rails.logger.info "#{lead['company_name']} failed bc #{e}"
			end
		end
	end
end