class AddCreateBoltAccountToSolidusBoltPaymentSource < ActiveRecord::Migration[6.1]
  def change
    add_column :solidus_bolt_payment_sources, :create_bolt_account, :boolean, default: false
  end
end
