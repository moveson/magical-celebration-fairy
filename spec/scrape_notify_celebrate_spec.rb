# frozen_string_literal: true

require_relative "../lib/scrape_notify_celebrate"
require "active_support/all"
require "active_support/testing/time_helpers"

RSpec.describe ScrapeNotifyCelebrate do
  include ::ActiveSupport::Testing::TimeHelpers
  include ::Mail::Matchers

  before do
    ::Mail::TestMailer.deliveries.clear
    travel_to test_date
    allow(::Net::HTTP).to receive(:get).and_return(stubbed_html)
    described_class.perform(email_addresses: email_addresses, admin_email_address: admin_email_address)
  end

  describe ".perform" do
    let(:stubbed_html) { IO.read("spec/fixtures/april_2021.html") }
    let(:email_addresses) { %w[email_1@example.com email_2@example.com] }
    let(:admin_email_address) { "admin@example.com" }
    let(:deliveries) { ::Mail::TestMailer.deliveries }

    context "when the test date includes celebration days" do
      let(:test_date) { "2021-04-24".to_date }
      let(:expected_body) do
        "The Fairy has discovered that today is a special day! Today is: National Pigs in a Blanket Day, National Kiss of Hope Day, National Pool Opening Day, National Rebuilding Day, and National Sense of Smell Day."
      end

      it "sends emails to the list" do
        expect(deliveries.count).to eq(2)
        expect(deliveries.map(&:to).flatten).to match_array(email_addresses)
      end

      it "sets subject and body as expected" do
        expect(deliveries.first.subject).to eq("Start your day with a celebration")
        expect(deliveries.first.body.raw_source).to include(expected_body)
      end
    end

    context "when the test date includes a blank list item" do
      let(:test_date) { "2021-04-25".to_date }
      let(:expected_body) do
        "The Fairy has discovered that today is a special day! Today is: National DNA Day, National East Meets West Day, National Hug a Plumber Day, National Telephone Day, National Zucchini Bread Day, and National Pet Parents Day."
      end

      it "sets subject and body as expected" do
        expect(deliveries.first.subject).to eq("Start your day with a celebration")
        expect(deliveries.first.body.raw_source).to include(expected_body)
      end
    end

    context "when the html dates are not ordinalized" do
      let(:stubbed_html) { IO.read("spec/fixtures/april_2021_non_ordinalized.html") }

      context "when the date is a single digit included in later dates (1, 2, or 3)" do
        let(:test_date) { "2021-04-2".to_date }
        let(:expected_body) do
          "The Fairy has discovered that today is a special day! Today is: April Seconds Day and National Two Cents Day."
        end

        it "sets subject and body as expected" do
          expect(deliveries.first.subject).to eq("Start your day with a celebration")
          expect(deliveries.first.body.raw_source).to include(expected_body)
        end
      end

      context "when the date is a double-digit date" do
        let(:test_date) { "2021-04-24".to_date }
        let(:expected_body) do
          "The Fairy has discovered that today is a special day! Today is: National Pigs in a Blanket Day, National Kiss of Hope Day, National Pool Opening Day, National Rebuilding Day, and National Sense of Smell Day."
        end

        it "sets subject and body as expected" do
          expect(deliveries.first.subject).to eq("Start your day with a celebration")
          expect(deliveries.first.body.raw_source).to include(expected_body)
        end
      end
    end
  end
end
