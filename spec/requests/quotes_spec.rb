require "rails_helper"

RSpec.describe "Quotes", type: :request do
  let(:partner) { create(:partner) }
  let(:user) { create(:user, partner: partner) }

  before do
    sign_in user
  end

  describe "GET /quotes" do
    it "lists quotes for the current user's partner" do
      visible_quote = create(:quote, partner: partner, created_by: user, name: "Visible quote")
      hidden_quote = create(:quote, name: "Hidden quote")

      get quotes_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(visible_quote.name)
      expect(response.body).not_to include(hidden_quote.name)
    end
  end

  describe "GET /quotes/:id" do
    it "shows a partner quote" do
      quote = create(:quote, partner: partner, created_by: user)

      get quote_path(quote)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(quote.name)
    end

    it "returns not found for a quote from another partner" do
      other_quote = create(:quote)

      get quote_path(other_quote)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /quotes" do
    it "creates a quote through the turbo stream endpoint" do
      expect do
        post quotes_path(format: :turbo_stream),
             params: { quote: { name: "New quote" } },
             headers: turbo_stream_headers
      end.to change(Quote, :count).by(1)

      quote = Quote.order(:id).last
      expect(response).to have_http_status(:ok)
      expect(quote.partner).to eq(partner)
      expect(quote.created_by).to eq(user)
      expect(quote.name).to eq("New quote")
      expect(quote).to be_in_draft
    end

    it "returns unprocessable entity for invalid params" do
      expect do
        post quotes_path(format: :turbo_stream),
             params: { quote: { name: "" } },
             headers: turbo_stream_headers
      end.not_to change(Quote, :count)

      expect(response).to have_http_status(422)
    end
  end

  describe "GET /quotes/:id/edit" do
    it "renders the edit turbo stream for a draft quote" do
      quote = create(:quote, partner: partner, created_by: user)

      get edit_quote_path(quote, format: :turbo_stream), headers: turbo_stream_headers

      expect(response).to have_http_status(:ok)
    end

    it "returns forbidden for a validated quote" do
      quote = create(:quote, :validated, partner: partner, created_by: user)

      get edit_quote_path(quote, format: :turbo_stream), headers: turbo_stream_headers

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /quotes/:id" do
    it "updates a draft quote" do
      quote = create(:quote, partner: partner, created_by: user, name: "Before")

      patch quote_path(quote, format: :turbo_stream),
            params: { quote: { name: "After" } },
            headers: turbo_stream_headers

      expect(response).to have_http_status(:ok)
      expect(quote.reload.name).to eq("After")
    end

    it "returns unprocessable entity for invalid updates" do
      quote = create(:quote, partner: partner, created_by: user)

      patch quote_path(quote, format: :turbo_stream),
            params: { quote: { name: "" } },
            headers: turbo_stream_headers

      expect(response).to have_http_status(422)
      expect(quote.reload.name).not_to eq("")
    end

    it "returns forbidden for a validated quote" do
      quote = create(:quote, :validated, partner: partner, created_by: user)

      patch quote_path(quote, format: :turbo_stream),
            params: { quote: { name: "After" } },
            headers: turbo_stream_headers

      expect(response).to have_http_status(:forbidden)
      expect(quote.reload.name).not_to eq("After")
    end
  end

  describe "DELETE /quotes/:id" do
    it "destroys a draft quote" do
      quote = create(:quote, partner: partner, created_by: user)
      create(:quote_item, quote: quote)

      expect do
        delete quote_path(quote, format: :turbo_stream), headers: turbo_stream_headers
      end.to change(Quote, :count).by(-1)
        .and change(QuoteItem, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end

    it "returns forbidden for a validated quote" do
      quote = create(:quote, :validated, partner: partner, created_by: user)

      expect do
        delete quote_path(quote, format: :turbo_stream), headers: turbo_stream_headers
      end.not_to change(Quote, :count)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /quotes/:id/validate_quote" do
    it "validates a draft quote with items" do
      quote = create(:quote, partner: partner, created_by: user)
      create(:quote_item, quote: quote)

      patch validate_quote_quote_path(quote)

      expect(response).to redirect_to(quote_path(quote))
      expect(quote.reload).to be_validated
    end

    it "does not validate a quote without items" do
      quote = create(:quote, partner: partner, created_by: user)

      patch validate_quote_quote_path(quote)

      expect(response).to redirect_to(quote_path(quote))
      expect(quote.reload).to be_in_draft
    end
  end
end
