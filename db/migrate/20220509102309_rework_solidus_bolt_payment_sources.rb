class ReworkSolidusBoltPaymentSources < ActiveRecord::Migration[6.1]
  def change
    remove_column :solidus_bolt_payment_sources, :transaction_id, :string
    remove_column :solidus_bolt_payment_sources, :transaction_reference, :string
    remove_column :solidus_bolt_payment_sources, :transaction_type, :string
    remove_column :solidus_bolt_payment_sources, :processor, :string
    remove_column :solidus_bolt_payment_sources, :date, :date
    remove_column :solidus_bolt_payment_sources, :transaction_status, :string
    remove_column :solidus_bolt_payment_sources, :amount, :decimal
    remove_column :solidus_bolt_payment_sources, :currency, :string
    add_column :solidus_bolt_payment_sources, :card_token, :string
    add_column :solidus_bolt_payment_sources, :card_last4, :string
    add_column :solidus_bolt_payment_sources, :card_bin, :string
    add_column :solidus_bolt_payment_sources, :card_number, :string
    add_column :solidus_bolt_payment_sources, :card_expiration, :string
    add_column :solidus_bolt_payment_sources, :card_postal_code, :string
    add_column :solidus_bolt_payment_sources, :card_id, :string
  end
end
