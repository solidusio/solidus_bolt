class RenameBoltConfigurationMerchantIdToDivisionPublicId < ActiveRecord::Migration[6.1]
  def change
    rename_column :solidus_bolt_bolt_configurations, :merchant_id, :division_public_id
  end
end
