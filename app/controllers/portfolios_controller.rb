class PortfoliosController < ApplicationController
  def index
    @portfolios = Portfolio.all.order(:id)
  end

  def show
    @portfolio = Portfolio.find(params[:id])
    # sumo los porcentajes de los aims
    @total_percentage = @portfolio.portfolio_stock_aims.sum(:percentage)
    # si es igual a 100, indicio booleano para no permitir agregar mas aims
    @is_full_aim = @total_percentage >= 100

    # obtengo el total de acciones en el portafolio de quantity por valor de stock
    @portfolio_stocks = @portfolio.portfolio_stocks.includes(:stock)
    # si el portafolio no tiene acciones, no se puede calcular el valor total
    @total_value = 0

    if @portfolio_stocks.any?
    @total_value = @portfolio_stocks.sum("quantity * stocks.price")
    end
    if flash[:rebalance].nil?
      flash[:rebalance] = [] # Inicializo el flash para evitar errores si no se ha reequilibrado
    end
  end

  def new
    @portfolio = Portfolio.new
  end

  def rebalance
    @portfolio = Portfolio.find(params[:id])
    @rebalance=@portfolio.rebalance
    # muestro los datos que retorna para ver si se ha reequilibrado correctamente
    flash[:rebalance] = @rebalance[0]
    if @rebalance[0].empty?
      flash[:notice] = @rebalance[1]
    else
      flash[:notice] = @rebalance[1]
    end
    # redirijo a la vista del portafolio
    redirect_to @portfolio
  end

  def rebalance_apply
    @portfolio = Portfolio.find(params[:id])
    @rebalance=@portfolio.rebalance
    # Recorro las acciones a comprar y vender
    @rebalance[0].each do |action|
      stock = action.stock
      amount = action.amount

      if action.action == "buy"
        # Llamo al metodo de compra de acciones del portafolio
        @portfolio.portfolioStockBuy(stock, amount)
      elsif action.action == "sell"
        # Llamo al metodo de venta de acciones del portafolio
        @portfolio.portfolioStockSell(stock.id, amount)
      end
    end

    flash[:notice] = "Balanceo del portafolio aplicado correctamente."
    redirect_to @portfolio and return
  end

  def create
    @portfolio = Portfolio.new(portfolio_params)
    if @portfolio.save
      redirect_to @portfolio
    else
      render :new, status: :unprocessable_entity
    end
  end


  def newStockAim
    @portfolio = Portfolio.find(params[:id])
    # sumo los porcentajes de los aims
    @total_percentage = @portfolio.portfolio_stock_aims.sum(:percentage)
    # si es igual a 100, indicio booleano para no permitir agregar mas aims
    @is_full_aim = @total_percentage >= 100
    if @is_full_aim
      flash[:error] = "El portafolio ya tiene el 100% de aims asignados."
      redirect_to @portfolio and return
    end
    # si es menor calculor el restante para limitar el porcentaje de los nuevos aims
    @remaining_percentage_aim = 100 - @total_percentage if @total_percentage < 100
  end

  def addStockAim
    @params2 = stockaim_params
    @portfolio = Portfolio.find(params[:id])

    # Verificar si el aim ya existe
    existing_aim = @portfolio.portfolio_stock_aims.find_by(stock_id: @params2[:stock_id])
    if existing_aim
      flash[:error] = "El objetivo para esta accion ya existe."
      redirect_to portfolio_stock_aims_new_path(@portfolio) and return
    end

    # Crear un nuevo aim
    aim = @portfolio.portfolio_stock_aims.create(@params2)
    if aim.save
      redirect_to @portfolio
    else
      flash[:error] = aim.errors.full_messages.to_sentence
      redirect_to @portfolio
    end
  end

  def removeStockAim
    @portfolio = Portfolio.find(params[:id])
    aim = @portfolio.portfolio_stock_aims.find_by(params[:stock_id])
    if aim
      aim.destroy
    else
      flash[:error] = "No se encontró un objetivo para esta accion."
    end
    redirect_to @portfolio
  end


  def portfolioStockBuy
    @params2 = stock_params
    @portfolio = Portfolio.find(params[:id])

    # busco stock
    stock = Stock.find_by(id: @params2[:stock_id])

    # verificar si el stock existe
    unless stock
      flash[:error] = "El stock no existe."
      return redirect_to @portfolio
    end
    # llamo funcion de compra de acciones del portafolio
    portfolio_stock = @portfolio.portfolioStockBuy(stock, @params2[:price].to_f)
    if portfolio_stock[0]
      flash[:notice] = portfolio_stock[1]
    else
      flash[:error] = portfolio_stock[1]
    end
    redirect_to @portfolio
  end

  def portfolioStockSell
    @params2 = stock_params
    @portfolio = Portfolio.find(params[:id])
    # llamo funcion de compra de acciones del portafolio
    portfolio_stock = @portfolio.portfolioStockSell(@params2[:stock_id], @params2[:price].to_f)

    if portfolio_stock[0]
      flash[:notice] = portfolio_stock[1]
    else
      flash[:error] = portfolio_stock[1]
    end
    redirect_to @portfolio
  end

  def portfolioStockSellAll
    @portfolio = Portfolio.find(params[:id])
    @portfolio_stock = @portfolio.portfolio_stocks.find_by(id: params[:stock_id])
    if @portfolio_stock
      # Eliminar todas las acciones del stock del portafolio
      @portfolio_stock.destroy
      flash[:notice] = "Todas las acciones del stock \""+@portfolio_stock.stock.identifier+"\" han sido vendidas."
    else
      flash[:error] = "No se encontró el stock en el portafolio."
    end
    redirect_to @portfolio
  end

  private
    def portfolio_params
      params.expect(portfolio: [ :name ])
    end
    def stockaim_params
      params.expect(portfolio_stock_aim: [ :stock_id, :percentage ])
    end
    def stock_params
      params.expect(stock: [ :stock_id, :price ])
    end
end
