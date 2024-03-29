# frozen_string_literal: true

require "active_support/all"
require "dotenv/load"
require "mail"
require "net/http"
require "nokogiri"

class ScrapeNotifyCelebrate
  CELEBRATE_BASE_URI = "https://nationaldaycalendar.com/"
  NBSP = [160].pack('U*')
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
    "a lovely",
    "a most fortuitous",
    "a glimmering, shimmering",
    "an elegant",
    "a wondrous",
    "a gorgeous",
    "an insightful",
    "an adventurous",
    "a captivating",
    "a spicy",
    "a bodacious",
    "a merry",
    "an absurd",
    "an exquisite",
    "an arcadian",
    "a magnanimous"
  ].freeze

  def self.perform(args)
    new(args).perform
  end

  def initialize(args)
    @celebratory_email_addresses = args[:email_addresses]
    @admin_email_address = args[:admin_email_address]
    @current_time = Time.current.in_time_zone("Mountain Time (US & Canada)")
  end

  def perform
    subject_text_local = subject_text
    body_text_local = body_text

    email_address_list.each do |email_address|
      mail = Mail.new do
        from "Magical Celebration Fairy"
        to email_address
        subject subject_text_local
        body body_text_local
      end

      puts "Sending mail to #{email_address}"
      mail.charset = "UTF-8"
      mail.deliver!
    end
  end

  private

  attr_reader :celebratory_email_addresses, :admin_email_address, :current_time

  def email_address_list
    fairy_is_broken? ? [admin_email_address] : celebratory_email_addresses
  end

  def subject_text
    fairy_is_broken? ? "Hey I need some attention" : "Start your day with a celebration"
  end

  def body_text
    if fairy_is_broken?
      <<~BODY
        The Fairy didn't find any days today, which probably means she's broken.
      BODY
    else
      <<~BODY
        The Fairy has discovered that today is a special day! Today is: #{days_to_celebrate.to_sentence}.

        Have #{adjective} day!
      BODY
    end
  end

  def fairy_is_broken?
    days_to_celebrate.empty?
  end

  def adjective
    FAIRY_ADJECTIVES.sample
  end

  def days_to_celebrate
    @days_to_celebrate ||= list_items.map { |item| item.css("a")&.text }.select(&:present?)
  end

  def list_items
    p_element = parent_div.css("p:contains('#{month_and_day}')").first || parent_div.css("p:contains('#{nbsp_month_and_day}')").first
    days_list = p_element.next_element
    days_list.css("li")
  end

  def parent_div
    html.css("#et-boc").presence || html.css("main")
  end

  def html
    celebrate_uri = URI("#{CELEBRATE_BASE_URI}#{current_month.downcase}/")
    html_text = Net::HTTP.get(celebrate_uri)
    Nokogiri::HTML(html_text)
  end

  def month_and_day
    "#{current_month} #{current_time.day}"
  end

  def nbsp_month_and_day
    "#{current_month}#{NBSP}#{current_time.day}"
  end

  def current_month
    current_time.strftime("%B")
  end
end
