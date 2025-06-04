class Portfolio < ApplicationRecord
    has_many :portfolio_stocks, dependent: :destroy
    has_many :portfolio_stock_aims, dependent: :destroy

    validates :name, presence: true

    def portfolioStockBuy(stock, price)
        # Verificar si el stock ya existe en el portafolio
        existing_stock = self.portfolio_stocks.find_by(stock_id: stock.id)
        if existing_stock
            # Si el stock ya existe, incrementar la cantidad segun el precio del stock
            existing_stock.quantity += price / stock.price
            if existing_stock.save!
                return true ,'Accion comprada y cantidad actualizada en el portafolio.'
            else
                return false, existing_stock.errors.full_messages.to_sentence
        end
        else
            # Si el stock no existe, crear una nueva entrada
            new_stock = self.portfolio_stocks.new(stock_id: stock.id, quantity: price / stock.price)
            if new_stock.save!
                return true, 'Accion comprada y agregada al portafolio.'
            else
                return false, new_stock.errors.full_messages.to_sentence
            end
        end

    end

    def portfolioStockSell(stock_id, price)

        # Verificar si el stock ya existe en el portafolio
        existing_stock = self.portfolio_stocks.find_by(stock_id: stock_id)
        if existing_stock
            @valorizado= existing_stock.quantity * existing_stock.stock.price
            # Si el stock ya existe, decrementar la cantidad
            if @valorizado >= price
                existing_stock.quantity -= price/ existing_stock.stock.price

                # si la cantidad llega a 0, eliminar el stock del portafolio
                if existing_stock.quantity == 0
                    existing_stock.destroy
                    return true, 'Accion vendida y eliminada del portafolio.'
                else
                    # Guardar los cambios en la cantidad del stock
                    if existing_stock.save!
                        return true,'Accion vendida y cantidad actualizada.'
                    else
                        return false, existing_stock.errors.full_messages.to_sentence
                    end
                end
            else
                return false, "No puedes vender más acciones de las que tienes."
            end
        else
            return false,"No se encontró el stock en el portafolio."
        end
    end

    def rebalance
        # metodo con la logica de rebalanceo,
        # esta funcion debe recorrer los stocks del portafolio, sumar su cantidad total en precio
        # y luego comparar con los aims de cada stock en cada portfolio y los porcentajes obtenidos
        # y entregar las acciones con los datos que se deben actualizar, ya sea en compra o venta de stocks
        # considera que si hay stocks que no estan en los aims, estos se deben vender

        updates = []

        # Obtener todos los stocks del portafolio
        portfolio_stocks = self.portfolio_stocks.includes(:stock)
        # Obtener todos los aims del portafolio
        portfolio_stock_aims = self.portfolio_stock_aims.includes(:stock)

        # Calcular el valor total del portafolio
        total_value = portfolio_stocks.sum("quantity * stocks.price")

        # calculo los porcentajes actuales de cada stock en el portafolio
        current_percentages = {}
        portfolio_stocks.each do |portfolio_stock|

            # Si el stock no tiene un aim asociado, lo vendo
            unless portfolio_stock_aims.any? { |aim| aim.stock_id == portfolio_stock.stock_id }
                # Calculo la cantidad de acciones a vender
                amount_to_sell = portfolio_stock.quantity * portfolio_stock.stock.price
                if amount_to_sell > 0
                    updates.push(StockAction.new('sell', stock, amount_to_sell))
                end
            end

            stock_price = portfolio_stock.stock.price
            current_percentages[portfolio_stock.stock.id] = ((portfolio_stock.quantity * stock_price) / total_value * 100).round(1)
        end

  
        # Recorro los aims y comparo con los stocks del portafolio
        portfolio_stock_aims.each do |aim|
            stock = aim.stock
            aim_percentage = aim.percentage
            current_percentage = current_percentages[stock.id] || 0

            # Si el porcentaje actual es menor que el aim, necesito comprar
            if current_percentage < aim_percentage
                # Calculo la cantidad de acciones a comprar en moneda
                amount_to_buy = ((aim_percentage - current_percentage) / 100.0) * total_value 
                #redonde a 1 decimal
                amount_to_buy = amount_to_buy.round(1)
                if amount_to_buy > 0
                    updates.push(StockAction.new('buy',stock,amount_to_buy))
                end
            # Si el porcentaje actual es mayor que el aim, necesito vender
            elsif current_percentage > aim_percentage
                # Calculo la cantidad de acciones a vender en moneda
                amount_to_sell = ((current_percentage - aim_percentage) / 100.0) * total_value 
                amount_to_sell = amount_to_sell.round(1)
                if amount_to_sell > 0
                    updates.push(StockAction.new('sell',stock,amount_to_sell))
                end
            end
        end
        

        return updates

    end
end
