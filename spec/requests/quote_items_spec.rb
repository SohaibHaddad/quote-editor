require "rails_helper"

RSpec.describe "QuoteItems", type: :request do
  let(:partner) { create(:partner) }
  let(:user) { create(:user, partner: partner) }
  let(:quote_record) { create(:quote, partner: partner, created_by: user) }

  before do
    sign_in user
  end

  describe "GET /quotes/:quote_id/quote_items/new" do
    it "renders the new turbo stream row for a draft quote" do
      get new_quote_quote_item_path(quote_record, format: :turbo_stream), headers: turbo_stream_headers

      expect(response).to have_http_status(:ok)
    end

    it "returns forbidden for a validated quote" do
      quote_record.update_column(:state, 1)

      get new_quote_quote_item_path(quote_record, format: :turbo_stream), headers: turbo_stream_headers

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /quotes/:quote_id/quote_items/cancel_new" do
    it "renders the new quote item row again for a draft quote" do
      get cancel_new_quote_quote_items_path(quote_record, format: :turbo_stream), headers: turbo_stream_headers

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq Mime[:turbo_stream].to_s
      expect(response.body).to include('target="new_quote_item_row"')
    end

    it "returns forbidden for a validated quote" do
      quote_record.update_column(:state, 1)

      get cancel_new_quote_quote_items_path(quote_record, format: :turbo_stream), headers: turbo_stream_headers

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /quotes/:quote_id/quote_items" do
    let(:params) do
      {
        quote_item: {
          name: "Lunch",
          quantity: 2,
          unit_price_before_tax_amount: "12.34",
          tax_rate: 20
        }
      }
    end

    it "creates a quote item and converts decimal amount input to cents" do
      expect do
        post quote_quote_items_path(quote_record, format: :turbo_stream),
             params: params,
             headers: turbo_stream_headers
      end.to change(quote_record.quote_items, :count).by(1)

      item = quote_record.quote_items.order(:id).last
      expect(response).to have_http_status(:ok)
      expect(item.unit_price_before_tax_in_cents).to eq(1234)
    end

    it "returns unprocessable entity for invalid params" do
      expect do
        post quote_quote_items_path(quote_record, format: :turbo_stream),
             params: { quote_item: { name: "", quantity: nil, unit_price_before_tax_amount: "", tax_rate: 20 } },
             headers: turbo_stream_headers
      end.not_to change(QuoteItem, :count)

      expect(response).to have_http_status(422)
    end

    it "returns forbidden for a validated quote" do
      quote_record.update_column(:state, 1)

      expect do
        post quote_quote_items_path(quote_record, format: :turbo_stream),
             params: params,
             headers: turbo_stream_headers
      end.not_to change(QuoteItem, :count)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /quotes/:quote_id/quote_items/:id/edit" do
    it "renders the edit turbo stream row for a draft quote" do
      quote_item = create(:quote_item, quote: quote_record)

      get edit_quote_quote_item_path(quote_record, quote_item, format: :turbo_stream), headers: turbo_stream_headers

      expect(response).to have_http_status(:ok)
    end

    it "returns forbidden for a validated quote" do
      quote_item = create(:quote_item, quote: quote_record)
      quote_record.update_column(:state, 1)

      get edit_quote_quote_item_path(quote_record, quote_item, format: :turbo_stream), headers: turbo_stream_headers

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /quotes/:quote_id/quote_items/:id/cancel_edit" do
    it "renders the quote item row again for a draft quote" do
      quote_item = create(:quote_item, quote: quote_record)

      get cancel_edit_quote_quote_item_path(quote_record, quote_item, format: :turbo_stream), headers: turbo_stream_headers

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq Mime[:turbo_stream].to_s
      expect(response.body).to include(%(target="#{ActionView::RecordIdentifier.dom_id(quote_item)}"))
    end

    it "returns forbidden for a validated quote" do
      quote_item = create(:quote_item, quote: quote_record)
      quote_record.update_column(:state, 1)

      get cancel_edit_quote_quote_item_path(quote_record, quote_item, format: :turbo_stream), headers: turbo_stream_headers

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /quotes/:quote_id/quote_items/:id" do
    it "updates a quote item" do
      quote_item = create(:quote_item, quote: quote_record, unit_price_before_tax_in_cents: 1000)

      patch quote_quote_item_path(quote_record, quote_item, format: :turbo_stream),
            params: {
              quote_item: {
                name: "Updated item",
                quantity: 3,
                unit_price_before_tax_amount: "15.50",
                tax_rate: 10
              }
            },
            headers: turbo_stream_headers

      expect(response).to have_http_status(:ok)
      expect(quote_item.reload.name).to eq("Updated item")
      expect(quote_item.quantity).to eq(3)
      expect(quote_item.unit_price_before_tax_in_cents).to eq(1550)
      expect(quote_item.tax_rate).to eq(10)
    end

    it "returns unprocessable entity for invalid params" do
      quote_item = create(:quote_item, quote: quote_record)

      patch quote_quote_item_path(quote_record, quote_item, format: :turbo_stream),
            params: {
              quote_item: {
                name: "",
                quantity: -1,
                unit_price_before_tax_amount: "",
                tax_rate: 200
              }
            },
            headers: turbo_stream_headers

      expect(response).to have_http_status(422)
    end

    it "returns forbidden for a validated quote" do
      quote_item = create(:quote_item, quote: quote_record)
      quote_record.update_column(:state, 1)

      patch quote_quote_item_path(quote_record, quote_item, format: :turbo_stream),
            params: { quote_item: { name: "Blocked", quantity: 1, unit_price_before_tax_amount: "10.00", tax_rate: 20 } },
            headers: turbo_stream_headers

      expect(response).to have_http_status(:forbidden)
      expect(quote_item.reload.name).not_to eq("Blocked")
    end
  end

  describe "DELETE /quotes/:quote_id/quote_items/:id" do
    it "destroys a quote item" do
      quote_item = create(:quote_item, quote: quote_record)

      expect do
        delete quote_quote_item_path(quote_record, quote_item, format: :turbo_stream), headers: turbo_stream_headers
      end.to change(QuoteItem, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end

    it "returns forbidden for a validated quote" do
      quote_item = create(:quote_item, quote: quote_record)
      quote_record.update_column(:state, 1)

      expect do
        delete quote_quote_item_path(quote_record, quote_item, format: :turbo_stream), headers: turbo_stream_headers
      end.not_to change(QuoteItem, :count)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
