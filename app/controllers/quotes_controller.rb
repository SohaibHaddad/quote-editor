class QuotesController < ApplicationController
  before_action :set_quote, only: [:show, :edit, :update, :destroy, :validate_quote, :cancel_edit]
  before_action :load_quotes, only: [:index, :destroy]
  before_action :ensure_quote_is_editable, only: [:edit, :update, :destroy, :cancel_edit]

  def index
    @quote = Quote.new
  end

  def new
    @quote = current_user.partner.quotes.new
    @quote.created_by = current_user

    respond_to do |format|
      format.turbo_stream
    end
  end

  # This restores the inline "new quote" row in place with Turbo instead of
  # navigating back to /quotes. A full page reload would reset the scroll
  # position, which creates a poor user experience because the user loses
  # their place in the table after cancelling the inline form.
  def cancel_new
    respond_to do |format|
      format.turbo_stream
    end
  end

  def create
    @quote = current_user.partner.quotes.new(quote_params)
    @quote.created_by = current_user

    if @quote.save
      @quotes_count = current_user.partner.quotes.count

      respond_to do |format|
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.turbo_stream { render :create, status: :unprocessable_entity }
      end
    end
  end

  def show
    @quote_items = @quote.quote_items.order(:id)
    @quote_item = @quote.quote_items.new
  end

  def edit
    respond_to do |format|
      format.turbo_stream
    end
  end

  def update
    if @quote.update(quote_params)
      respond_to do |format|
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.turbo_stream { render :update, status: :unprocessable_entity }
      end
    end
  end

  # This restores the inline edit row in place with Turbo instead of
  # navigating back to /quotes. A full page reload would reset the scroll
  # position, which creates a poor user experience because the user loses
  # their place in the table after cancelling the inline form.
  def cancel_edit
    respond_to do |format|
      format.turbo_stream
    end
  end

  def destroy
    @quote.destroy
    load_quotes

    respond_to do |format|
      format.turbo_stream
    end
  end

  def validate_quote
    @quote.validate_quote
    @quote.save

    redirect_to quote_path(@quote)
  end

  private

  def load_quotes
    @quotes = current_user.partner.quotes
      .includes(:partner, :created_by, :quote_items)
      .order(id: :desc)
  end

  def set_quote
    @quote = current_user.partner.quotes.includes(:created_by, :quote_items).find(params[:id])
  end

  def quote_params
    params.require(:quote).permit(:name)
  end

  def ensure_quote_is_editable
    head :forbidden if @quote.validated?
  end
end
