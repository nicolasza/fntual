class PortfolioStockAim < ApplicationRecord
    belongs_to :portfolio
    belongs_to :stock

    validates :percentage, presence: true
end
