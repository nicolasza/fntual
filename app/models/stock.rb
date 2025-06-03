class Stock < ApplicationRecord
    validates :identifier, presence: true
    validates :price, presence: true
end
