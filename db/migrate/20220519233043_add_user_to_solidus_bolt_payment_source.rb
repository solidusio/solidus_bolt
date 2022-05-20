class AddUserToSolidusBoltPaymentSource < ActiveRecord::Migration[6.1]
  def change
    add_column :solidus_bolt_payment_sources, :user_id, :integer
  end
end
