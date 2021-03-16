# frozen_string_literal: true

require "dotenv/load"
require "mail"
require "nokogiri"
require "net/http"

class ScrapeNotifyCelebrate
  CELEBRATE_URI = URI("https://nationaldaycalendar.com/what-day-is-it/")

  def self.perform(args)
    email_addresses = args[:email_addresses]
    email_from = ENV["SN_EMAIL_FROM"]
    password = ENV["SN_PASSWORD"]

    html_text = Net::HTTP.get(CELEBRATE_URI)
    html = Nokogiri::HTML(html_text)
    parent_div = html.at_css('[id="evcal_list"]')
    text_spans = parent_div.css(".evcal_desc2")

    days_to_celebrate = text_spans.map(&:text)

    days_to_celebrate.each { |day| pp day }

    # email_addresses.each do |email_address|
    #   mail_options = { address: "smtp.gmail.com",
    #                    port: 587,
    #                    domain: "opensplittime.org",
    #                    user_name: email_from,
    #                    password: password,
    #                    authentication: "plain",
    #                    enable_starttls_auto: true }
    #   Mail.defaults { delivery_method :smtp, mail_options }
    #
    #   subject = "scrape-notify #{found_or_not} a match for #{search_text} at #{uri.host}"
    #
    #   mail = Mail.new do
    #     from email_from
    #     to email_address
    #     subject subject
    #     body "#{uri.host} responded with: \n\n#{response_text}"
    #   end
    #
    #   mail.deliver!
    # end
  end
end

ScrapeNotifyCelebrate.perform({})
