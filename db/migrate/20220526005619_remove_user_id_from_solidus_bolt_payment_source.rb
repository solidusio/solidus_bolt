class RemoveUserIdFromSolidusBoltPaymentSource < ActiveRecord::Migration[6.1]
  def change
    remove_column :solidus_bolt_payment_sources, :user_id, :integer
  end
end
