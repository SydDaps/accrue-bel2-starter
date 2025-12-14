class CreateGiftCardOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :gift_card_orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :gift_card, null: false, foreign_key: true
      t.string :status, null: false, default: 'pending'
      t.integer :fee, null: false

      t.timestamps
    end
    add_index :gift_card_orders, :status
  end
end
