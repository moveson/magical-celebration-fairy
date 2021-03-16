require_relative "../lib/scrape_notify"

RSpec.describe ScrapeNotify do
  describe ".perform" do
    let(:args) { {url: url, dom_element: dom_element, search_text: search_text, notify_on: notify_on, email_to: email_to} }

    context "when the search_text is available at the given domain and notify_on: :matched" do
      let(:url) { "https://example.com" }
      let(:dom_element) { "h1" }
      let(:search_text) { "Example Domain" }
      let(:notify_on) { :matched }
      let(:email_to) { nil }

      it "sends an email" do
        mail_response = ScrapeNotify.perform(args)
        expect(mail_response).to be_a(Mail::Message)
      end
    end

    context "when the search_text is not available at the given domain and notify_on: :matched" do
      let(:url) { "https://example.com" }
      let(:dom_element) { "h1" }
      let(:search_text) { "Nonexistent text" }
      let(:notify_on) { :matched }
      let(:email_to) { nil }

      it "does not send an email and returns nil" do
        mail_response = ScrapeNotify.perform(args)
        expect(mail_response).to be_nil
      end
    end

    context "when the search_text is not available at the given domain and notify_on: :not_matched" do
      let(:url) { "https://example.com" }
      let(:dom_element) { "h1" }
      let(:search_text) { "Nonexistent text" }
      let(:notify_on) { :not_matched }
      let(:email_to) { nil }

      it "sends an email" do
        mail_response = ScrapeNotify.perform(args)
        expect(mail_response).to be_a(Mail::Message)
      end
    end

    context "when the search_text is available at the given domain and notify_on: :not_matched" do
      let(:url) { "https://example.com" }
      let(:dom_element) { "h1" }
      let(:search_text) { "Example Domain" }
      let(:notify_on) { :not_matched }
      let(:email_to) { nil }

      it "does not send an email and returns nil" do
        mail_response = ScrapeNotify.perform(args)
        expect(mail_response).to be_nil
      end
    end
  end
end
