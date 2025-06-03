class StockAction

    def initialize(action, stock, quantity)
        @action = action
        @stock = stock
        @quantity = quantity
    end

    def action
        @action
    end

    def stock
        @stock
    end

    def quantity
        @quantity
    end
end