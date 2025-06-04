class Stock < ApplicationRecord
    validates :identifier, presence: true
    validates :price, presence: true

    def identifier_price
    "#{identifier} (#{price}$)"
    end

end
