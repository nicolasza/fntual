class StockAction
    def initialize(action, stock, amount)
        @action = action
        @stock = stock
        @amount = amount
    end

    def action
        @action
    end

    def stock
        @stock
    end

    def amount
        @amount
    end
end
