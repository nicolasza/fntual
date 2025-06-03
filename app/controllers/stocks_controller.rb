class StocksController < ApplicationController
  def index
    @stocks = Stock.all
  end

  def create
    @stock = Stock.new(stock_params)
    if @stock.save
      redirect_to "/stocks"
    else
      flash[:errorCreate] = @stock.errors.full_messages.to_sentence
      redirect_to "/stocks"
    end
  end

  def edit
    @stock = Stock.find(params[:id])
    if @stock.update(stock_params)
      redirect_to "/stocks"
    else
      flash[:errorEdit] = @stock.errors.full_messages.to_sentence
      redirect_to "/stocks"
    end
  end


  private
    def stock_params
      params.expect(stock: [ :identifier, :price ])
    end

end
