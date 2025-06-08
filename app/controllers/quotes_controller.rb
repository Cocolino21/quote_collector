class QuotesController < ApplicationController
  before_action :set_quote, only: [:show, :edit, :update, :destroy]
  
  def index
    @quotes = Quote.all
    

    if params[:search].present?
      @quotes = @quotes.search(params[:search])
    end
    
    
    if params[:author].present?
      @quotes = @quotes.by_author(params[:author])
    end
    
   
    if params[:category].present?
      @quotes = @quotes.by_category(params[:category])
    end
    
    @quotes = @quotes.order(created_at: :desc)
    
    
    @authors = Quote.distinct.pluck(:author).compact.sort
    @categories = Quote.distinct.pluck(:category).compact.sort
  end
  
  def show
  end
  
  def new
    @quote = Quote.new
  end
  
  def create
    @quote = Quote.new(quote_params)
    
    if @quote.save
      redirect_to @quote, notice: 'Quote was successfully created.'
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @quote.update(quote_params)
      redirect_to @quote, notice: 'Quote was successfully updated.'
    else
      render :edit
    end
  end
  
  def destroy
    @quote.destroy
    redirect_to quotes_url, notice: 'Quote was successfully deleted.'
  end
  
  def random
    gemini_service = GeminiService.new
    quote_data = gemini_service.generate_random_quote
    
    @quote = Quote.new(
      content: quote_data[:content],
      author: quote_data[:author],
      category: quote_data[:category]
    )
    

    @quote.define_singleton_method(:ai_generated?) { true }
    
    render :show
  end
  
  private
  
  def set_quote
    @quote = Quote.find(params[:id])
  end
  
  def quote_params
    if params[:quote].present?
      params.require(:quote).permit(:content, :author, :category)
    else
      
      params.permit(:content, :author, :category).slice(:content, :author, :category)
    end
  end
end
