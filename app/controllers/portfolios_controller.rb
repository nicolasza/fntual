class PortfoliosController < ApplicationController


  def index
    @portfolios = Portfolio.all
  end

  def show
    @portfolio = Portfolio.find(params[:id])
    #sumo los porcentajes de los aims
    @total_percentage = @portfolio.portfolio_stock_aims.sum(:percentage)
    #si es igual a 100, indicio booleano para no permitir agregar mas aims
    @is_full_aim = @total_percentage >= 100
    #si es menor calculor el restante para limitar el porcentaje de los nuevos aims
    @remaining_percentage_aim = 100 - @total_percentage if @total_percentage < 100
  end

  def new
    @portfolio = Portfolio.new
  end

  def rebalance
    @portfolio = Portfolio.find(params[:id])
    @rebalance=@portfolio.rebalance
    #muestro los datos que retorna para ver si se ha reequilibrado correctamente
    flash[:rebalance] = @rebalance
    #redirijo a la vista del portafolio
    redirect_to @portfolio
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
    #sumo los porcentajes de los aims
    @total_percentage = @portfolio.portfolio_stock_aims.sum(:percentage)
    #si es igual a 100, indicio booleano para no permitir agregar mas aims
    @is_full_aim = @total_percentage >= 100
    if @is_full_aim
      flash[:error] = "El portafolio ya tiene el 100% de aims asignados."
      redirect_to @portfolio and return
    end
    #si es menor calculor el restante para limitar el porcentaje de los nuevos aims
    @remaining_percentage_aim = 100 - @total_percentage if @total_percentage < 100

  end

  def addStockAim
    @params2 = stockaim_params
    puts @params2[:stock_id]
    @portfolio = Portfolio.find(params[:id])
    # Verificar si el aim ya existe
    existing_aim = @portfolio.portfolio_stock_aims.find_by(stock_id:@params2[:stock_id])
    if existing_aim
      flash[:error] = "El aim para este stock ya existe."
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
      flash[:error] = "No se encontró un aim para este stock."
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

end
