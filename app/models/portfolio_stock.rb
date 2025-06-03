class PortfolioStock < ApplicationRecord
    belongs_to :portfolio
    belongs_to :stock

    validates :quantity, presence: true
end
