class CreatePortfolioImages < ActiveRecord::Migration
  def change
    create_table :portfolio_images do |t|
    	t.integer :user_id
    	t.string :link
      
      t.timestamps null: false
    end
  end
end
