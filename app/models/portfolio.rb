class Portfolio < ApplicationRecord
    has_many :portfolio_stocks, dependent: :destroy
    has_many :portfolio_stock_aims, dependent: :destroy
end
