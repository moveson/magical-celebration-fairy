# frozen_string_literal: true

require "active_support/all"
require "dotenv/load"
require "mail"
require "net/http"
require "nokogiri"

class ScrapeNotifyCelebrate
  CELEBRATE_URI = URI("https://nationaldaycalendar.com/what-day-is-it/")

  def self.perform(args)
    email_addresses = args[:email_addresses]
    email_from = ENV["MCF_EMAIL_FROM"]
    password = ENV["MCF_PASSWORD"]

    html_text = Net::HTTP.get(CELEBRATE_URI)
    html = Nokogiri::HTML(html_text)
    parent_div = html.at_css('[id="evcal_list"]')
    text_spans = parent_div.css(".evcal_desc2")

    days_to_celebrate = text_spans.map { |span| span.text.titleize }

    email_addresses.each do |email_address|
      mail_options = { address: "smtp.gmail.com",
                       port: 587,
                       domain: "gmail.com",
                       user_name: email_from,
                       password: password,
                       authentication: "plain",
                       enable_starttls_auto: true }
      Mail.defaults { delivery_method :smtp, mail_options }

      subject = "Start your day with a celebration"

      mail = Mail.new do
        from "Magical Celebration Fairy"
        to email_address
        subject subject
        body <<~BODY
          The Fairy has discovered that today is a special day! Today is: #{days_to_celebrate.to_sentence}.

          Have a magical day!
        BODY
      end

      mail.deliver!
    end
  end
end
