class CreatePortfolioStocks < ActiveRecord::Migration[8.0]
  def change
    create_table :portfolio_stocks do |t|
      t.float :quantity
      t.belongs_to :portfolio
      t.belongs_to :stock

      t.timestamps
    end
  end
end
