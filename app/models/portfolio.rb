class Portfolio < ApplicationRecord
    has_many :portfolio_stocks, dependent: :destroy
    has_many :portfolio_stock_aims, dependent: :destroy

    validates :name, presence: true

    def rebalance
        # metodo con la logica de rebalanceo,
        # esta funcion debe recorrer los stocks del portafolio, sumar su cantidad en precio o en cantidad
        # y luego comparar con los aims de cada stock en cada portfolio
        # y entregar un json con los datos que se deben actualizar, ya sea en compra o venta de stocks
        #considera que si hay stocks que no estan en los aims, estos se deben vender

        updates = []
        

        return updates

    end
end
