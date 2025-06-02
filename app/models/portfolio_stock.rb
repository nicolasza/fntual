class PortfolioStock < ApplicationRecord
    belongs_to :Portfolio
    belongs_to :Stock
end
