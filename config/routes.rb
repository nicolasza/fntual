Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"


  # ruta por defecto
  root "portfolios#index"

  # #RUTAS DE PORTFOLIOS
  # ruta de portafolios
  get "/portfolios", to: "portfolios#index"
  # ruta de creacion de un nuevo portafolio
  get "/portfolios/new", to: "portfolios#new", as: "new_portfolio"
  # ruta para ver un portafolio específico
  get "/portfolios/:id", to: "portfolios#show", as: "portfolio"
  # ruta para reequilibrar un portafolio
  post "/portfolios/:id/rebalance", to: "portfolios#rebalance", as: "rebalance"
  # ruta para reequilibrar un portafolio
  post "/portfolios/:id/rebalance_apply", to: "portfolios#rebalance_apply", as: "rebalance_apply"
  # ruta para crear un portafolio
  post "/portfolios", to: "portfolios#create"
  # ##RUTAS DE STOCKS
  # ruta de stocks
  get "/stocks", to: "stocks#index"
  # ruta de visualizacion de un stock
  get "/stocks/:id", to: "stocks#show", as: "stock"
  # ruta para crear un stock
  post "/stocks", to: "stocks#create", as: "new_stock"
  # ruta para editar un stock
  patch "/stocks/:id/edit", to: "stocks#edit", as: "edit_stock"
  # rutas de aims de stocks en portafolios
  get "/portfolios/:id/portfolio_stock_aims/new", to: "portfolios#newStockAim", as: "portfolio_stock_aims_new"
  delete "/portfolios/:id/portfolio_stock_aims/:stock_id", to: "portfolios#removeStockAim", as: "portfolio_stock_aim"
  post "/portfolios/:id/portfolio_stock_aims/", to: "portfolios#addStockAim", as: "portfolio_stock_aim_add"
  # rutas de stock en portafolios
  post "/portfolios/:id/portfolio_stocks/buy", to: "portfolios#portfolioStockBuy", as: "portfolio_stock_buy"
  post "/portfolios/:id/portfolio_stocks/sell", to: "portfolios#portfolioStockSell", as: "portfolio_stock_sell"
  delete "/portfolios/:id/portfolio_stocks/:stock_id", to: "portfolios#portfolioStockSellAll", as: "portfolio_stock_sell_all"
end
