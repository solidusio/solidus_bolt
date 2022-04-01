class CreateSolidusBoltPaymentSources < ActiveRecord::Migration[6.1]
  def change
    create_table :solidus_bolt_payment_sources do |t|
      t.integer :payment_method_id, index: true
      t.string :transaction_id
      t.string :transaction_reference, null: false
      t.string :transaction_type
      t.string :processor
      t.date :date
      t.string :transaction_status
      t.decimal :amount, precision: 10, scale: 2
      t.string :currency
      t.timestamps
    end
  end
end
