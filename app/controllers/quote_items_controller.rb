class QuoteItemsController < ApplicationController
  before_action :set_quote
  before_action :ensure_quote_is_editable
  before_action :set_quote_item, only: [:edit, :update, :destroy]

  def new
    @quote_item = @quote.quote_items.new

    respond_to do |format|
      format.turbo_stream
    end
  end

  def create
    @quote_item = @quote.quote_items.new(quote_item_params)

    if @quote_item.save
      respond_to do |format|
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.turbo_stream { render :create, status: :unprocessable_entity }
      end
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream
    end
  end

  def update
    if @quote_item.update(quote_item_params)
      respond_to do |format|
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.turbo_stream { render :update, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @quote_item.destroy
    @quote.reload

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_quote
    @quote = current_user.partner.quotes.includes(:quote_items).find(params[:quote_id])
  end

  def set_quote_item
    @quote_item = @quote.quote_items.find(params[:id])
  end

  def quote_item_params
    params.require(:quote_item).permit(:name, :quantity, :tax_rate, :unit_price_before_tax_amount)
  end

  def ensure_quote_is_editable
    head :forbidden if @quote.validated?
  end
end
