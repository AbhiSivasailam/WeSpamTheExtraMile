require 'infra/redshift_manager'

class HarrassmentManager
	def self.get_records_from_prospect_db(query)
		records = RedshiftManager.query(query)
		records.each do |record|
			Lead.create!(record)
		end
	end

	def self.send_to_ww(batch_size=1000)
		driver = Selenium::WebDriver.for :chrome

		leads = Lead.where(:sent.ne => true).limit(batch_size).shuffle

		leads.each do |lead|
			begin

				client_params = generate_random_params

				driver.navigate.to lead[:source]

				wait = Selenium::WebDriver::Wait.new(:timeout => 10)

				driver.find_element(:class, "testing-first-name").send_keys(client_params[:first_name])

				driver.find_element(:class, "testing-last-name").send_keys(client_params[:last_name])

				driver.find_element(:class, "testing-email").send_keys(client_params[:user])

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

	def self.generate_random_params()
		client_params = {}
		num_clients = Client.count
		
		client_params[:first_name] = Client.skip(rand(num_clients)).first.first_name
		client_params[:last_name] = Client.skip(rand(num_clients)).first.last_name
		client_params[:user] = Client.skip(rand(num_clients)).first.user
		return client_params
	end
end