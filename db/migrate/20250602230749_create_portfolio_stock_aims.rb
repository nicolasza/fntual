class CreatePortfolioStockAims < ActiveRecord::Migration[8.0]
  def change
    create_table :portfolio_stock_aims do |t|
      t.float :percentage
      t.belongs_to :portfolio
      t.belongs_to :stock

      t.timestamps
    end
  end
end
