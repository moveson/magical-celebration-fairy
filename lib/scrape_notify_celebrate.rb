# frozen_string_literal: true

require "active_support/all"
require "dotenv/load"
require "mail"
require "net/http"
require "nokogiri"

class ScrapeNotifyCelebrate
  CELEBRATE_BASE_URI = "https://nationaldaycalendar.com/"
  FAIRY_ADJECTIVES = [
    "a magical",
    "a fantastical",
    "a marvelous",
    "a magnificent",
    "a sparkling",
    "a dazzling",
    "an enchanting",
    "a miraculous",
    "an extraordinary",
    "a heavenly",
    "a stupendous",
    "a brilliant",
    "a sensational",
    "a most unusual",
  ].freeze

  def self.perform(args)
    email_addresses = args[:email_addresses]
    admin_email_address = ENV["MCF_ADMIN_EMAIL_TO"]
    email_from = ENV["MCF_EMAIL_FROM"]
    password = ENV["MCF_PASSWORD"]
    current_month = Time.current.strftime("%B")
    celebrate_uri = URI("#{CELEBRATE_BASE_URI}#{current_month.downcase}/")

    html_text = Net::HTTP.get(celebrate_uri)
    html = Nokogiri::HTML(html_text)
    parent_div = html.css("#et-boc")

    ordinalized_day = "#{current_month} #{Time.current.day.ordinalize}"
    p_element = parent_div.css("p:contains('#{ordinalized_day}hello')").first
    days_list = p_element.next_element
    list_items = days_list.css("li")

    days_to_celebrate = list_items.map { |item| item.css("a").text }
    fairy_is_broken = days_to_celebrate.empty?

    mail_options = { address: "smtp.gmail.com",
                     port: 587,
                     domain: "gmail.com",
                     user_name: email_from,
                     password: password,
                     authentication: "plain",
                     enable_starttls_auto: true }

    Mail.defaults { delivery_method :smtp, mail_options }

    if fairy_is_broken
      subject = "Hey I need some attention"

      mail = Mail.new do
        from "Magical Celebration Fairy"
        to admin_email_address
        subject subject
        body <<~BODY
          The Fairy didn't find any days today, which probably means she's broken.
        BODY
      end

      mail.deliver!
    else
      adjective = FAIRY_ADJECTIVES.sample

      email_addresses.each do |email_address|
        subject = "Start your day with a celebration"

        mail = Mail.new do
          from "Magical Celebration Fairy"
          to email_address
          subject subject
          body <<~BODY
            The Fairy has discovered that today is a special day! Today is: #{days_to_celebrate.to_sentence}.

            Have #{adjective} day!
          BODY
        end

        mail.deliver!
      end
    end
  end
end
