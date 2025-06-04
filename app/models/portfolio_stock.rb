class PortfolioStock < ApplicationRecord
    belongs_to :portfolio
    belongs_to :stock

    validates :quantity, presence: true

    def valorized_price
        (stock.price * quantity).round(1)
    end
end
