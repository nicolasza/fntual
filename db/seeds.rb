# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# primero genero un listado de stocks con sus precios
stocks = [ [ "Apple", 150.00 ], [ "Google", 2800.00 ], [ "Amazon", 3400.00 ], [ "Microsoft", 300.00 ], [ "Tesla", 700.00 ] ].map do |name, price|
  Stock.find_or_create_by!(identifier: name) do |stock|
    stock.price = price
  end
end

# creo listado de portafolios con distintos stocks y cantidades, tambien defino sus aims con los porcentajes
portfolios = [
    { name: "Tech Giants", stocks: { stocks[0] => 10, stocks[1] => 5, stocks[2] => 3 }, aims: { stocks[0] => 50, stocks[1] => 30, stocks[2] => 20 } },
    { name: "E-commerce Leaders", stocks: { stocks[2] => 8, stocks[3] => 4 }, aims: { stocks[2] => 60, stocks[3] => 40 } },
    { name: "Electric Vehicles", stocks: { stocks[4] => 15 }, aims: { stocks[4] => 100 } },
    { name: "Mixed Portfolio", stocks: { stocks[0] => 5, stocks[1] => 3, stocks[2] => 2, stocks[3] => 4, stocks[4] => 6 }, aims: { stocks[0] => 25, stocks[1] => 25, stocks[2] => 20, stocks[3] => 15, stocks[4] => 15 } }
].each do |portfolio_data|
    portfolio = Portfolio.create!(name: portfolio_data[:name])
    # Agregar stocks al portafolio
    portfolio_data[:stocks].each do |stock, quantity|
        portfolio.portfolio_stocks.create!(stock: stock, quantity: quantity)
    end
    # Agregar aims al portafolio
    portfolio_data[:aims].each do |stock, percentage|
        portfolio.portfolio_stock_aims.create!(stock: stock, percentage: percentage)
    end
    end
